/**
 * =======================================================================================================
 * _Bridge - EXTERNAL AUTOMATION EXTENSION
 * =======================================================================================================
 * Description: Middleware for AutoIt <-> WebView2 communication.
 * Version:     1.0.0
 * Last Update: 2025-01-01
 * * API INDEX:
 * - mapForm() : Scans and maps the active form.
 * - fillForm(json) : Fills form fields from JSON data.
 * - extractTableFromPoint(x,y): Exports table data based on coordinates.
 * - getTableDataByIndex(idx) : Exports table data by DOM index.
 * - scanTables() : Discovers all tables on the page.
 * - setBridgeConfig(json) : Updates settings (color, enabled, etc.)
 * - highlightElement(el) : Provides visual feedback.
 * - showNotification(message, type = 'success', duration = 3000) : notification toast in the browser
 * - waitForElement(selector) : Waits until an element appears in the DOM and then sends a message to AutoIt.
 * - scanForFiles(extension) : Scans the page for files with a specific extension and sends them to AutoIt.
 * - getFilesByExtension(ext) : This function will return the list of files to AutoIt
 * - startProgress(startPercent) : Creates and starts a progress bar indicator.
 * - showWelcomeForm() : Renders a dynamic Welcome Form directly into the page body.
 * =======================================================================================================
 */
	
/**
* DYNAMIC CONFIGURATION
 */
let BRIDGE_CONFIG = {
    enabled: false,
    color: "rgba(255, 0, 0, 0.7)",
    thickness: "4px",
    duration: 1200
};

/**
 * Updates the bridge configuration from AutoIt
 * @param {string} jsonSettings - JSON string with new settings
 */
function setBridgeConfig(jsonSettings) {
    try {
        let newSettings = JSON.parse(jsonSettings);
        
        // Direct assignment to avoid issues with the spread operator (...)
        if (newSettings.enabled !== undefined) BRIDGE_CONFIG.enabled = newSettings.enabled;
        if (newSettings.color !== undefined) BRIDGE_CONFIG.color = newSettings.color;
        if (newSettings.thickness !== undefined) BRIDGE_CONFIG.thickness = newSettings.thickness;
        if (newSettings.duration !== undefined) BRIDGE_CONFIG.duration = newSettings.duration;

        // Debugging: You will see this message in the Browser Console (F12)
        console.log("BRIDGE_CONFIG UPDATED:", BRIDGE_CONFIG);
        
        return "CONFIG_UPDATED";
    } catch (e) {
        console.error("CONFIG_ERROR:", e.message);
        return "CONFIG_ERROR: " + e.message;
    }
}

/**
* THE HIGHLIGHT FUNCTION
 */
function highlightElement(el) {
    if (!BRIDGE_CONFIG.enabled || !el) return;

    // Apply the highlight
    const originalOutline = el.style.outline;
    el.style.outline = `${BRIDGE_CONFIG.thickness} solid ${BRIDGE_CONFIG.color}`;
    el.style.outlineOffset = "2px";

    // Timer for removing the effect
    setTimeout(() => {
        el.style.outline = originalOutline;
        
        BRIDGE_CONFIG.enabled = false; 
        console.log("Bridge automatically disabled after highlight.");
    }, BRIDGE_CONFIG.duration);
}

/**
* FORM MAPPING
 */
function mapForm() {
    let target = document.activeElement;
    let form = target.closest('form') || document.querySelector('form');
    
    if (!form) {
        window.chrome.webview.postMessage(JSON.stringify({
            type: 'ERROR', 
            message: 'No form found near selection.'
        }));
        return;
    }
    
    highlightElement(form);

    let formMap = {};
    Array.from(form.elements).forEach(el => {
        let key = el.name || el.id;
        if (!key) return;
        if (el.type === 'checkbox') formMap[key] = el.checked;
        else if (el.type === 'radio') { if (el.checked) formMap[key] = el.value; }
        else formMap[key] = el.value;
    });

    window.chrome.webview.postMessage(JSON.stringify({
        type: 'FORM_MAP',
        data: JSON.stringify(formMap)
    }));
}

/**
* FORM FILLING
 */
function fillForm(jsonString) {
    try {
        let data = JSON.parse(jsonString);
        let form = document.activeElement.closest('form') || document.querySelector('form');
        if (!form) return "ERROR: No form found";

        highlightElement(form); // Highlight when filling starts

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
        return "SUCCESS";
    } catch (e) { return "ERROR: " + e.message; }
}

/**
* TABLE EXTRACTION FROM POINT
 */
