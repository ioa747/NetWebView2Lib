/**
 * 00_Core.js - The Master Bridge Core for NetWebView2Lib
 * This script acts as the primary communication layer between the Browser and AutoIt.
 */

// Ο διακόπτης ελέγχου. Η AutoIt μπορεί να τον αλλάξει δυναμικά με ExecuteScript.
window.DEBUG_ENABLED = window.DEBUG_ENABLED || false;

/**
 * window.Log
 * Η κεντρική συνάρτηση αποστολής μηνυμάτων στην AutoIt.
 * @param {string|object} msg - Το μήνυμα ή το αντικείμενο προς καταγραφή.
 * @param {string} type - Το επίπεδο του log (DEBUG, INFO, ERROR, κλπ).
 */
window.Log = function(msg, type = "DEBUG") {
    if (!window.DEBUG_ENABLED) return;

    // Αν το msg είναι αντικείμενο, το μετατρέπουμε σε string για την AutoIt
    let output = (typeof msg === 'object') ? JSON.stringify(msg) : msg;

    const logData = {
        type: "CONSOLE_LOG",
        level: type,
        message: output,
        timestamp: new Date().toLocaleTimeString()
    };

    try {
        window.chrome.webview.postMessage(JSON.stringify(logData));
    } catch (e) {
        // Fallback αν το WebView2 δεν είναι ακόμα έτοιμο
        console.warn("WebView2 Bridge not ready yet.");
    }
};

/**
 * Console Hijacking
 * Μετατρέπουμε τα κλασικά console.log, console.error κλπ σε window.Log
 */
(function() {
    const originalConsole = {
        log: console.log,
        error: console.error,
        warn: console.warn,
        info: console.info
    };

    console.log = function() {
        window.Log(arguments[0], "BROWSER-LOG");
        originalConsole.log.apply(console, arguments);
    };

    console.error = function() {
        window.Log(arguments[0], "BROWSER-ERROR");
        originalConsole.error.apply(console, arguments);
    };

    console.warn = function() {
        window.Log(arguments[0], "BROWSER-WARN");
        originalConsole.warn.apply(console, arguments);
    };
})();

/**
 * Global Error Handler
 * Πιάνει όλα τα JavaScript σφάλματα (π.χ. ReferenceErrors) και τα στέλνει στην AutoIt.
 */
window.onerror = function(message, source, lineno, colno, error) {
    if (window.DEBUG_ENABLED) {
        let errorMsg = `${message} | Source: ${source} | Line: ${lineno}`;
        window.Log(errorMsg, "CRITICAL-JS-ERROR");
    }
    return false; // Επιτρέπει στο σφάλμα να εμφανιστεί και στα DevTools
};

/**
 * Heartbeat (Προαιρετικό)
 * Ενημερώνει την AutoIt ότι το Bridge είναι ενεργό στη συγκεκριμένη σελίδα.
 */
window.Log("Core Bridge Initialized and Ready", "SYSTEM");