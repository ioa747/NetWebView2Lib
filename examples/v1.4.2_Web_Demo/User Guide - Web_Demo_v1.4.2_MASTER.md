# User Guide: Testing the WebView2 MASTER DEMO

To see the power of the **NetWebView2Lib v1.4.2**, follow these step-by-step instructions for the specific demo scenarios.

### 1. Requirements & Setup

- **Bridge File**: Ensure `_Bridge.js` is in the same directory as the script. It contains the logic for scraping and form mapping.
    
- **Library**: The `NetWebView2Lib.dll` must be registered on your system (`RegAsm`).
    
- **Assets**: Ensure the `Forms_Data` folder exists if you want to test the pre-saved form filling.
    

---

### 2. Scenario A: Wikipedia (Data Scraping & Massive Screenshots)

The demo starts automatically on the Wikipedia population page. This page is perfect for testing high-volume data handling.

- **Extra Long "Full Page Screenshot"**:
    
    1. Go to the **Features** menu (Star icon) -> **Full Page Screenshot**.
        
    2. **What happens**: The script calculates the document height (often over **26,000 pixels**).
        
    3. **GPU Protection**: If the height exceeds the hardware limit (**16,384 pixels**), the script automatically calculates a **Dynamic Scale Factor** (e.g., 0.62x) to ensure the capture is successful without "ghosting" or memory corruption.
       
    4. **Result**: A perfectly rendered PNG of the entire page is saved and opened automatically.
        
- **Direct Table Export (Context Menu)**:
    
    1. **Right-click** anywhere inside the main data table (the list of countries).
        
    2. Select the dynamic option: **📥 Export this Table to CSV**.
        
    3. **What happens**: AutoIt asks JavaScript to parse the specific table under your mouse, converts it to a CSV string, saves it, and opens it in Excel/Notepad.
        
- **Scan for HTML Tables**:
    
    1. Select **Scan for HTML Tables** from the Features menu.
        
    2. An InputBox will appear listing all detected tables and their row counts.
        
    3. Enter a number (e.g., `0`) to extract that specific table.
        

---

### 3. Scenario B: DemoQA (Form Automation & JSON Mapping)

Switch to the form testing site to see how AutoIt handles structured data.

1. Click the **Application Menu** (First icon on the left) and select **demoqa**.
    
2. Once the "Text Box" page loads:
    
    - **Fill Form from JSON**: Right-click the form area and select **Fill Form from JSON File**.
        
    - Navigate to `Forms_Data\` and select the file `DEMOQA_form_20260108-1223-43111.json`.
        
    - **Result**: The script uses **Base64 encoding** to safely pass the JSON to the browser, and JavaScript instantly populates all fields (Name, Email, Addresses).
        
3. **Map Form (Save)**: Fill in some random data yourself, right-click, and select **Save Form Map to JSON File**. This creates a reusable template for that specific page.
    

---

### 4. Advanced Toolset Overview

|**Feature**|**How to use**|**Why it matters**|
|---|---|---|
|**Audit Highlights**|Features -> Highlights|Visually debugs which HTML elements the script is targeting.|
|**Custom CSS Injection**|Features -> Inject Custom CSS|Demonstrates how to force "Dark Mode" or UI changes on any website.|
|**Extension Picker**|App Menu -> Extensions Manager|Allows loading of Chrome extensions (uBlock, Ghostery) from a local folder.|
|**Browser Cleanup**|App Menu -> Clear browser history|One-click deletion of cookies and cache using the internal API.|
|**DevTools**|Right-click -> Inspect Element|Opens the standard F12 developer tools for deep debugging.|

---

### Pro Debugging Tip

Keep your **SciTE Console (F8)** open while running the demo. You will see real-time logs of:

- URL changes and Navigation status.
    
- JSON data payloads being sent through the **JavaScript Bridge**.
    
- COM Errors caught by the `_ErrFunc` handler.
      
---