function extractTableFromPoint(x, y) {
    let el = document.elementFromPoint(x, y);
    let table = el.closest('table');
    if (table) {
        highlightElement(table);
        let data = Array.from(table.rows).map(r => 
            Array.from(r.cells).map(c => c.innerText.trim())
        );
        window.chrome.webview.postMessage(JSON.stringify({
            type: 'TABLE_DATA', 
            rows: JSON.stringify(data)
        }));
    } else {
        window.chrome.webview.postMessage(JSON.stringify({
            type: 'ERROR', 
            message: 'No table found at these coordinates.'
        }));
    }
}

/**
* GET SPECIFIC TABLE DATA BY INDEX
 */
function getTableDataByIndex(index) {
    let tables = document.querySelectorAll('table');
    let table = tables[index];
    if (table) {
        highlightElement(table);
        let rowData = Array.from(table.rows).map(row => 
            Array.from(row.cells).map(cell => cell.innerText.trim())
        );
        window.chrome.webview.postMessage(JSON.stringify({
            type: 'TABLE_DATA',
            rows: JSON.stringify(rowData)
        }));
    }
}

/**
* TABLE SCANNER
 */
function scanTables() {
    let tables = document.querySelectorAll('table');
    let tableList = Array.from(tables).map((table, index) => {
        return {
            index: index,
            id: table.id || "No ID",
            className: table.className || "No Class",
            rowCount: table.rows.length,
            colCount: table.rows[0] ? table.rows[0].cells.length : 0 // Add the columns too
        };
    });
    
    window.chrome.webview.postMessage(JSON.stringify({
        type: 'TABLE_LIST',
        count: tables.length,
        data: tableList // JSON.stringify will eventually catch it all
    }));
    
    //showNotification(`Detected ${tables.length} tables`, 'info');
}

/**
 * Shows a professional notification toast in the browser
 * @param {string} message - The text to display
 * @param {string} type - 'success', 'error', 'info'
 * @param {number} duration - MS to show the message
 */
function showNotification(message, type = 'success', duration = 3000) {
    // Colors based on type
    const colors = {
        success: '#4CAF50',
        error: '#f44336',
        info: '#2196F3',
        warning: '#ff9800'
    };

    // Remove existing notification if any
    const oldDiv = document.getElementById('autoit-notification');
    if (oldDiv) oldDiv.remove();

    // Create element
    const div = document.createElement('div');
    div.id = 'autoit-notification';
    
    // Styling
    Object.assign(div.style, {
        position: 'fixed',
        top: '20px',
        left: '50%',
        transform: 'translateX(-50%)',
        padding: '15px 25px',
        background: colors[type] || colors.success,
        color: 'white',
        borderRadius: '8px',
        zIndex: '99999',
        fontFamily: 'sans-serif',
        fontSize: '14px',
        fontWeight: 'bold',
        boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
        transition: 'opacity 0.5s ease',
        pointerEvents: 'none' // Don't block clicks
    });

    div.innerText = message;
    document.body.appendChild(div);

    // Fade out and remove
    setTimeout(() => {
        const target = document.getElementById('autoit-notification');
        if (target) {
            target.style.opacity = '0';
            setTimeout(() => target.remove(), 500);
        }
    }, duration);
}

/**
* Waits until an element appears in the DOM and then sends a message to AutoIt.
* @param {string} selector - The CSS selector (e.g. '#submit-btn')
 */
function waitForElement(selector) {
    const el = document.querySelector(selector);
    if (el) {
        window.chrome.webview.postMessage(JSON.stringify({ type: 'ELEMENT_READY', selector: selector }));
        return;
    }

    const observer = new MutationObserver((mutations, obs) => {
        const element = document.querySelector(selector);
        if (element) {
            window.chrome.webview.postMessage(JSON.stringify({ type: 'ELEMENT_READY', selector: selector }));
            obs.disconnect(); // Stop watching
        }
    });

    observer.observe(document.body, { childList: true, subtree: true });
}

/**
 * Scans the page for files with a specific extension and sends them to AutoIt.
 * @param {string} extension - e.g., '.zip', '.jpg', '.pdf'
 */
function scanForFiles(extension) {
    const links = document.querySelectorAll('a, img');
    const files = [];
    const ext = extension.toLowerCase();

    links.forEach(el => {
        let url = el.href || el.src;
        if (url && url.toLowerCase().endsWith(ext)) {
            files.push(url);
        }
    });

    // Remove duplicates
    const uniqueFiles = [...new Set(files)];

    window.chrome.webview.postMessage(JSON.stringify({
        type: 'FILE_LIST',
        extension: extension,
        count: uniqueFiles.length,
        links: uniqueFiles
    }));

    showNotification(`Found ${uniqueFiles.length} ${extension} files`, 'info');
}

