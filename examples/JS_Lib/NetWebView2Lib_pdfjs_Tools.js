/**
 * PDF_Tools.js - Final Combined Library (v1.4.2)
 */

// NetWebView2Lib_pdfjs_Tools.js
async function PDF_ExtractToJSON() {
    if (typeof PDFViewerApplication === 'undefined') return;
    
    const pdf = PDFViewerApplication.pdfDocument;
    const pdfData = {
        type: 'PDF_DATA_PACKAGE',
        metadata: (await pdf.getMetadata()).info,
        pagesCount: pdf.numPages, // Explicitly send page count for AutoIt
        pages: []
    };

    for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        const textContent = await page.getTextContent();
        
        // Map items and include the actual width provided by PDF.js
        // Then sort by Y (top to bottom) and X (left to right)
        let items = textContent.items.map(item => ({
            str: item.str,
            x: item.transform[4],
            y: item.transform[5],
            width: item.width 
        })).sort((a, b) => Math.abs(b.y - a.y) > 5 ? b.y - a.y : a.x - b.x);

        let pageText = "";
        let lastY = -1;
        let lastX = 0;
        const charWidth = 5; // Standard multiplier for visual spacing

        for (const item of items) {
            // Check for line change based on Y coordinate threshold
            if (lastY !== -1 && Math.abs(lastY - item.y) > 5) {
                pageText = pageText.trimEnd() + "\n"; 
                lastX = 0;
            }

            // Calculate horizontal spacing based on distance from last item
            let distance = item.x - lastX;
            let spaces = Math.floor(distance / charWidth);
            
            pageText += " ".repeat(Math.max(0, spaces)) + item.str;
            
            // Update lastX using the actual width of the current text element
            lastX = item.x + item.width; 
            lastY = item.y;
        }
        
        // Push processed page data to the package
        pdfData.pages.push({ 
            pageIndex: i, 
            text: pageText.trim() 
        });
    }
    
    // Send the final JSON package back to AutoIt
    window.chrome.webview.postMessage(JSON.stringify(pdfData));
}

async function PDF_ExtractLegacy() {
    try {
        const pdfUrl = window.PDFViewerApplication.url;
        const pdf = await pdfjsLib.getDocument(pdfUrl).promise;
        let fullText = "";
        for (let i = 1; i <= pdf.numPages; i++) {
            const page = await pdf.getPage(i);
            const textContent = await page.getTextContent();
            fullText += "[Page " + i + "]\n" + textContent.items.map(item => item.str).join(" ") + "\n\n";
        }
        window.chrome.webview.postMessage("PDF_TEXT_RESULT|" + fullText);
    } catch (error) {
        window.chrome.webview.postMessage("ERROR|" + error.message);
    }
}

// --- Highlighting Engine ---

function PDF_HighlightSpansContainingText(text, color, backColor) {
    const spans = document.querySelectorAll('.textLayer span');
    spans.forEach(span => {
        if (span.textContent.includes(text)) {
            span.style.color = color;
            span.style.backgroundColor = backColor;
            span.style.opacity = "1"; 
        }
    });
}

// Alias for PDF_HighlightAndScroll
function PDF_HighlightAndScroll(text, color, backColor) {
    const spans = document.querySelectorAll('.textLayer span');
    let firstFound = null;
    spans.forEach(span => {
        if (span.textContent.includes(text)) {
            span.style.color = color;
            span.style.backgroundColor = backColor;
            span.style.opacity = "1";
            if (!firstFound) firstFound = span;
        }
    });
    if (firstFound) firstFound.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

/**
 * Removes highlights. 
 * If 'text' is provided, it only clears matches for that text.
 * If 'text' is empty/null, it clears ALL highlights on the page.
 */
function PDF_RemoveHighlights(text = null) {
    const spans = document.querySelectorAll('.textLayer span');
    spans.forEach(span => {
        // If text is null OR if the span contains the target text
        if (!text || span.textContent.includes(text)) {
            span.style.color = "";
            span.style.backgroundColor = "";
            span.style.opacity = ""; 
        }
    });
}
