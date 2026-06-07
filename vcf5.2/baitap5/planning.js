// VCF 5.2 Planning & Preparation Workbook - Main Application
// Features: Tab navigation, form management, SQLite/JSON storage, PDF print, history

const APP_VERSION = '1.0.0';
let allData = {};
let db = null;

document.addEventListener('DOMContentLoaded', function() {
  initTabs();
  loadSession();
  initDB();
  updateStatus('Ready');
});

function updateStatus(msg) {
  document.getElementById('statusBar').textContent = msg;
}

// =============== TAB SYSTEM ===============
function initTabs() {
  const tabs = document.querySelectorAll('.tab-btn');
  if (tabs.length > 0) {
    tabs[0].classList.add('active');
    const firstTab = tabs[0].getAttribute('data-tab');
    const el = document.getElementById('tab-' + firstTab);
    if (el) el.classList.add('active');
  }
}

function switchTab(tabId) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  const btn = document.querySelector(`.tab-btn[data-tab="${tabId}"]`);
  const content = document.getElementById('tab-' + tabId);
  if (btn) btn.classList.add('active');
  if (content) content.classList.add('active');
}

// =============== DATA COLLECTION ===============
function collectAllData() {
  const data = { _version: APP_VERSION, _timestamp: new Date().toISOString(), _sections: {} };
  document.querySelectorAll('.tab-content').forEach(tab => {
    const tabId = tab.id.replace('tab-', '');
    const tabData = {};
    tab.querySelectorAll('input, select').forEach(el => {
      if (el.type === 'password' || el.type === 'hidden') return;
      const name = el.name || el.id;
      if (name) {
        const val = el.value;
        if (val !== '' && val !== null && val !== undefined) {
          tabData[name] = val;
        }
      }
    });
    if (Object.keys(tabData).length > 0) {
      data._sections[tabId] = tabData;
    }
  });
  return data;
}

function restoreAllData(data) {
  if (!data || !data._sections) return;
  Object.keys(data._sections).forEach(tabId => {
    const tabData = data._sections[tabId];
    const tab = document.getElementById('tab-' + tabId);
    if (!tab) return;
    Object.keys(tabData).forEach(name => {
      const el = tab.querySelector(`[name="${name}"], #${name}`);
      if (el) {
        el.value = tabData[name];
      }
    });
  });
}

// =============== SESSION MANAGEMENT ===============
function saveSession() {
  const data = collectAllData();
  try {
    localStorage.setItem('vcf_planning_session', JSON.stringify(data));
    showToast('Session saved to browser', 'success');
  } catch (e) {
    showToast('Error saving session: ' + e.message, 'error');
  }
}

function loadSession() {
  try {
    const raw = localStorage.getItem('vcf_planning_session');
    if (raw) {
      const data = JSON.parse(raw);
      restoreAllData(data);
    }
  } catch (e) {
    // ignore
  }
}

// =============== DATABASE (IndexedDB) ===============
function initDB() {
  if (!window.indexedDB) {
    console.warn('IndexedDB not supported');
    return;
  }
  const request = indexedDB.open('VCFPlanningDB', 1);
  request.onerror = () => console.warn('IndexedDB error');
  request.onupgradeneeded = function(e) {
    const db = e.target.result;
    if (!db.objectStoreNames.contains('sessions')) {
      const store = db.createObjectStore('sessions', { keyPath: 'id', autoIncrement: true });
      store.createIndex('timestamp', 'timestamp', { unique: false });
      store.createIndex('name', 'name', { unique: false });
    }
  };
  request.onsuccess = function(e) {
    db = e.target.result;
  };
}

function saveToDB(name) {
  if (!db) { showToast('Database not available', 'error'); return; }
  const data = collectAllData();
  data._name = name || 'Session ' + new Date().toLocaleString();
  data._savedAt = new Date().toISOString();
  const tx = db.transaction(['sessions'], 'readwrite');
  const store = tx.objectStore('sessions');
  store.add(data);
  tx.oncomplete = () => showToast('Saved to database: ' + data._name, 'success');
  tx.onerror = (e) => showToast('DB error: ' + e.target.error, 'error');
}

function getAllFromDB(callback) {
  if (!db) { callback([]); return; }
  const tx = db.transaction(['sessions'], 'readonly');
  const store = tx.objectStore('sessions');
  const request = store.getAll();
  request.onsuccess = () => callback(request.result || []);
  request.onerror = () => callback([]);
}

function deleteFromDB(id) {
  if (!db) return;
  const tx = db.transaction(['sessions'], 'readwrite');
  const store = tx.objectStore('sessions');
  store.delete(id);
  tx.oncomplete = () => showToast('Session deleted', 'info');
}

// =============== JSON EXPORT/IMPORT ===============
function exportJSON() {
  const data = collectAllData();
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'vcf-planning-' + new Date().toISOString().slice(0,10) + '.json';
  a.click();
  URL.revokeObjectURL(url);
  showToast('JSON exported', 'success');
}