/**
 * This function will return the list of files to AutoIt
 * @param {string} ext - e.g., '.zip', '.jpg', '.pdf'
 */
function getFilesByExtension(ext) {
    const allLinks = Array.from(document.querySelectorAll('a'));
    const filtered = allLinks
        .map(a => a.href)
        .filter(href => href.toLowerCase().endsWith(ext.toLowerCase()));
    
    window.chrome.webview.postMessage(JSON.stringify({
        type: 'BULK_DOWNLOAD',
        extension: ext,
        links: filtered
    }));
}

/**
 * Creates and starts a progress bar indicator.
 * Can be called multiple times from AutoIt.
 * @param {number} startPercent - The initial width (default 20)
 */
function startProgress(startPercent = 20) {
    // Remove existing bar if any
    let existingBar = document.getElementById('autoit-progress-bar');
    if (existingBar) existingBar.remove();

    // Create the bar element
    const progressBar = document.createElement('div');
    progressBar.id = 'autoit-progress-bar';
    
    // Modern UI Styling with English comments
    Object.assign(progressBar.style, {
        position: 'fixed',
        top: '0',
        left: '0',
        width: startPercent + '%',
        height: '4px',
        backgroundColor: '#0078D4', 
        zIndex: '2147483647',
        transition: 'width 0.4s ease, opacity 0.5s ease',
        boxShadow: '0 0 10px rgba(0, 120, 212, 0.5)',
        pointerEvents: 'none',
        opacity: '1'
    });
    
    document.documentElement.appendChild(progressBar);

    // Global listener to update progress during standard page loads
    document.onreadystatechange = () => {
        if (document.readyState === 'interactive') progressBar.style.width = '70%';
        if (document.readyState === 'complete') finalizeProgress();
    };
}

/**
 * Moves the bar to 100% and fades it out.
 */
function finalizeProgress() {
    const progressBar = document.getElementById('autoit-progress-bar');
    if (!progressBar) return;
    
    progressBar.style.width = '100%';
    setTimeout(() => {
        progressBar.style.opacity = '0';
        setTimeout(() => { if (progressBar.parentNode) progressBar.remove(); }, 500);
    }, 400);
}

/**
 * Renders a dynamic Welcome Form directly into the page body.
 * This can be called even on a blank page.
 */
function showWelcomeForm() {
    // Set body styles directly via JS to match your theme
    document.body.style.backgroundColor = '#1e1e1e';
    document.body.style.color = '#e0e0e0';
    document.body.style.fontFamily = "'Segoe UI', sans-serif";
    document.body.style.padding = '20px';

    // Inject the HTML structure
    document.body.innerHTML = `
        <style>
            :root {
              --bg-color: #1e1e1e; --form-bg: #2d2d2d;
              --accent-color: #4db8ff; --btn-color: #0078d7; --txt-color: #e0e0e0;
            }
            #contactForm { 
                max-width: 400px; background-color: var(--form-bg); 
                padding: 20px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.5);
                margin: auto; 
            }
            label { display: block; margin-bottom: 5px; font-weight: bold; color: var(--accent-color); }
            input, textarea { 
                width: 100%; padding: 10px; background-color: #3d3d3d; border: 1px solid #555; 
                border-radius: 4px; color: #fff; box-sizing: border-box; margin-bottom: 15px; 
            }
            button { 
                background-color: var(--btn-color); color: white; border: none; padding: 12px 20px; 
                border-radius: 4px; cursor: pointer; width: 100%; font-size: 16px; 
            }
        </style>
        <form id="contactForm">
          <label>Name:</label><input type="text" id="name">
          <label>Email:</label><input type="email" id="mail">
          <label>Message:</label><textarea id="msg"></textarea>
          <button type="button" onclick="submitToAutoIt()">Send Message</button>
        </form>
    `;
}

/**
 * Handles form submission and communicates with AutoIt.
 */
function submitToAutoIt() {
    const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('mail').value,
        message: document.getElementById('msg').value
    };
    
    // Send data to AutoIt via postMessage
    window.chrome.webview.postMessage('SUBMIT_FORM:' + JSON.stringify(formData));
    
    // Reset form after sending
    document.getElementById('contactForm').reset();
}
