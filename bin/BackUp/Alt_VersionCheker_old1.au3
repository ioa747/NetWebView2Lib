
#include <Misc.au3>

Local $sArch = @AutoItX64 ? "\x64" : "\x86"

Local $sLoaderPath = @ScriptDir & $sArch & "\WebView2Loader.dll" ; $sArch depending on the host
ConsoleWrite("$sLoaderPath=" & $sLoaderPath & @CRLF)
Local $sMinReq = "128.0.2739.15"
Local $sCurrentVersion = _WebView2_GetInstalledVersion($sLoaderPath)



If $sCurrentVersion = "0.0.0.0" Then
    MsgBox(16, "Error", "WebView2 Runtime not found installed.")
    Exit
EndIf

ConsoleWrite("$sCurrentVersion=" & $sCurrentVersion & @CRLF)

; Version comparison
If _VersionCompare($sCurrentVersion, $sMinReq) = -1 Then
MsgBox(48, "Update Required", "Version " & $sCurrentVersion & " is out of date." & @CRLF & _
"At least " & $sMinReq is required)
; Here you can open the download URL
; ShellExecute("https://developer.microsoft.com/en-us/microsoft-edge/webview2/")
Exit
EndIf

ConsoleWrite("WebView2 OK: " & $sCurrentVersion & @CRLF)

ConsoleWrite("WebView2Loader.dll v: " & _GetProperty($sLoaderPath) & @CRLF)

;~ $sLoaderPath=D:\i\Pro\.AutoIT\_Test\100_NetWebView2\NetWebView2Lib\bin\x86\WebView2Loader.dll
;~ $sCurrentVersion=145.0.3800.70
;~ WebView2 OK: 145.0.3800.70
;~ WebView2Loader.dll v: 1.0.2739.15

Func _WebView2_GetInstalledVersion($sLoaderPath)
    ; 1. Load the Loader DLL (WebView2Loader.dll)
    Local $hLoader = DllOpen($sLoaderPath)
    If $hLoader = -1 Then Return "Error: DLL not found"

    ; 2. Call the function
    ; The first parameter is 'ptr' (NULL) to search in default paths.
    ; The second parameter is 'ptr*' to receive the pointer to the version string.
    Local $aRet = DllCall($hLoader, "long", "GetAvailableCoreWebView2BrowserVersionString", _
            "ptr", 0, _      ; browserExecutableFolder: NULL for default
            "ptr*", 0)       ; versionInfo: output pointer

    ; Check for errors or non-S_OK (0) return value
    If @error Or $aRet[0] <> 0 Then
        DllClose($hLoader)
        Return "0.0.0.0"
    EndIf

    ; 3. Get the pointer to the string from the return array
    Local $pVersionInfo = $aRet[2]

    ; 4. Use 'Ptr' and 'wstr' logic to read the string directly
    ; AutoIt can read a wide string from a pointer using DllStructCreate
    Local $tString = DllStructCreate("wchar[128]", $pVersionInfo)
    Local $sVersion = DllStructGetData($tString, 1)

    ; 5. IMPORTANT: Free the memory allocated by the DLL using CoTaskMemFree
    DllCall("ole32.dll", "none", "CoTaskMemFree", "ptr", $pVersionInfo)

    DllClose($hLoader)
    Return $sVersion
EndFunc


Func _GetProperty($sPath)
    Local $sFile = StringTrimLeft($sPath, StringInStr($sPath, "\", 0, -1))
    Local $sDir = StringTrimRight($sPath, (StringLen($sPath) - StringInStr($sPath, "\", 0, -1)))
    Local $oShellApp = ObjCreate("shell.application")
    Local $oDir = $oShellApp.NameSpace($sDir)
    Local $oFile = $oDir.Parsename($sFile)
	Local $sFileVersion = $oFile.ExtendedProperty("System.FileVersion")
	Return $sFileVersion
EndFunc   ;==>_GetProperty