function importJSON() {
  document.getElementById('importFile').click();
}

function handleImport(event) {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = function(e) {
    try {
      const data = JSON.parse(e.target.result);
      restoreAllData(data);
      saveSession();
      showToast('Data imported from ' + file.name, 'success');
    } catch (err) {
      showToast('Import error: ' + err.message, 'error');
    }
  };
  reader.readAsText(file);
  event.target.value = '';
}

// =============== PRINT / PDF ===============
function printPDF() {
  saveSession();
  const data = collectAllData();
  const count = Object.keys(data._sections).length;
  updateStatus(`Printing ${count} sections...`);
  setTimeout(() => {
    window.print();
    updateStatus('Ready');
  }, 300);
}

// =============== HISTORY ===============
function showHistory() {
  getAllFromDB(function(items) {
    const title = 'Saved Sessions';
    let html = '';
    if (items.length === 0) {
      html = '<p style="color:var(--text-secondary);text-align:center;padding:20px">No saved sessions found.</p>';
    } else {
      html = '<div class="history-list">';
      items.sort((a,b) => (b._savedAt || '').localeCompare(a._savedAt || ''));
      items.forEach(item => {
        const name = item._name || 'Session #' + item.id;
        const date = item._savedAt ? new Date(item._savedAt).toLocaleString() : 'Unknown';
        const sectionCount = item._sections ? Object.keys(item._sections).length : 0;
        html += '<div class="history-item">';
        html += `<div class="history-name">${name}</div>`;
        html += `<div class="history-date">${date} · ${sectionCount} sections</div>`;
        html += '<div class="history-actions">';
        html += `<button onclick="loadFromDB(${item.id})">Load</button>`;
        html += `<button onclick="exportDBSession(${item.id})">Export JSON</button>`;
        html += `<button onclick="deleteFromDB(${item.id});showHistory();">Delete</button>`;
        html += '</div></div>';
      });
      html += '</div>';
    }
    const footer = items.length > 0 ? '<button class="btn btn-danger" onclick="clearDB()">Clear All History</button>' : '<button class="btn" onclick="closeModal()">Close</button>';
    openModal(title, html, footer);
  });
}

function loadFromDB(id) {
  if (!db) return;
  const tx = db.transaction(['sessions'], 'readonly');
  const store = tx.objectStore('sessions');
  const req = store.get(id);
  req.onsuccess = function() {
    if (req.result) {
      restoreAllData(req.result);
      saveSession();
      showToast('Session loaded', 'success');
      closeModal();
    }
  };
}

function exportDBSession(id) {
  if (!db) return;
  const tx = db.transaction(['sessions'], 'readonly');
  const store = tx.objectStore('sessions');
  const req = store.get(id);
  req.onsuccess = function() {
    if (req.result) {
      const data = req.result;
      delete data.id;
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'vcf-planning-' + (data._name || 'session').replace(/[^a-zA-Z0-9]/g,'-') + '.json';
      a.click();
      URL.revokeObjectURL(url);
    }
  };
}

function clearDB() {
  if (!db) return;
  const tx = db.transaction(['sessions'], 'readwrite');
  const store = tx.objectStore('sessions');
  store.clear();
  tx.oncomplete = function() {
    showToast('All history cleared', 'info');
    showHistory();
  };
}

// =============== SAVE ALL (to DB + localStorage) ===============
function saveAll() {
  saveSession();
  const name = prompt('Name this session:', 'VCF Planning - ' + new Date().toLocaleDateString());
  if (name) {
    saveToDB(name);
  }
}

// =============== CLEAR ALL ===============
function clearAll() {
  if (confirm('Clear all form data? This cannot be undone.')) {
    document.querySelectorAll('input, select').forEach(el => {
      if (el.type === 'password') {
        // keep password defaults
      } else if (el.tagName === 'SELECT') {
        if (el.options.length > 0) el.selectedIndex = 0;
      } else {
        el.value = '';
      }
    });
    localStorage.removeItem('vcf_planning_session');
    showToast('All data cleared', 'info');
  }
}

// =============== MODAL ===============
function openModal(title, bodyHTML, footerHTML) {
  document.getElementById('modalTitle').textContent = title;
  document.getElementById('modalBody').innerHTML = bodyHTML;
  document.getElementById('modalFooter').innerHTML = footerHTML || '';
  document.getElementById('modal').classList.add('show');
}

function closeModal() {
  document.getElementById('modal').classList.remove('show');
}
document.getElementById('modal').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});

// =============== TOAST ===============
function showToast(msg, type) {
  const toast = document.getElementById('toast');
  toast.textContent = msg;
  toast.className = 'toast ' + (type || 'info') + ' show';
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => toast.classList.remove('show'), 3000);
}

// =============== KEYBOARD SHORTCUTS ===============
document.addEventListener('keydown', function(e) {
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault();
    saveSession();
  }
});
