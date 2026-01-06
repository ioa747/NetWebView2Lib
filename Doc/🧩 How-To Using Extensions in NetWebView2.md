
With the release of **v1.3.0**, you can now load browser extensions (unpacked) independently for each WebView2 instance. This is perfect for adding Ad-blockers, Dark Mode, or custom developer tools to your automation scripts.

---

#### 1. Prepare your Extension Library

WebView2 requires extensions to be in **Unpacked** format (a folder containing the `manifest.json` file).

1. Create a folder named `Extensions_Lib` in your project directory.
    
2. Download your desired extension (e.g., **uBlock Origin Lite** or **Dark Reader**).
    
3. If you have a `.crx` file, extract it using a ZIP tool.
    
4. Your structure should look like this:
    
    Plaintext
    
    ```
    YourProject/
    ├── MyScript.au3
    └── Extensions_Lib/
        └── DarkReader/
            ├── manifest.json  <-- This must be in the root of the folder
            ├── background.js
            └── ...
    ```
    

#### 2. Implementation in AutoIt

Extensions must be loaded **after** the engine is ready (`INIT_READY`) but **before** or during the initial navigation.

AutoIt

```
; Example for Instance 2
Func Web2_OnMessageReceived($sMsg)
    Local $aParts = StringSplit($sMsg, "|")
    Local $sCommand = StringStripWS($aParts[1], 3)

    Switch $sCommand
        Case "INIT_READY"
            ; Define the path to your unpacked extension
            Local $sExtPath = @ScriptDir & "\Extensions_Lib\DarkReader"
            
            ; Load the extension for this specific instance
            $oWeb2.AddExtension($sExtPath)
            
            ; Navigate to your target site
            $oWeb2.Navigate("https://www.autoitscript.com/forum/")
            
        Case "EXTENSION_LOADED"
            ConsoleWrite("+> Success: Extension loaded in Web2!" & @CRLF)
            
        Case "ERROR"
            If StringInStr($sMsg, "EXTENSION") Then 
                ConsoleWrite("!> Error: Failed to load extension." & @CRLF)
            EndIf
    EndSwitch
EndFunc
```

#### Key Features in v1.3.0:

- **Isolation**: Loading an extension in `Web1` does not affect `Web2`. Each instance stays completely independent.
    
- **Persistence**: Since v1.3.0 uses dedicated User Profiles, extension settings (like custom filters or dark mode intensity) are saved automatically in the profile folder.
    
- **Event Tracking**: The new version sends a `EXTENSION_LOADED` message back to AutoIt so you can confirm the injection was successful.
    

---

### Manual Method: Extracting Extensions from your Browser

If you already have the extension installed in your Chrome or Edge browser, follow these steps to "extract" it for use with this library:

1. **Find the Extension ID:**
    
    - Open your browser and navigate to `chrome://extensions/` or `edge://extensions/`.
        
    - Enable **Developer mode** (toggle switch at the top right).
        
    - Locate your extension (e.g., Dark Reader) and copy its **ID** (a long string of random letters like `eimadpbcbfnmbkopoojfekhnkhdbieeh`).
        
2. **Locate the Source Folder:**
    
    - Press `Win + R`, paste the following path, and press Enter:
        
        - **For Edge:** `%LocalAppData%\Microsoft\Edge\User Data\Default\Extensions`
            
        - **For Chrome:** `%LocalAppData%\Google\Chrome\User Data\Default\Extensions`
            
    - Find the folder named after the **ID** you copied in Step 1.
        
3. **Identify the Unpacked Folder:**
    
    - Inside that folder, you will see a sub-folder named after the version number (e.g., `4.9.118_0`).
        
    - **Crucial:** This version folder is your "Unpacked Extension". It contains the `manifest.json` file.
        
4. **Copy to your Project:**
    
    - Copy the version folder into your project's `Extensions_Lib` directory.
        
    - **Pro Tip:** Rename the folder from `4.9.118_0` to something readable like `DarkReader` to keep your code clean.
        

---

# How-To: stored in your library 

With the  `#include "_WV2_ExtensionPicker.au3"`
### 1. The New Folder Architecture (Format: `Name_ID`)

For the automated **Extension Picker** to function properly, extensions must be stored in your library (`Extensions_Lib`) using a specific naming format.

**Syntax:** `[Extension Name]_[32-char ID]`

Example:

`Extensions_Lib\DarkReader_eimadpbcbfnmbkopoojfekhnkhdbieeh`


    Your Extensions_Lib/
        └── DarkReader_eimadpbcbfnmbkopoojfekhnkhdbieeh/
            ├── manifest.json  <-- This must be in the root of the folder
            ├── background.js
            └── ...
            

> **Why this format?**
> 
> - **Name:** AutoIt uses this to display a user-friendly name for the extension in the list.
>     
> - **ID:** AutoIt uses this to check if the extension is already active in the `UserDataPath` and to generate the `extension://ID/` URL.
>     

---

### 2. Using the Extension Picker (UI Mode)

Instead of "hardcoding" extensions into your script, you can call the new Native Module:

**AutoIt**

AutoIt

```
#include "_WV2_ExtensionPicker.au3"

; Call the Picker (Modal Window)
_WV2_ShowExtensionPicker($iWidth = 500, $iHeight = 600, $hWND = 0, $sExtSourcePath = "", $sUserDataPath = "")
```

### 3. How to Find the Correct ID

1. Install the extension in your regular Chrome/Edge browser.
    
2. Navigate to `chrome://extensions`.
    
3. Enable **Developer Mode** (top right).
    
4. Click the **Details** button on the extension you want.
    
5. Copy the **ID** (e.g., `eimadpbcbfnmbkopoojfekhnkhdbieeh`).
    
6. Rename the extension folder in your library to `DarkReader_eimadpbcbfnmbkopoojfekhnkhdbieeh`.
    

---

### 5. Technical Note (State Sync)

The Picker performs a real-time check of the following folder:

`UserDataPath\EBWebView\Default\Local Extension Settings`

If the extension ID is found there, the button automatically changes from **"Add Extension"** to **"Launch"**, allowing for the immediate start of the Extension UI.

---

Example: 

