/**
 * =======================================================================================================
 * _Bridge - MASTER AUTOMATION EXTENSION (v1.4.2 New Demo)
 * =======================================================================================================
 * Description: Middleware for AutoIt <-> WebView2 communication.
 * Version:     1.4.2
 * Last Update: 2026-01-07
 * =======================================================================================================
 */

let BRIDGE_CONFIG = {
    enabled: true,
    color: "rgba(0, 120, 212, 0.7)",
    thickness: "3px",
    duration: 1500
};

// --- MODERN UI SYSTEM ---

/**
 * Multi-toast notification system
 */
function showNotification(message, type = 'success', duration = 3000) {
    const colors = {
        success: '#107c10', error: '#a80000', info: '#0078d4', warning: '#d83b01', scrape: '#800080'
    };

    let container = document.getElementById('autoit-notifications');
    if (!container) {
        container = document.createElement('div');
        container.id = 'autoit-notifications';
        Object.assign(container.style, {
            position: 'fixed', top: '20px', right: '20px', zIndex: '2147483647',
            display: 'flex', flexDirection: 'column', gap: '10px', pointerEvents: 'none'
        });
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    Object.assign(toast.style, {
        minWidth: '250px', padding: '12px 20px', background: colors[type] || colors.success,
        color: 'white', borderRadius: '4px', fontFamily: "'Segoe UI', sans-serif",
        fontSize: '14px', boxShadow: '0 4px 12px rgba(0,0,0,0.3)', transition: 'all 0.4s ease',
        transform: 'translateX(120%)', opacity: '0'
    });

    toast.innerText = message;
    container.appendChild(toast);

    requestAnimationFrame(() => { toast.style.transform = 'translateX(0)'; toast.style.opacity = '1'; });

    setTimeout(() => {
        toast.style.transform = 'translateX(120%)';
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 400);
    }, duration);
}

function highlightElement(el) {
    if (!BRIDGE_CONFIG.enabled || !el) return;
    const originalOutline = el.style.outline;
    el.style.outline = `${BRIDGE_CONFIG.thickness} solid ${BRIDGE_CONFIG.color}`;
    el.style.outlineOffset = "2px";
    setTimeout(() => { el.style.outline = originalOutline; }, BRIDGE_CONFIG.duration);
}

// --- TABLE EXTRACTION ---

function scanTables() {
    let tables = document.querySelectorAll('table');
    let tableList = Array.from(tables).map((table, index) => ({
        index: index,
        id: table.id || "No ID",
        rowCount: table.rows.length,
        colCount: table.rows[0] ? table.rows[0].cells.length : 0
    }));

    window.chrome.webview.postMessage(JSON.stringify({
        type: 'TABLE_LIST',
        count: tables.length,
        data: tableList
    }));
}

function extractTableFromPoint(x, y) {
    let el = document.elementFromPoint(x, y);
    let table = el.closest('table');
    if (table) {
        highlightElement(table);
        let data = Array.from(table.rows).map(r => Array.from(r.cells).map(c => c.innerText.trim()));
        window.chrome.webview.postMessage(JSON.stringify({ type: 'TABLE_DATA', rows: JSON.stringify(data) }));
    }
}

function getTableDataByIndex(index) {
    let tables = document.querySelectorAll('table');
    let table = tables[index];
    if (table) {
        highlightElement(table);
        let rowData = Array.from(table.rows).map(row => Array.from(row.cells).map(cell => cell.innerText.trim()));
        window.chrome.webview.postMessage(JSON.stringify({ type: 'TABLE_DATA', rows: JSON.stringify(rowData) }));
    }
}

// --- FORM AUTOMATION ---

function mapForm() {
    let form = document.activeElement?.closest('form') || document.querySelector('form');
    if (!form) { showNotification('No form found', 'error'); return; }
    highlightElement(form);
    let formMap = {};
    Array.from(form.elements).forEach(el => {
        let key = el.name || el.id;
        if (!key) return;
        if (el.type === 'checkbox') formMap[key] = el.checked;
        else if (el.type === 'radio') { if (el.checked) formMap[key] = el.value; }
        else formMap[key] = el.value;
    });
    window.chrome.webview.postMessage(JSON.stringify({ type: 'FORM_MAP', data: formMap }));
}

function fillForm(jsonString) {
    try {
        let data = typeof jsonString === 'string' ? JSON.parse(jsonString) : jsonString;
        let form = document.querySelector('form');
        if (!form) return "ERROR: No form found";
        highlightElement(form);
        for (let key in data) {
            let el = form.elements[key] || document.getElementById(key);
            if (el) {
                if (el.type === 'checkbox') el.checked = (data[key] === true || data[key] === "true");
                else if (el.type === 'radio') { if (el.value === data[key]) el.checked = true; }
                else el.value = data[key];
                el.dispatchEvent(new Event('input', { bubbles: true }));
                el.dispatchEvent(new Event('change', { bubbles: true }));
            }
        }
        showNotification("Form filled automatically", "success");
        return "SUCCESS";
    } catch (e) { return "ERROR: " + e.message; }
}

// --- SCRAPING & UTILITIES ---

function scrapeLinks() {
    const links = Array.from(document.querySelectorAll('a')).map(a => ({ text: a.innerText.trim(), href: a.href })).filter(l => l.href && l.href.startsWith('http'));
    window.chrome.webview.postMessage(JSON.stringify({ type: 'SCRAPE_RESULT', category: 'links', count: links.length, data: links }));
    showNotification(`Scraped ${links.length} links`, 'scrape');
}

function scrapeImages() {
    const imgs = Array.from(document.querySelectorAll('img')).map(img => ({ alt: img.alt || 'No Alt', src: img.src })).filter(img => img.src && img.src.startsWith('http'));
    window.chrome.webview.postMessage(JSON.stringify({ type: 'SCRAPE_RESULT', category: 'images', count: imgs.length, data: imgs }));
    showNotification(`Scraped ${imgs.length} images`, 'scrape');
}

function scrapeSummary() {
    const summary = {
        title: document.title,
        h1: Array.from(document.querySelectorAll('h1')).map(h => h.innerText.trim()),
        meta_desc: document.querySelector('meta[name="description"]')?.content || 'N/A',
        word_count: document.body.innerText.split(/\s+/).length
    };
    window.chrome.webview.postMessage(JSON.stringify({ type: 'SCRAPE_RESULT', category: 'summary', data: summary }));
    showNotification(`Page Summary Generated`, 'success');
}

function startProgress(startPercent = 20) {
    let bar = document.getElementById('autoit-progress-bar');
    if (bar) bar.remove();
    bar = document.createElement('div');
    bar.id = 'autoit-progress-bar';
    Object.assign(bar.style, {
        position: 'fixed', top: '0', left: '0', height: '4px', width: startPercent + '%', backgroundColor: '#0078D4',
        zIndex: '2147483647', transition: 'width 0.4s ease, opacity 0.5s ease', boxShadow: '0 0 10px rgba(0, 120, 212, 0.5)'
    });
    document.documentElement.appendChild(bar);
}

function finalizeProgress() {
    const bar = document.getElementById('autoit-progress-bar');
    if (!bar) return;
    bar.style.width = '100%';
    setTimeout(() => { bar.style.opacity = '0'; setTimeout(() => bar.remove(), 500); }, 400);
}
