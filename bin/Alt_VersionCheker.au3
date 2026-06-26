
#include <Misc.au3>

_WebView2_CheckInstalledVersion(@ScriptDir)

Func _WebView2_CheckInstalledVersion($sBasePath, $sMinReq = "128.0.2739.15")
	Local $sArch = @AutoItX64 ? "\x64" : "\x86"
	Local $sLoaderPath = $sBasePath & $sArch & "\WebView2Loader.dll" ; $sArch depending on the host
	Local $sCurrentVersion = "0.0.0.0" ;= _WebView2_GetInstalledVersion($sLoaderPath)

	; Load the Loader DLL (WebView2Loader.dll)
	Local $hLoader = DllOpen($sLoaderPath)
	If $hLoader <> -1 Then

		; === Call the function ===
		; The first parameter is 'ptr' (NULL) to search in default paths.
		; The second parameter is 'ptr*' to receive the pointer to the version string.
		Local $aRet = DllCall($hLoader, "long", "GetAvailableCoreWebView2BrowserVersionString", _
				"ptr", 0, _  ; browserExecutableFolder: NULL for default
				"ptr*", 0)   ; versionInfo: output pointer

		; Check for errors or non-S_OK (0) return value
		If @error Or $aRet[0] <> 0 Then
			DllClose($hLoader)
		Else

			Local $pVersionInfo = $aRet[2]
			Local $tString = DllStructCreate("wchar[128]", $pVersionInfo)
			Local $sVersion = DllStructGetData($tString, 1)

			; Free the memory allocated by the DLL using CoTaskMemFree
			DllCall("ole32.dll", "none", "CoTaskMemFree", "ptr", $pVersionInfo)

			DllClose($hLoader)
			$sCurrentVersion = $sVersion
		EndIf
	EndIf

	If $sCurrentVersion = "0.0.0.0" Then
		MsgBox(16, "Error", "WebView2 Runtime not found installed.")
		Exit
	EndIf

	; Version comparison
	If _VersionCompare($sCurrentVersion, $sMinReq) = -1 Then
		MsgBox(48, "Update Required", "Version " & $sCurrentVersion & " is out of date." & @CRLF & _
				"At least " & $sMinReq & " is required")
		; ShellExecute("https://developer.microsoft.com/en-us/microsoft-edge/webview2/")
		Exit
	EndIf

	ConsoleWrite("WebView2 OK: " & $sCurrentVersion & @CRLF)
EndFunc   ;==>_WebView2_CheckInstalledVersion

