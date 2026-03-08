
# Logic for MHTML Export

>[!INFO] 
> This extra logic is here to handle modern sites with lazy-loading and responsive breakpoints.  
> For simpler sites, it is not strictly required but highly recommended for consistency.

### The "Viewport Scaling" Logic for MHTML Export:

To ensure a complete MHTML capture on modern responsive sites (like Microsoft.com), we must trigger the **High-Resolution breakpoints** (typically >1408px).

1. **The Goal:** Force the browser to load assets intended for Ultra-Wide layouts, even if the user's physical window is smaller.
    
2. **The Method:** We use `$oWebV2M.ZoomFactor = 0.5` during the pre-export phase. This expands the logical viewport (e.g., a 1000px GUI becomes a 2000px virtual canvas), triggering the CSS media queries to load all high-res assets.
    
3. **The Scaling Factor:** We must note that these calculations assume **100% Windows Scaling**. If a user has 150% scaling, the "physical" width needed is even higher. Using Zoom 0.5 is the most reliable "universal" way to bypass local DPI settings and ensure the MHTML remains visual even when viewed on a 1920px monitor.
    
4. **Scope:** This is specifically required for sites using **Lazy-Loaded assets** and **Responsive Breakpoints** that hide/show content based on width.
    

This table explains how the **Zoom Factor** affects the **Virtual Viewport**  
assuming a typical GUI width of **1000px**:

### Viewport Scaling Logic (Base GUI: 1000px)

|Zoom Factor|Virtual Viewport Width|Breakpoint Targeted|Result for MHTML|
|---|---|---|---|
|**1.0**|1000px|Mobile / Tablet|Missing High-Res Assets|
|**0.8**|1250px|Standard Desktop|Missing Ultra-Wide Assets|
|**0.75**|1333px|Standard Desktop|Still below the 1408px limit|
|**0.7**|1428px|**Ultra-Wide (>1408px)**|**Triggers 1408px assets**|
|**0.5**|**2000px**|**4K / Ultra-Wide**|**Full Asset Capture (Safe Zone)**|

---

### Important Technical Constraint: Breakpoint Lock

When using `ZoomFactor = 0.5` to ensure we capture the **Ultra-Wide / 4K assets** (>1408px), we are effectively "locking" the MHTML package to that specific responsive state.

- **The Trade-off:** While this ensures the page looks perfect on high-resolution monitors (1920px and above), the browser might not include the assets required for the **Standard Desktop** layout.
    
- **The Result:** If a user opens the resulting MHTML and resizes the window below the 1408px threshold, some images or icons might disappear because they weren't part of the "Wide" capture session.
    
- **Conclusion:** We choose **0.5** as the default for the Demo because it covers the most common use case (Modern Desktop viewing), but users should be aware that MHTML is not truly "fluid" across all breakpoints unless all states are triggered before export.
    

---
### Example
005-SaveDemo.au3:

```autoit
	#Region ; MHTML
	; # NOTE # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; This sequence ensures that responsive design (CSS) and lazy-loaded assets
	; We use Zoom 0.5 to trigger Ultra-Wide assets (>1408px). 
	; Note: This might cause missing assets if the MHTML is viewed in a very small window later,
	; as the browser only bundles assets active during the current (Wide) session.
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$oWebV2M.ZoomFactor = 0.5
	_ForceAntiLazy($oWebV2M)
	Local $s_MHTML_content = _NetWebView2_ExportPageData($oWebV2M, 1, "")
	$oWebV2M.ZoomFactor = 1.0

    ; Save to file
    Local $s_MHTML_FileFullPath = @ScriptDir & '\5-SaveDemo_result.mhtml'
    If FileExists($s_MHTML_FileFullPath) Then FileDelete($s_MHTML_FileFullPath)
    FileWrite($s_MHTML_FileFullPath, $s_MHTML_content)

    ; Open the result in the default browser (Edge)
    ShellExecute($s_MHTML_FileFullPath)
    #EndRegion ; MHTML
...
...
Func _ForceAntiLazy($oWebV2M)
    Local $sJS = ""
    $sJS &= "(function() {" & @CRLF
    $sJS &= "    document.querySelectorAll('img').forEach(img => {" & @CRLF
    $sJS &= "        img.setAttribute('loading', 'eager');" & @CRLF
    $sJS &= "        if (img.dataset.srcset) img.srcset = img.dataset.srcset;" & @CRLF
    $sJS &= "        if (img.dataset.src) img.src = img.dataset.src;" & @CRLF
    $sJS &= "    });" & @CRLF
    $sJS &= "    window.scrollTo(0, document.body.scrollHeight);" & @CRLF
    $sJS &= "    setTimeout(() => { window.scrollTo(0, 0); }, 150);" & @CRLF
    $sJS &= "    return 'AntiLazy: Multi-layout triggered.';" & @CRLF
    $sJS &= "})();"

    Local $sResult = _NetWebView2_ExecuteScript($oWebV2M, $sJS, 2)
    Sleep(500) ; Slightly more sleep to handle the 1408px transition
    Return $sResult
EndFunc
```

---
