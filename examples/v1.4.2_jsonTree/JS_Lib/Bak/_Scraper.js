/**
 * _Scraper.js - Web Data Extraction Module
 */

// Δημιουργία του namespace αν δεν υπάρχει ήδη
window.GOGScraper = window.GOGScraper || {};

// 1. Quick Audit
window.GOGScraper.quickAudit = function() {
    window.Log("Starting Quick Audit...", "SCRAPER");
    const data = {
        type: "SCRAPE_RESULT",
        url: window.location.href,
        title: document.title,
        links_count: document.links.length,
        images_count: document.images.length,
        timestamp: new Date().toISOString()
    };
    window.Log(`Audit complete. Found ${data.links_count} links.`, "SUCCESS");
    window.chrome.webview.postMessage(JSON.stringify(data));
};

// 2. Generic Price Scraper
window.GOGScraper.getPrices = function(selector) {
    window.Log(`Searching for prices with selector: ${selector}`, "DEBUG");
    let prices = Array.from(document.querySelectorAll(selector)).map(el => el.innerText.trim());
    window.Log(`Found ${prices.length} price tags.`, "INFO");
    window.chrome.webview.postMessage(JSON.stringify({
        type: "PRICE_DATA",
        items: prices
    }));
};

// 3. Detailed Game & Price Scraper
window.GOGScraper.getGamesAndPrices = function() {
    window.Log("Scanning for game tiles...", "SCRAPER");
    
    // Επιλέγουμε τα Tiles αλλά φιλτράρουμε ώστε να παίρνουμε κάθε μοναδικό προϊόν
    const tiles = Array.from(document.querySelectorAll('product-tile, .product-tile'));
    const games = [];
    const seenTitles = new Set();

    tiles.forEach(tile => {
        let title = tile.querySelector('.product-tile__title, .title')?.innerText.trim() || "N/A";
        // Αφαιρούμε το "GOOD OLD GAME" text αν υπάρχει για να είναι καθαρός ο τίτλος
        title = title.replace("GOOD OLD GAME\n", "").trim();

        if (title !== "N/A" && !seenTitles.has(title)) {
            seenTitles.add(title);
            games.push({
                title: title,
                price: tile.querySelector('.product-tile__price-discounted, .price, .money')?.innerText.trim() || "Free/Owned",
                url: tile.querySelector('a')?.href || ""
            });
        }
    });

    window.Log(`Cleaned data: Found ${games.length} unique games.`, "SUCCESS");
    window.chrome.webview.postMessage(JSON.stringify({
        type: "GOG_CATALOG",
        count: games.length,
        items: games
    }));
};

// _Scraper.js - Προσθήκη Observer
window.GOGScraper.watchForChanges = function() {
    window.Log("Observer: Searching for catalog container...", "SYSTEM");

    // Δοκιμάζουμε διάφορους selectors που χρησιμοποιεί το GOG
    const selectors = ['catalog-grid', '.catalog__grid', 'div[class*="grid"]', 'section[class*="catalog"]'];
    let targetNode = null;

    for (let s of selectors) {
        targetNode = document.querySelector(s);
        if (targetNode) {
            window.Log(`Observer linked to: ${s}`, "SUCCESS");
            break;
        }
    }

    if (!targetNode) {
        window.Log("Observer Error: No suitable container found. Retrying in 2s...", "WARN");
        setTimeout(window.GOGScraper.watchForChanges, 2000);
        return;
    }

    const observer = new MutationObserver((mutations) => {
        if (mutations.some(m => m.addedNodes.length > 0)) {
            window.Log("New games detected in DOM!", "INFO");
            window.GOGScraper.getGamesAndPrices();
        }
    });

    observer.observe(targetNode, { childList: true, subtree: true });
};
