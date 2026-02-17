#include-once
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_Events__*,__NetWebView2_JSEvents__*

#Tidy_Parameters=/tcb=-1

; NetWebView2Lib.au3 - Script Version: 2026.2.17.5 🚩

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <SendMessage.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPIShPath.au3>
#include <WinAPISysWin.au3>
#include <WindowsConstants.au3>

#REMARK This UDF is marked as WorkInProgress - you may use them, but do not blame me if I do ScriptBreakingChange and as so far do not ask me for description or help till I remove this remark ; mLipok
#TODO UDF HEADER - anybody - feel free to make it done - just do not hesitate to full fill this part
#TODO UDF INDEX - anybody - feel free to make it done - just do not hesitate to full fill this part
#TODO FUNCTION HEADERS SUPLEMENTATION & CHECK - anybody - feel free to make it done - just do not hesitate to full fill this part
#INFO JScript related to WebView2 that we can learn from ; https://github.com/MicrosoftEdge/WebView2Browser/tree/main/wvbrowser_ui

; Global objects
Global $_g_bNetWebView2_DebugInfo = True
;~ Global $_g_bNetWebView2_DebugDev = False
Global $_g_bNetWebView2_DebugDev = (@Compiled = 1)
#Region ; ENUMS

#Region ; ENUMS

;~ Global Enum _
;~ 		$NETWEBVIEW2_ERR__INIT_FAILED, _
;~ 		$NETWEBVIEW2_ERR__PROFILE_NOT_READY, _
;~ 		$NETWEBVIEW2_ERR___FAKE_COUNTER

Global Enum _ ; $NETWEBVIEW2_MESSAGE__* are set by mainly by __NetWebView2_Events__OnMessageReceived() but also others
		$NETWEBVIEW2_MESSAGE__NONE, _ ; UDF setting - not related directly to API REFERENCES
		$NETWEBVIEW2_MESSAGE__INIT_FAILED, _
		$NETWEBVIEW2_MESSAGE__PROFILE_NOT_READY, _
		$NETWEBVIEW2_MESSAGE__INIT_READY, _
		$NETWEBVIEW2_MESSAGE__NAV_STARTING, _
		$NETWEBVIEW2_MESSAGE__URL_CHANGED, _
		$NETWEBVIEW2_MESSAGE__HISTORY_CHANGED, _ ; #TODO https://learn.microsoft.com/en-us/microsoft-edge/webview2/get-started/wpf#step-7---navigation-events
		$NETWEBVIEW2_MESSAGE__SOURCE_CHANGED, _ ; #TODO https://learn.microsoft.com/en-us/microsoft-edge/webview2/get-started/wpf#step-7---navigation-events
		$NETWEBVIEW2_MESSAGE__CONTENT_LOADING, _ ; #TODO https://learn.microsoft.com/en-us/microsoft-edge/webview2/get-started/wpf#step-7---navigation-events
		$NETWEBVIEW2_MESSAGE__BASIC_AUTHENTICATION_REQUESTED, _ ; #TODO WHERE THIS SHOULD be Lower/Higher ?
		$NETWEBVIEW2_MESSAGE__CRITICAL_ERROR, _
		$NETWEBVIEW2_MESSAGE__DOM_CONTENT_LOADED, _ ; #TODO https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/navigation-events
		$NETWEBVIEW2_MESSAGE__NAV_ERROR, _
		$NETWEBVIEW2_MESSAGE__NAV_COMPLETED, _
		$NETWEBVIEW2_MESSAGE__PROCESS_FAILED, _
		$NETWEBVIEW2_MESSAGE__TITLE_CHANGED, _
		$NETWEBVIEW2_MESSAGE__BROWSER_GOT_FOCUS, _
		$NETWEBVIEW2_MESSAGE__BROWSER_LOST_FOCUS, _
		$NETWEBVIEW2_MESSAGE__WINDOW_RESIZED, _
		$NETWEBVIEW2_MESSAGE__ZOOM_CHANGED, _
		$NETWEBVIEW2_MESSAGE__EXTENSION, _
		$NETWEBVIEW2_MESSAGE__EXTENSION_LOADED, _ ; #TODO Question ? when EXTENSION is loaded ? before $NETWEBVIEW2_MESSAGE__INIT_READY ? before $NETWEBVIEW2_MESSAGE__NAV_COMPLETED ?
		$NETWEBVIEW2_MESSAGE__EXTENSION_FAILED, _
		$NETWEBVIEW2_MESSAGE__EXTENSION_REMOVED, _
		$NETWEBVIEW2_MESSAGE__EXTENSION_NOT_FOUND, _
		$NETWEBVIEW2_MESSAGE__REMOVE_EXTENSION_FAILED, _
		$NETWEBVIEW2_MESSAGE__SELECTED_TEXT, _
		$NETWEBVIEW2_MESSAGE__INNER_TEXT, _
		$NETWEBVIEW2_MESSAGE__INNER_TEXT_FAILED, _
		$NETWEBVIEW2_MESSAGE__HTML_SOURCE, _
		$NETWEBVIEW2_MESSAGE__CAPTURE_SUCCESS, _
		$NETWEBVIEW2_MESSAGE__CAPTURE_ERROR, _
		$NETWEBVIEW2_MESSAGE__PRINT_ERROR, _
		$NETWEBVIEW2_MESSAGE__PDF_EXPORT_SUCCESS, _
		$NETWEBVIEW2_MESSAGE__PDF_EXPORT_ERROR, _
		$NETWEBVIEW2_MESSAGE__CDP_RESULT, _
		$NETWEBVIEW2_MESSAGE__CDP_ERROR, _
		$NETWEBVIEW2_MESSAGE__DATA_CLEARED, _
		$NETWEBVIEW2_MESSAGE__COOKIES_B64, _
		$NETWEBVIEW2_MESSAGE__COOKIES_ERROR, _
		$NETWEBVIEW2_MESSAGE__COOKIE_ADD_ERROR, _
		$NETWEBVIEW2_MESSAGE__BLOCKED_AD, _
		$NETWEBVIEW2_MESSAGE__DOWNLOAD_STARTING, _
		$NETWEBVIEW2_MESSAGE__DOWNLOAD_IN_PROGRESS, _
		$NETWEBVIEW2_MESSAGE__DOWNLOAD_INTERRUPTED, _
		$NETWEBVIEW2_MESSAGE__DOWNLOAD_COMPLETED, _
		$NETWEBVIEW2_MESSAGE__RESPONSE_RECEIVED, _
		$NETWEBVIEW2_MESSAGE__UNKNOWN_MESSAGE, _
		$NETWEBVIEW2_MESSAGE___FAKE_COUNTER

Global Enum _
		$NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET, _
		$NETWEBVIEW2_EXECUTEJS_MODE1_ASYNC, _
		$NETWEBVIEW2_EXECUTEJS_MODE2_RESULT, _
		$NETWEBVIEW2_ExecuteJS__FAKE_COUNTER

Global Enum _ ; Indicates the type of process that has failed.
		$NETWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_EXITED, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_RENDER_EXITED, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_RENDER_UNRESPONSIVE, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_FRAME_RENDER_EXITED, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_UTILITY_EXITED, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_SANDBOX_EXITED, _
		$NETWEBVIEW2_PROCESS_FAILED_KIND_GPU_EXITED

Global Enum _ ; Indicates the reason for the process failure.
		$NETWEBVIEW2_PROCESS_FAILED_REASON_UNEXPECTED, _
		$NETWEBVIEW2_PROCESS_FAILED_REASON_UNRESPONSIVE, _
		$NETWEBVIEW2_PROCESS_FAILED_REASON_TERMINATED, _
		$NETWEBVIEW2_PROCESS_FAILED_REASON_CRASHED, _
		$NETWEBVIEW2_PROCESS_FAILED_REASON_LAUNCH_FAILED, _
		$NETWEBVIEW2_PROCESS_FAILED_REASON_OUT_OF_MEMORY
#EndRegion ; ENUMS

#Region ; NetWebView2Lib UDF - _NetWebView2_* core functions
; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_CreateManager
; Description ...:
; Syntax ........: _NetWebView2_CreateManager([$sUserAgent = ''[, $s_fnEventPrefix = ""[, $s_AddBrowserArgs = ""]]])
; Parameters ....: $sUserAgent          - [optional] a string value. Default is ''.
;                  $s_fnEventPrefix     - [optional] a string value. Default is "".
;                  $s_AddBrowserArgs    - [optional] a string value. Default is "". Allows passing command-line switches (e.g., --disable-gpu, --mute-audio, --proxy-server="...") to the Chromium engine.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......: $s_AddBrowserArgs must be set before calling Initialize().
; Related .......:
; Link ..........: https://www.chromium.org/developers/how-tos/run-chromium-with-flags
; Link ..........: https://chromium.googlesource.com/chromium/src/+/main/docs/configuration.md#switches
; Link ..........: https://peter.sh/experiments/chromium-command-line-switches/
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_CreateManager($sUserAgent = '', $s_fnEventPrefix = "", $s_AddBrowserArgs = "")
	Local Const $s_Prefix = "[_NetWebView2_CreateManager]: fnEventPrefix=" & $s_fnEventPrefix & " AddBrowserArgs=" & $s_AddBrowserArgs
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oWebV2M = ObjCreate("NetWebView2Lib.WebView2Manager") ; REGISTERED VERSION
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Manager Creation ERROR", 1)
	If @error Then Return SetError(@error, @extended, 0)

;~ 	If $_g_bNetWebView2_DebugDev Then __NetWebView2_ObjName_FlagsValue($oWebV2M) ; FOR DEV TESTING ONLY

	If $sUserAgent Then $oWebV2M.SetUserAgent($sUserAgent)
	If $s_AddBrowserArgs Then $oWebV2M.AdditionalBrowserArguments = $s_AddBrowserArgs

	ObjEvent($oWebV2M, "__NetWebView2_Events__", "IWebViewEvents")
	If $s_fnEventPrefix Then ObjEvent($oWebV2M, $s_fnEventPrefix, "IWebViewEvents")

	Return SetError(@error, @extended, $oWebV2M)
EndFunc   ;==>_NetWebView2_CreateManager

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_Initialize
; Description ...:
; Syntax ........: _NetWebView2_Initialize($oWebV2M, $hUserGUI, $s_ProfileDirectory[, $i_Left = 0[, $i_Top = 0[, $i_Width = 0[,
;                  $i_Height = 0[, $b_SetAutoResize = True[, $b_DevToolsEnabled = True[, $i_ZoomFactor = 1.0[,
;                  $s_BackColor = "0x2B2B2B"[, $b_InitConsole = False]]]]]]]]])
; Parameters ....: $oWebV2M             - an object.
;                  $hUserGUI            - a handle to User window in which new WebView Window containng the controler should be placed/added
;                  $s_ProfileDirectory  - a string value.
;                  $i_Left              - [optional] an integer value. Default is 0.
;                  $i_Top               - [optional] an integer value. Default is 0.
;                  $i_Width             - [optional] an integer value. Default is 0.
;                  $i_Height            - [optional] an integer value. Default is 0.
;                  $b_SetAutoResize     - [optional] a boolean value. Default is True.
;                  $b_DevToolsEnabled   - [optional] a boolean value. Default is True. Allow F12 to show Developer Tools in WebView2 component
;                  $i_ZoomFactor        - [optional] an integer value. Default is 1.0.
;                  $s_BackColor         - [optional] a string value. Default is "0x2B2B2B".
;                  $b_InitConsole       - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_Initialize($oWebV2M, $hUserGUI, $s_ProfileDirectory, $i_Left = 0, $i_Top = 0, $i_Width = 0, $i_Height = 0, $b_SetAutoResize = True, $b_DevToolsEnabled = True, $i_ZoomFactor = 1.0, $s_BackColor = "0x2B2B2B", $b_InitConsole = False)

	Local Const $s_Prefix = "[_NetWebView2_Initialize]: GUI:" & $hUserGUI & " ProfileDirectory:" & $s_ProfileDirectory & " LEFT:" & $i_Left & " TOP:" & $i_Top & " WIDTH" & $i_Width & " HEIGHT:" & $i_Height & " SETAUTORESIZE:" & $b_SetAutoResize & " SetAutoResize:" & $b_DevToolsEnabled & " ZoomFactor:" & $i_ZoomFactor & " BackColor:" & $s_BackColor
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	If Not IsHWnd($hUserGUI) Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " !!! ERROR: $hUserGUI is not a valid HWND pointer.", 1)
		Return SetError($NETWEBVIEW2_MESSAGE__CRITICAL_ERROR, 0, False)
	EndIf

	; ⚠️ Important: Enclose ($hUserGUI) in parentheses to force "Pass-by-Value".
	; This prevents the COM layer from changing the AutoIt variable type from Ptr to Int64.
	Local $iInit = $oWebV2M.Initialize(($hUserGUI), $s_ProfileDirectory, $i_Left, $i_Top, $i_Width, $i_Height)
	If @error Then Return SetError(@error, @extended, $iInit)
	If $_g_bNetWebView2_DebugDev Then ConsoleWrite("! IFNC: FailureReportFolderPath = " & $oWebV2M.FailureReportFolderPath & @CRLF)

	#Region ; After Initialization wait for the engine to be ready before navigating
	Local $hTimer = TimerInit()
	Local $iTimeOut_ms = 10000 ; max 10 seconds for initialization
	Local $iMessage
	Do
		Sleep(50)
		$iMessage = __NetWebView2_LastMessage_KEEPER($oWebV2M)
		If $iMessage = $NETWEBVIEW2_MESSAGE__INIT_FAILED _
				Or $iMessage = $NETWEBVIEW2_MESSAGE__PROFILE_NOT_READY _
				Or $iMessage = $NETWEBVIEW2_MESSAGE__PROCESS_FAILED _
				Or $iMessage = $NETWEBVIEW2_MESSAGE__CRITICAL_ERROR Then
			Return SetError($iMessage, @extended, '')
		EndIf
		If TimerDiff($hTimer) >= $iTimeOut_ms Then Return SetError(1, 0, '')
	Until $oWebV2M.IsReady Or $iMessage = $NETWEBVIEW2_MESSAGE__INIT_READY
	If Not __NetWebView2_WaitForReadyState($oWebV2M, $hTimer, $iTimeOut_ms) Then Return SetError(2, 0, '')
	#EndRegion ; After Initialization wait for the engine to be ready before navigating

	; WebView2 Configuration
	$oWebV2M.SetAutoResize($b_SetAutoResize) ; Using SetAutoResize(True) to skip WM_SIZE
	$oWebV2M.AreDevToolsEnabled = $b_DevToolsEnabled ; Allow F12
	$oWebV2M.ZoomFactor = $i_ZoomFactor
	$oWebV2M.BackColor = $s_BackColor

	If $b_InitConsole Then
		$oWebV2M.AddInitializationScript(__Get_Core_Bridge_JS())
	EndIf

	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " !!! Manager Creation ERROR", 1)
	Return SetError(@error, $oWebV2M.GetBrowserProcessId(), '')
EndFunc   ;==>_NetWebView2_Initialize

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_WaitForReadyState
; Description ...: Polls the browser until the document.readyState reaches 'complete'.
; Syntax ........: __NetWebView2_WaitForReadyState($oWebV2M, $hTimer[, $iTimeOut_ms = 5000])
; Parameters ....: $oWebV2M       - The WebView2 Manager object.
;                  $hTimer        - a handle to a caller TimerInit
;                  $iTimeOut_ms   - [optional] Maximum time to wait in milliseconds. 0 for infinite. Default is 5000ms
; Return values .: Success: True
;                  Failure: False, sets @error:
;                      1 - Timeout reached before document was complete.
;                      2 - WebView2 object is not valid or ready.
; Author ........: ioa747, mLipok
; Modified.......:
; Remarks .......: This function uses JavaScript execution to check the internal state of the page.
;                  Useful for tasks like PDF printing where 'complete' state is mandatory.
; ===============================================================================================================================
Func __NetWebView2_WaitForReadyState($oWebV2M, $hTimer, $iTimeOut_ms = 5000)
	Local Const $s_Prefix = ">>>[_NetWebView2_WaitForReadyState]:"

	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(2, 0, False)
	Local $sReadyState = ""

	While 1
		; Execute JS via the Bridge (Mode 2)
		$sReadyState = _NetWebView2_ExecuteScript($oWebV2M, "document.readyState", $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)
		If @error Then Return SetError(@error, @extended, False)

		; Check for the 'complete' state
		If $sReadyState == "complete" Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " SUCCESS: Document is ready. Timeout_ms: " & Round(TimerDiff($hTimer), 0), 0)
			Return True
		EndIf

		; Check for C# Bridge internal errors (Timeout/Init)
		If StringLeft($sReadyState, 6) == "ERROR:" Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " BRIDGE " & $sReadyState & " Timeout_ms: " & Round(TimerDiff($hTimer), 0), 1)
			Return SetError(3, 0, False)
		EndIf

		; Check for AutoIt-side Timeout
		If $iTimeOut_ms > 0 And TimerDiff($hTimer) > $iTimeOut_ms Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " TIMEOUT: Document state is " & $sReadyState & " Timeout_ms: " & Round(TimerDiff($hTimer), 0), 1)
			Return SetError(1, 0, False)
		EndIf
		Sleep(50)
	WEnd
EndFunc   ;==>__NetWebView2_WaitForReadyState

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_IsRegisteredCOMObject
; Description ...: Check if all necessary object are registerd
; Syntax ........: _NetWebView2_IsRegisteredCOMObject()
; Parameters ....: None
; Return values .: True or False
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......: __NetWebView2_fake_COMErrFunc
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_IsRegisteredCOMObject()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_fake_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	ObjCreate("NetWebView2Lib.WebView2Manager")
	If @error Then Return SetError(1, 0, False)

	ObjCreate("NetWebView2Lib.WebView2Parser")
	If @error Then Return SetError(2, 0, False)

	Return True
EndFunc   ;==>_NetWebView2_IsRegisteredCOMObject

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_IsAlreadyInstalled
; Description ...: Check if MS WebView2 is installed or not
; Syntax ........: _NetWebView2_IsAlreadyInstalled()
; Parameters ....: None
; Return values .: True or False
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_IsAlreadyInstalled()
	Local $sResult, $iExtended = 0
	If @AutoItX64 Then
		$sResult = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv')
	Else
		$sResult = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv')
	EndIf
	If $sResult Then
		$iExtended = 1
	Else
		$sResult = RegRead('HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv')
		$iExtended = 2
	EndIf
	If @AutoItX64 Then $iExtended += 10
	Return SetError(($sResult = ''), $iExtended, $sResult)

#cs The two registry locations to inspect on 64-bit Windows: https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
#ce The two registry locations to inspect on 64-bit Windows: https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed

#cs The two registry locations to inspect on 32-bit Windows: https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}
#CE The two registry locations to inspect on 32-bit Windows: https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed

EndFunc   ;==>_NetWebView2_IsAlreadyInstalled

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_CleanUp
; Description ...:
; Syntax ........: _NetWebView2_CleanUp(ByRef $oWebV2M, ByRef $oJSBridge)
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $oJSBridge           - [in/out] an object.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_CleanUp(ByRef $oWebV2M, ByRef $oJSBridge)
	Local Const $s_Prefix = "[_NetWebView2_CleanUp]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " ! Object not found", 1))

	; Update Static Map to delete Handle
	__NetWebView2_LastMessage_KEEPER($oWebV2M, -1)

	Local $iRet = $oWebV2M.Cleanup()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " ! Error during internal cleanup", 1)
	$oWebV2M = 0
	$oJSBridge = 0
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)

	Return SetError(@error, @extended, $iRet)
EndFunc   ;==>_NetWebView2_CleanUp

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_ExecuteScript
; Description ...:
; Syntax ........: _NetWebView2_ExecuteScript($oWebV2M, $sJavaScript[, $iMode = 0])
; Parameters ....: $oWebV2M             - an object.
;                  $sJavaScript         - a string value.
;                  $iMode               - [optional] Default is $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET. One of the following search modes:
;                  |0 - $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET - Execute, do not wait "Fire-and-Forget"
;                  |1 - $NETWEBVIEW2_EXECUTEJS_MODE1_ASYNC - ExecuteScriptOnPage "Async-Void Trap"
;                  |2 - $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT - ExecuteScriptWithResult - This is the only method designed to return data
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......: $iMode additionall information:
; 					$NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET - ExecuteScript (Fire-and-Forget)
; 						In the C# bridge, this is defined as a public void. It uses _webView.Invoke to send the command to the UI thread and exits immediately. It does not wait for the JavaScript to execute, and it has no return type.
; 						Use case: Clicking buttons, scrolling, or triggering JS events where you don't care about the result.
; 					$NETWEBVIEW2_EXECUTEJS_MODE1_ASYNC - ExecuteScriptOnPage (Async-Void Trap)
; 						This is defined as public async void. In COM Interop (which AutoIt uses), an async void method returns control to the caller (AutoIt) the moment it hits the first internal await. The script runs in the background, but the result is never passed back to the COM interface.
; 						Use case: Fast execution where background processing is acceptable, but again, no return value.
; 					$NETWEBVIEW2_EXECUTEJS_MODE2_RESULT - ExecuteScriptWithResult
; 						This is the only method designed to return data. It implements a Message Pump (using Application.DoEvents()) to keep the interface responsive while waiting up to 5 seconds for the result.
; 						Key Features of ExecuteScriptWithResult:
; 						Blocking: It waits for the script to finish (Sync-like behavior for AutoIt).
; 						JSON Cleaning: WebView2 returns results as JSON strings (e.g., "Hello"). This method automatically strips the extra quotes and unescapes the string for you.
; 						Error Handling: Returns ERROR: Script Timeout if the JS takes longer than 5 seconds.
; Related .......:
; Link ..........: https://github.com/ioa747/NetWebView2Lib/issues/45#issuecomment-3831184514
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_ExecuteScript($oWebV2M, $sJavaScript, $iMode = $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	Local Const $s_Prefix = "[_NetWebView2_ExecuteScript]:" & " TYPE: " & $iMode
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $iRet
	Switch $iMode
		Case 0
			$iRet = $oWebV2M.ExecuteScript($sJavaScript)
		Case 1
			$iRet = $oWebV2M.ExecuteScriptOnPage($sJavaScript)
		Case 2
			$iRet = $oWebV2M.ExecuteScriptWithResult($sJavaScript)
	EndSwitch
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $iRet)
EndFunc   ;==>_NetWebView2_ExecuteScript

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetBridge
; Description ...:
; Syntax ........: _NetWebView2_GetBridge($oWebV2M[, $s_fnEventPrefix = ""])
; Parameters ....: $oWebV2M             - an object.
;                  $s_fnEventPrefix     - [optional] a string value. Default is "".
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetBridge($oWebV2M, $s_fnEventPrefix = "")
	Local Const $s_Prefix = "[_NetWebView2_GetBridge]:" & " fnEventPrefix:" & $s_fnEventPrefix
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oWebJS = $oWebV2M.GetBridge()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " : Manager.GetBridge() ERROR", 1)

	ObjEvent($oWebJS, "__NetWebView2_JSEvents__", "IBridgeEvents")
	If $s_fnEventPrefix Then ObjEvent($oWebJS, $s_fnEventPrefix, "IBridgeEvents")

	Return SetError(@error, @extended, $oWebJS)
EndFunc   ;==>_NetWebView2_GetBridge

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetVersion
; Description ...: Get NetWebView2Lib component version number
; Syntax ........: _NetWebView2_GetVersion($oWebV2M)
; Parameters ....: $oWebV2M             - an object.
; Return values .: NetWebView2Lib component version number or set @error
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetVersion($oWebV2M)
	Local Const $s_Prefix = "[_NetWebView2_GetVersion]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $sVersion = $oWebV2M.version
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " : Version=" & $sVersion, 1)
	Return SetError(@error, @extended, $sVersion)
EndFunc   ;==>_NetWebView2_GetVersion

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_LoadWait
; Description....: Waits for a specific WebView2 status or event with a timeout.
; Syntax ........: _NetWebView2_LoadWait($oWebV2M[, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED[, $sExpectedTitle = ""[,
;                  $iTimeOut_ms = 5000]]])
; Parameters.....: $oWebV2M             - The NetWebView2 Manager object.
;                  $iWaitMessage        - The status code to wait for (Default is $NETWEBVIEW2_MESSAGE__TITLE_CHANGED).
;                  $sExpectedTitle      - [optional] Expected title to LoadWait for, as StringRegExp() pattern
;                  $iTimeOut_ms         - [optional] Maximum time to wait in milliseconds. 0 for infinite. Default is 5000ms
; Return values..: Success      - True
;                  Failure      - False and sets @error:
;                                     3 - Navigation Error ($NETWEBVIEW2_MESSAGE__NAV_ERROR)
;                                     4 - Timeout reached
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......: This function uses a centralized state machine to track asynchronous events.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_LoadWait($oWebV2M, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle = "", $iTimeOut_ms = 5000)
	Local Const $s_Prefix = '[_NetWebView2_LoadWait]: WaitMessage:' & $iWaitMessage & ' WAIT:' & $iWaitMessage & ' ExpectedTitle="' & $sExpectedTitle & '" TimeOut_ms=' & $iTimeOut_ms
	Local $hTimer = TimerInit()

	; RESET: Clear the status of this instance before starting the wait loop
	__NetWebView2_LastMessage_Navigation($oWebV2M, $NETWEBVIEW2_MESSAGE__NONE)

	While 1
		; Allow AutoIt to "breathe" and process the GUI messages
		Sleep(10)

		; RULE 1: If we reached the target status or higher
		Local $bWebIsReady = $oWebV2M.IsReady
		If @error Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
			Return SetError(1, 0, False) ; browser/COM error ?
		EndIf

		; RULE 2: TimeOut Check
		If $iTimeOut_ms And TimerDiff($hTimer) >= $iTimeOut_ms Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " - TIME OUT - the waiting time has expired", 1)
			Return SetError(2, 0, False)
		EndIf

		; RULE 3: if browser is not ready continue waiting
		If Not $bWebIsReady Then ContinueLoop ; For navigation events, ensure the browser reports IsReady

		; RULE 4: checking browser ReadyState
		Local $iLastMessage = -1
		Local $sReadyState = _NetWebView2_ExecuteScript($oWebV2M, "document.readyState", $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)
		If @error Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
			Return SetError(7, 0, False)
		ElseIf StringLeft($sReadyState, 6) == "ERROR:" Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
			Return SetError(8, 0, False)
		ElseIf $sReadyState = "complete" Then
			; RULE 5: checking events messages
			$iLastMessage = __NetWebView2_LastMessage_Navigation($oWebV2M)
			If $_g_bNetWebView2_DebugDev Then ConsoleWrite('! IFNC: TEST LOAD WAIT: ReadyState=' & $sReadyState & ' LastMessage=' & $iLastMessage & ' WaitMessage=' & $iWaitMessage & ' SLN=' & @ScriptLineNumber & @CRLF)
			If $iLastMessage = $NETWEBVIEW2_MESSAGE__NAV_ERROR Or $iLastMessage = $NETWEBVIEW2_MESSAGE__PROCESS_FAILED Or $iLastMessage = $NETWEBVIEW2_MESSAGE__CRITICAL_ERROR Then
				If $_g_bNetWebView2_DebugDev Then ConsoleWrite('! IFNC: TEST LOAD WAIT: ' & $iLastMessage & ' SLN=' & @ScriptLineNumber & @CRLF)
				__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
				Return SetError(3, $iLastMessage, False)
;~ 			ElseIf $iLastMessage >= $iWaitMessage Then ; checking events
			ElseIf $iLastMessage >= $iWaitMessage Then ; checking events
				; RULE 6: checking document title
				Local $sCurrentTitle = $oWebV2M.GetDocumentTitle()
				Local $bTitleCheck = ($sExpectedTitle And StringRegExp($sCurrentTitle, $sExpectedTitle, $STR_REGEXPMATCH) = 1)
				Local $s_MessageInfo = '! IFNC: TEST LOAD WAIT: CurrentTitle="' & $sCurrentTitle & '" ExpectedTitle"' & $sExpectedTitle & '" TitleCheck=' & $bTitleCheck & ' LastMessage=' & $iLastMessage
				If $sExpectedTitle And $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED And $bTitleCheck Then
					If $_g_bNetWebView2_DebugDev Then ConsoleWrite($s_MessageInfo & ' SLN=' & @ScriptLineNumber & @CRLF)
					__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " LastMessage=" & $iLastMessage, 1)
					Return True
				Else
					If $_g_bNetWebView2_DebugDev Then ConsoleWrite($s_MessageInfo & ' SLN=' & @ScriptLineNumber & @CRLF)
					__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " LastMessage=" & $iLastMessage, 1)
					Return True
				EndIf
			EndIf
		EndIf
		If $_g_bNetWebView2_DebugDev Then ConsoleWrite("> IFNC: TEST LOAD WAIT: __NetWebView2_LastMessage_Navigation($oWebV2M)=" & $iLastMessage & ' >> ' & __NetWebView2_LastMessage_Navigation($oWebV2M) & ' SLN=' & @ScriptLineNumber & @CRLF)
	WEnd
EndFunc   ;==>_NetWebView2_LoadWait

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_Navigate
; Description....: Navigates to a URL and waits for a specific completion status.
; Syntax ........: _NetWebView2_Navigate($oWebV2M, $s_URL[, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED[,
;                  $sExpectedTitle = ""[, $iTimeOut_ms = 5000]]])
; Parameters.....: $oWebV2M             - The NetWebView2 Manager object.
;                  $s_URL               - The URL to navigate to.
;                  $iWaitMessage        - The status code to wait for (Default is $NETWEBVIEW2_MESSAGE__TITLE_CHANGED).
;                  $sExpectedTitle      - [optional] Expected title to LoadWait for, as StringRegExp() pattern
;                  $iTimeOut_ms         - [optional] Maximum time to wait in milliseconds. 0 for infinite. Default is 5000ms
; Return values..: Success       - True
;                  Failure       - False and sets @error:
;                                      1 - Invalid parameters
;                                      2 - Navigation call failed (COM error)
;                                      3 - Navigation Error status received
;                                      4 - Timeout reached
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_Navigate($oWebV2M, $s_URL, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle = "", $iTimeOut_ms = 5000)
	Local Const $s_Prefix = "[_NetWebView2_Navigate]: URL:" & $s_URL & " WAIT:" & $iWaitMessage & " TimeOut_ms=" & $iTimeOut_ms
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	; 1. Parameter Validation
	If $iWaitMessage < $NETWEBVIEW2_MESSAGE__INIT_READY Or $iWaitMessage > $NETWEBVIEW2_MESSAGE__TITLE_CHANGED Then ; higher messsages are not for NAVIGATION thus not checking in _NetWebView2_LoadWait()
		Return SetError(1, 0, False)
	EndIf

	; 2. Execute Navigation
	; The Local Error Handler catches potential "Disposed Object" crashes here
	$oWebV2M.Navigate($s_URL)
	If @error Then Return SetError(2, @error, False)

	; 3. Wait for status using the Bulletproof LoadWait logic
	Local $bResult = _NetWebView2_LoadWait($oWebV2M, $iWaitMessage, $sExpectedTitle, $iTimeOut_ms)
	Local $iErr = @error, $iExt = @extended

	; If an error occurred (3: Nav Error, 4: Timeout), log the failure
	If @error Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " -> LOAD WAIT FAILED (Err:" & $iErr & " Ext:" & $iExt & ")", 1)
	EndIf

	Return SetError($iErr, $iExt, $bResult)
EndFunc   ;==>_NetWebView2_Navigate

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_NavigateToString
; Description ...:
; Syntax ........: _NetWebView2_NavigateToString($oWebV2M, $s_HTML[, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED[,
;                  $sExpectedTitle = ""[, $iTimeOut_ms = 5000]]])
; Parameters ....: $oWebV2M             - an object.
;                  $s_HTML              - a string value.
;                  $iWaitMessage        - [optional] an integer value. Default is $NETWEBVIEW2_MESSAGE__TITLE_CHANGED.
;                  $sExpectedTitle      - [optional] Expected title to LoadWait for, as StringRegExp() pattern
;                  $iTimeOut_ms         - [optional] Maximum time to wait in milliseconds. 0 for infinite. Default is 5000ms
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_NavigateToString($oWebV2M, $s_HTML, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle = "", $iTimeOut_ms = 5000)
	Local Const $s_Prefix = "[_NetWebView2_NavigateToString]:" & " HTML Size:" & StringLen($s_HTML) & " WaitMessage:" & $iWaitMessage & " TimeOut_ms=" & $iTimeOut_ms
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	If $iWaitMessage < $NETWEBVIEW2_MESSAGE__INIT_READY Then
		Return SetError(1)
	ElseIf $iWaitMessage > $NETWEBVIEW2_MESSAGE__TITLE_CHANGED Then ; higher messsages are not for NAVIGATION thus not checking in _NetWebView2_LoadWait()
		Return SetError(2)
	Else
		Local $iNavigation = $oWebV2M.NavigateToString($s_HTML)
		If @error Then Return SetError(@error, @extended, $iNavigation)

		_NetWebView2_LoadWait($oWebV2M, $iWaitMessage, $sExpectedTitle, $iTimeOut_ms)
		If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
		Return SetError(@error, @extended, '')
	EndIf
EndFunc   ;==>_NetWebView2_NavigateToString

#EndRegion ; NetWebView2Lib UDF - _NetWebView2_* core functions

#Region ; NetWebView2Lib UDF - _NetWebView2_* helper functions
; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_BrowserSetupWrapper
; Description ...:
; Syntax ........: _NetWebView2_BrowserSetupWrapper($hOuterParentWindow, ByRef $oOuterWeb, $sEventPrefix, $sProfile,
;                  ByRef $oOuterBridge, ByRef $hInnerWebViewWindow, $iX, $iY, $iW, $iH, $s_AddBrowserArgs)
; Parameters ....: $hOuterParentWindow  - a handle value.
;                  $oOuterWeb           - [in/out] an object.
;                  $sEventPrefix        - a string value.
;                  $sProfile            - a string value.
;                  $oOuterBridge        - [in/out] an object.
;                  $hInnerWebViewWindow - [in/out] a handle value.
;                  $iX                  - an integer value.
;                  $iY                  - an integer value.
;                  $iW                  - an integer value.
;                  $iH                  - an integer value.
;                  $s_AddBrowserArgs    - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_BrowserSetupWrapper($hOuterParentWindow, ByRef $oOuterWeb, $sEventPrefix, $sProfile, ByRef $oOuterBridge, ByRef $hInnerWebViewWindow, $iX, $iY, $iW, $iH, $s_AddBrowserArgs)
	$hInnerWebViewWindow = GUICreate("", $iW, $iH, $iX, $iY, $WS_CHILD, -1, $hOuterParentWindow)
	GUISetState(@SW_SHOW, $hInnerWebViewWindow)

	$oOuterWeb = _NetWebView2_CreateManager("", $sEventPrefix & '_Manager__', $s_AddBrowserArgs)
	If @error Then Return SetError(@error, @extended, $oOuterWeb)

	Local $Result = _NetWebView2_Initialize($oOuterWeb, $hInnerWebViewWindow, $sProfile, 0, 0, $iW, $iH)
	If @error Then Return SetError(@error, @extended, $Result)

	$oOuterBridge = _NetWebView2_GetBridge($oOuterWeb, $sEventPrefix & "_Bridge__")
	If @error Then Return SetError(@error, @extended, $oOuterBridge)
EndFunc   ;==>_NetWebView2_BrowserSetupWrapper

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_ExportPageData
; Description ...:
; Syntax ........: _NetWebView2_ExportPageData($oWebV2M, $iFormat[, $sFilePath = ''])
; Parameters ....: $oWebV2M             - an object.
;                  $iFormat             - a string value. 0 HTML only, 1 MHTML Snapshot
;                  $sFilePath           - [optional] a string value. Default is '' which mean make Base64 as a result instead write to file
; Return values .: Success      - Depends on $sFilePath String with Base64 encoded binary content of the PDF or "SUCCESS: File saved to ...."
;                  Failure      - string with error description "ERROR: ........." and set @error to 1
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_ExportPageData($oWebV2M, $iFormat, $sFilePath = '')
	Local Const $s_Prefix = "[_NetWebView2_ExportPageData]:" & " Format:" & $iFormat & " FilePath:" & (($sFilePath) ? ($sFilePath) : ('"EMPTY"'))
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
	#TODO $sParameters - search for  => "name": "captureSnapshot" ; https://github.com/ChromeDevTools/devtools-protocol/blob/master/json/browser_protocol.json

	Local $s_Result = $oWebV2M.ExportPageData($iFormat, $sFilePath)
	If StringLeft($s_Result, 6) = 'ERROR:' Then SetError(1)
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " RESULT:" & ((@error) ? ($s_Result) : ("SUCCESS")), 1)
	Return SetError(@error, @extended, $s_Result)
EndFunc   ;==>_NetWebView2_ExportPageData

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetSource
; Description ...:
; Syntax ........: _NetWebView2_GetSource($oWebV2M)
; Parameters ....: $oWebV2M             - an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetSource($oWebV2M)
	Local Const $s_Prefix = "[_NetWebView2_GetSource]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $sSource = $oWebV2M.GetSource()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $sSource)
EndFunc   ;==>_NetWebView2_GetSource

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_NavigateToPDF
; Description ...: Navigate to a PDF (local PDF file or online direct URL link to PDF file)
; Syntax ........: _NetWebView2_NavigateToPDF($oWebV2M, $s_URL_or_FileFullPath[, $s_Parameters = ''[, $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED[,
;                  $sExpectedTitle = ""[, $iTimeOut_ms = 5000[, $iSleep_ms = 1000[, $bFreeze = True]]]]]])
; Parameters ....: $oWebV2M             - an object.
;                  $s_URL_or_FileFullPath- a string value.
;                  $s_Parameters        - [optional] a string value. Default is ''.
;                  $iWaitMessage        - [optional] an integer value. Default is $NETWEBVIEW2_MESSAGE__TITLE_CHANGED.
;                  $sExpectedTitle      - [optional] Expected title to LoadWait for, as StringRegExp() pattern
;                  $iTimeOut_ms         - [optional] Maximum time to wait in milliseconds. 0 for infinite. Default is 5000ms
;                  $iSleep_ms           - [optional] an integer value. Default is 1000.
;                  $bFreeze             - [optional] a boolean value. Default is True.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_NavigateToPDF($oWebV2M, $s_URL_or_FileFullPath, Const $s_Parameters = '', $iWaitMessage = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle = "", $iTimeOut_ms = 5000, Const $iSleep_ms = 1000, Const $bFreeze = True)
	Local Const $s_Prefix = "[_NetWebView2_NavigateToPDF]: URL_or_File:" & $s_URL_or_FileFullPath ; #TODO suplement

	If FileExists($s_URL_or_FileFullPath) Then
		$s_URL_or_FileFullPath = StringReplace($s_URL_or_FileFullPath, '\', '/')
		$s_URL_or_FileFullPath = StringReplace($s_URL_or_FileFullPath, ' ', '%20')
		$s_URL_or_FileFullPath = "file:///" & $s_URL_or_FileFullPath
	EndIf

	If $s_Parameters Then
		$s_URL_or_FileFullPath &= $s_Parameters
		#TIP: FitToPage: https://stackoverflow.com/questions/78820187/how-to-change-webview2-fit-to-page-button-on-pdf-toolbar-default-to-fit-to-width#comment138971950_78821231
		#TIP: Open desired PAGE: https://stackoverflow.com/questions/68500164/cycle-pdf-pages-in-wpf-webview2#comment135402565_68566860
	EndIf

	Local $idPic = 0
	If $bFreeze Then __NetWebView2_freezer($oWebV2M, $idPic)
	_NetWebView2_Navigate($oWebV2M, $s_URL_or_FileFullPath, $iWaitMessage, $sExpectedTitle, $iTimeOut_ms)
	If Not @error Then Sleep($iSleep_ms)
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	If $bFreeze And $idPic Then __NetWebView2_freezer($oWebV2M, $idPic)
EndFunc   ;==>_NetWebView2_NavigateToPDF

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_PrintToPdfStream
; Description ...: Print web content to PDF
; Syntax ........: _NetWebView2_PrintToPdfStream($oWebV2M, $b_TBinary_FBase64)
; Parameters ....: $oWebV2M             - an object.
;                  $b_TBinary_FBase64   - a boolean value.
; Return values .: Success      - binary or string with Base64 encoded binary content of the PDF
;                  Failure      - string with error description "ERROR: ........." and set @error to 1
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_PrintToPdfStream($oWebV2M, $b_TBinary_FBase64)
	Local Const $s_Prefix = "[_NetWebView2_PrintToPdfStream]: TBinary_FBase64:" & $b_TBinary_FBase64
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $s_Result = $oWebV2M.PrintToPdfStream()
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	If StringInStr($s_Result, 'ERROR:') Then SetError(1)

	If $b_TBinary_FBase64 Then
		; decode Base64 encoded data do Binary
		$s_Result = _NetWebView2_DecodeB64ToBinary($oWebV2M, $s_Result)
	EndIf

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " RESULT:" & ((@error) ? ($s_Result) : ("SUCCESS")), 1)
	Return SetError(@error, @extended, $s_Result)
EndFunc   ;==>_NetWebView2_PrintToPdfStream

#EndRegion ; NetWebView2Lib UDF - _NetWebView2_* helper functions

#Region ; New Core Method Wrappers
; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_AddInitializationScript
; Description ...: Adds a JavaScript to be executed before any other script when a new page is loaded.
; Syntax.........: _NetWebView2_AddInitializationScript($oWeb, $sScript)
; Parameters ....: $oWeb    - The NetWebView2 Manager object.
;                  $vScript - The JavaScript code to inject (String) OR the full path to a JavaScript file.
; Return values .: Success  - Returns a Script ID (string).
;                  Failure  - Returns the error message and sets @error.
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......: _NetWebView2_RemoveInitializationScript
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_AddInitializationScript($oWebV2M, $vScript)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, "ERROR: Invalid Object")

	; Smart Detection
	If FileExists($vScript) Then $vScript = FileRead($vScript)

	Local $sScriptId = $oWebV2M.AddInitializationScript($vScript)
	If StringInStr($sScriptId, "ERROR:") Then Return SetError(2, 0, $sScriptId)
	Return SetError(0, 0, $sScriptId)
EndFunc   ;==>_NetWebView2_AddInitializationScript

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_RemoveInitializationScript
; Description....: Removes a previously added initialization script using its ID.
; Syntax.........: _NetWebView2_RemoveInitializationScript($oWebV2M, $sScriptId)
; Parameters.....: $oWebV2M - The Net WebView2 instance to manipulate.
;                  $sScriptId     - The ID of the initialization script to remove.
; Return values .: Success   - True
;                  Failure   - False and sets @error
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......: _NetWebView2_AddInitializationScript
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_RemoveInitializationScript($oWebV2M, $sScriptId)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, False) ; Error 1: Not an object
	$oWebV2M.RemoveInitializationScript($sScriptId)
	Return SetError(@error, 0, (@error ? False : True))
EndFunc   ;==>_NetWebView2_RemoveInitializationScript

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_SetVirtualHostNameToFolderMapping
; Description ...: Maps a custom host name to a local folder path (bypasses CORS).
; Syntax.........: _NetWebView2_SetVirtualHostNameToFolderMapping($oWebV2M, $sHostName, $sFolderPath[, $iAccessKind = 0])
; Parameters ....: $oWebV2M     - The NetWebView2 Manager object.
;                  $sHostName   - The virtual domain (e.g., "myapp.local").
;                  $sFolderPath - The absolute path to the local folder.
;                  $iAccessKind - 0: Allow, 1: Deny, 2: Allow (Cross-Origin restricted).
; Return values .: Success      - True
;                  Failure      - False and sets @error
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_SetVirtualHostNameToFolderMapping($oWebV2M, $sHostName, $sFolderPath, $iAccessKind = 0)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, False)
	$oWebV2M.SetVirtualHostNameToFolderMapping($sHostName, $sFolderPath, $iAccessKind)
	Return SetError(@error, 0, (@error ? False : True))
EndFunc   ;==>_NetWebView2_SetVirtualHostNameToFolderMapping

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_SetLockState
; Description ...: Locks or unlocks the manager to prevent COM calls during critical operations (e.g., Cleanup).
; Syntax.........: _NetWebView2_SetLockState($oWebV2M, $bLockState)
; Parameters ....: $oWebV2M    - The NetWebView2 Manager object.
;                  $bLockState - True to lock (prevent calls), False to unlock.
; Return values .: Success     - True
;                  Failure     - False and sets @error
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_SetLockState($oWebV2M, $bLockState)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, False)
	$oWebV2M.SetLockState($bLockState)
	Return SetError(@error, 0, (@error ? False : True))
EndFunc   ;==>_NetWebView2_SetLockState

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_EncodeBinaryToB64
; Description ...: High-performance binary to Base64 string encoding using the C# Core.
; Syntax.........: _NetWebView2_EncodeBinaryToB64($oWebV2M, ByRef $dBinary)
; Parameters ....: $oWebV2M - The NetWebView2 Manager object.
;                  $dBinary - The binary data to encode.
; Return values .: Success  - Returns a Base64 encoded string.
;                  Failure  - Returns an empty string and sets @error.
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......: _NetWebView2_DecodeB64ToBinary
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_EncodeBinaryToB64($oWebV2M, ByRef $dBinary)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, "")
	Local $sResult = $oWebV2M.EncodeBinaryToB64($dBinary)
	If @error Then Return SetError(@error, 0, "")
	Return SetError(0, 0, $sResult)
EndFunc   ;==>_NetWebView2_EncodeBinaryToB64

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_DecodeB64ToBinary
; Description ...: High-performance Base64 string to binary data decoding using the C# Core.
; Syntax.........: _NetWebView2_DecodeB64ToBinary($oWebV2M, ByRef $sB64)
; Parameters ....: $oWebV2M - The NetWebView2 Manager object.
;                  $sB64    - The Base64 encoded string to decode.
; Return values .: Success  - Returns binary data.
;                  Failure  - Returns empty binary and sets @error.
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......: _NetWebView2_EncodeBinaryToB64
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_DecodeB64ToBinary($oWebV2M, ByRef $sB64)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, Binary(""))
	Local $dResult = $oWebV2M.DecodeB64ToBinary($sB64)
	If @error Then Return SetError(@error, 0, Binary(""))
	Return SetError(0, 0, $dResult)
EndFunc   ;==>_NetWebView2_DecodeB64ToBinary

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_SetBuiltInErrorPageEnabled
; Description ...: Enables or disables the built-in WebView2 error pages (e.g., "No Internet").
; Syntax.........: _NetWebView2_SetBuiltInErrorPageEnabled($oWeb, $bEnabled)
; Parameters ....: $oWeb     - The NetWebView2 Manager object.
;                  $bEnabled - True to show default error pages, False to hide them.
; Return values .: Success   - True
;                  Failure   - False and sets @error
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......: _NetWebView2_EncodeBinaryToB64
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_SetBuiltInErrorPageEnabled($oWebV2M, $bEnabled)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2Lib.WebView2Manager' Then Return SetError(1, 0, False)
	$oWebV2M.IsBuiltInErrorPageEnabled = $bEnabled
	Return SetError(@error, 0, (@error ? False : True))
EndFunc   ;==>_NetWebView2_SetBuiltInErrorPageEnabled


; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_SilentErrorHandler
; Description....: A generic COM Error Handler that silences errors.
; Syntax.........: _NetWebView2_SilentErrorHandler()
; Remarks........: Used to prevent script crashes when a WebView2 object is disposed or closed
;                  while an event or a method call is still in progress.
; Author ........: ioa747, mLipok
; ===============================================================================================================================
Volatile Func _NetWebView2_SilentErrorHandler($oError)
	#forceref $oError
	; We do nothing, effectively "swallowing" the COM error.
	; This prevents the "Object Disposed" fatal crash.
	$oError = 0 ; Explicitly release the COM reference inside the volatile scopeEndFunc
EndFunc   ;==>_NetWebView2_SilentErrorHandler

#EndRegion ; New Core Method Wrappers

#Region ; NetWebView2Lib UDF - _NetJson_* functions
; #FUNCTION# ====================================================================================================================
; Name ..........: _NetJson_CreateParser
; Description ...:
; Syntax ........: _NetJson_CreateParser([$sInitialJson = "{}"])
; Parameters ....: $sInitialJson        - [optional] a string value. Default is "{}".
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetJson_CreateParser($sInitialJson = "{}")
	Local Const $s_Prefix = "[_NetJson_CreateParser]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	If $sInitialJson = "" Or $sInitialJson = Default Then $sInitialJson = "{}"
	Local $oParser = ObjCreate("NetWebView2Lib.WebView2Parser") ; REGISTERED VERSION
;~ 	If $_g_bNetWebView2_DebugDev Then __NetWebView2_ObjName_FlagsValue($oParser) ; FOR DEV TESTING ONLY
	If Not IsObj($oParser) Then Return SetError(1, 0, 0)
	If @error Then Return SetError(@error, @extended, 0)

	$oParser.Parse($sInitialJson)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return $oParser
EndFunc   ;==>_NetJson_CreateParser

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetJson_DecodeB64
; Description ...:
; Syntax ........: _NetJson_DecodeB64($sData)
; Parameters ....: $sData               - a string value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetJson_DecodeB64($sData)
	Local Const $s_Prefix = "[_NetJson_DecodeB64]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oJSON = _NetJson_CreateParser()
	If @error Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
		Return SetError(@error, @extended, $oJSON)
	EndIf

	Local $dBinary = $oJSON.Decode64($sData)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $dBinary)
EndFunc   ;==>_NetJson_DecodeB64

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetJson_EncodeB64
; Description ...:
; Syntax ........: _NetJson_EncodeB64($sData)
; Parameters ....: $sData               - a string value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetJson_EncodeB64($sData)
	Local Const $s_Prefix = "[_NetJson_EncodeB64]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oJSON = _NetJson_CreateParser()
	If @error Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
		Return SetError(@error, @extended, $oJSON)
	EndIf

	Local $vResult = $oJSON.EncodeB64($sData)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $vResult)
EndFunc   ;==>_NetJson_EncodeB64
#EndRegion ; NetWebView2Lib UDF - _NetJson_* functions

#Region ; NetWebView2Lib UDF - #INTERNAL_USE_ONLY#
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetWebView2_LastMessage_KEEPER
; Description....: Centralized state manager for WebView2 instances using a static map.
; Syntax ........: __NetWebView2_LastMessage_KEEPER($oWebV2M[, $iMessage = Default[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $oWebV2M             - The NetWebView2 Manager object.
;                  $iMessage            - [optional] Message to SET. If Default, function acts as GET. If -1, performs cleanup.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Author.........: mLipok, ioa747
; Modified ......:
; Remarks........: Uses a Local COM Error Handler to silently handle "Disposed Object" errors during shutdown.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_LastMessage_KEEPER($oWebV2M, $iMessage = Default, $iError = @error, $iExtended = @extended)
	; Static Map - The central database of status indexed by Window Handle
	; Local COM Error Handler to trap 0x80020009 (Disposed Object) during closure
	Local $oMyError = ObjEvent("AutoIt.Error", _NetWebView2_SilentErrorHandler)
	#forceref $oMyError

	Local Static $mLastMessegKeeper[]
	Local $sKey = "" & $oWebV2M.BrowserWindowHandle
	If $iMessage <> Default Then
		__NetWebView2_LastMessage__INTERNALL($mLastMessegKeeper, $sKey, $iMessage, $iError = @error, $iExtended = @extended)

		__NetWebView2_LastMessage_onReceived($oWebV2M, $iMessage)
		__NetWebView2_LastMessage_Navigation($oWebV2M, $iMessage)
		Return SetError($iError, $iExtended)
	Else
		Return SetError($iError, $iExtended, $mLastMessegKeeper[$sKey])
	EndIf

EndFunc   ;==>__NetWebView2_LastMessage_KEEPER

Func __NetWebView2_LastMessage_onReceived($oWebV2M, $iMessage = Default, $iError = @error, $iExtended = @extended)
	; Static Map - The central database of status indexed by Window Handle
	; Local COM Error Handler to trap 0x80020009 (Disposed Object) during closure
	Local $oMyError = ObjEvent("AutoIt.Error", _NetWebView2_SilentErrorHandler)
	#forceref $oMyError

	Local Static $mLastMessegReceived[]
	Local $sKey = "" & $oWebV2M.BrowserWindowHandle

	If $iMessage <> Default Then
		If $_g_bNetWebView2_DebugDev Then ConsoleWrite('! IFNC: __NetWebView2_LastMessage_onReceived ==> ' & $iMessage & ' Key=' & $sKey & ' SLN=' & @ScriptLineNumber & @CRLF)
		__NetWebView2_LastMessage__INTERNALL($mLastMessegReceived, $sKey, $iMessage, $iError = @error, $iExtended = @extended)
	EndIf

	Return SetError($iError, $iExtended, $mLastMessegReceived[$sKey])
EndFunc   ;==>__NetWebView2_LastMessage_onReceived

Func __NetWebView2_LastMessage_Navigation($oWebV2M, $iMessage = Default, $iError = @error, $iExtended = @extended)
	; Static Map - The central database of status indexed by Window Handle
	; Local COM Error Handler to trap 0x80020009 (Disposed Object) during closure
	Local $oMyError = ObjEvent("AutoIt.Error", _NetWebView2_SilentErrorHandler)
	#forceref $oMyError

	Local Static $mLastNavigationMessage[]
	Local $sKey = "" & $oWebV2M.BrowserWindowHandle
	If $iMessage <> Default Then
		If $iMessage >= $NETWEBVIEW2_MESSAGE__NAV_STARTING And $iMessage <= $NETWEBVIEW2_MESSAGE__TITLE_CHANGED Then
			If $_g_bNetWebView2_DebugDev Then ConsoleWrite('! IFNC: __NetWebView2_LastMessage_Navigation ==> ' & $iMessage & ' Key=' & $sKey & ' SLN=' & @ScriptLineNumber & @CRLF)
			__NetWebView2_LastMessage__INTERNALL($mLastNavigationMessage, $sKey, $iMessage, $iError = @error, $iExtended = @extended)
		EndIf
	EndIf
	Return SetError($iError, $iExtended, $mLastNavigationMessage[$sKey])
EndFunc   ;==>__NetWebView2_LastMessage_Navigation

Func __NetWebView2_LastMessage__INTERNALL(ByRef $mStatus, $sKey, $iMessage = Default, $iError = @error, $iExtended = @extended)

	; If an error occurred while retrieving the Handle (e.g. Object already closed)
	If @error Then Return SetError($iError, $iExtended, $NETWEBVIEW2_MESSAGE__NONE)

	; If the handle is invalid
	If $sKey = "0" Or $sKey = "" Then Return SetError($iError, $iExtended, $NETWEBVIEW2_MESSAGE__NONE)

	; --- SET MODE (Called from Events or Cleanup) ---
	If $iMessage <> Default Then
		; Special case: -1 for memory cleanup when the instance is closed
		If $iMessage = -1 Then
			If MapExists($mStatus, $sKey) Then MapRemove($mStatus, $sKey)
			Return SetError($iError, $iExtended, $NETWEBVIEW2_MESSAGE__NONE)
		EndIf

		; Update the status for this specific Handle
		$mStatus[$sKey] = $iMessage
		Return SetError($iError, $iExtended, $iMessage)
	EndIf

	; --- GET MODE (Called from LoadWait) ---
	If Not MapExists($mStatus, $sKey) Then Return SetError($iError, $iExtended, $NETWEBVIEW2_MESSAGE__NONE)

	Return SetError($iError, $iExtended, $mStatus[$sKey])
EndFunc   ;==>__NetWebView2_LastMessage__INTERNALL

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Log
; Description ...: Debug Write utility
; Syntax ........: __NetWebView2_Log($s_ScriptLineNumber, $sString[, $iErrorNoLineNo = 1[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $s_ScriptLineNumber  - a string value.
;                  $sString             - a string value.
;                  $iErrorNoLineNo      - [optional] an integer value. Default is 1.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_Log($s_ScriptLineNumber, $sString, $iErrorNoLineNo = 1, $iError = @error, $iExtended = @extended)
	If Not $_g_bNetWebView2_DebugInfo Then Return SetError($iError, $iExtended, 0)
	If $iErrorNoLineNo = 1 Then
		If $iError Then
			$sString = "! ( NetWebView2Lib UDF : SLN=" & $s_ScriptLineNumber & ", @error=" & $iError & ", @extended=" & $iExtended & " ) :: " & $sString
		Else
			$sString = "+> ( NetWebView2Lib UDF : SLN=" & $s_ScriptLineNumber & " ) :: " & $sString
		EndIf
	EndIf
	Local $iReturn = ConsoleWrite($sString & @CRLF)
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__NetWebView2_Log

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_ObjName_FlagsValue
; Description ...:
; Syntax ........: __NetWebView2_ObjName_FlagsValue($oObj)
; Parameters ....: $oObj                - an object.
; Return values .: None
; Author ........: AutoIt HelpFile ObjName Example 2
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_ObjName_FlagsValue($oObj)
	Local $sInfo = ''
	$sInfo &= '+>' & @TAB & 'ObjName($oObj,1) {The name of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_NAME) & @CRLF

	; HELPFILE REMARKS: Not all Objects support flags 2 to 7. Always test for @error in these cases.
	$sInfo &= '+>' & @TAB & 'ObjName($oObj,2) {Description string of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_STRING)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,3) {The ProgID of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_PROGID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,4) {The file that is associated with the object in the Registry} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_FILE)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,5) {Module name in which the object runs (WIN XP And above). Marshaller for non-inproc objects.} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_MODULE)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,6) {CLSID of the object''s coclass} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_CLSID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,7) {IID of the object''s interface} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_IID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	ConsoleWrite($sInfo & @CRLF)
EndFunc   ;==>__NetWebView2_ObjName_FlagsValue

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Get_Core_Bridge_JS
; Description ...: Get JavaScript for Bridge
; Syntax ........: __Get_Core_Bridge_JS()
; Parameters ....: None
; Return values .: JavaScript for Bridge
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Get_Core_Bridge_JS()
	Local $sJS = _
			"/**" & @CRLF & _
			" * NetWebView2Lib Core Bridge" & @CRLF & _
			" * Handles Console Hijacking and Global Error Reporting" & @CRLF & _
			" */" & @CRLF & _
			"" & @CRLF & _
			"(function() {" & @CRLF & _
			"    // 1. Configuration & State" & @CRLF & _
			"    window.NET_BRIDGE_ENABLED = true;" & @CRLF & _
			"" & @CRLF & _
			"    /**" & @CRLF & _
			"     * Centralized message dispatcher to AutoIt" & @CRLF & _
			"     */" & @CRLF & _
			"    const dispatchToAutoIt = (data) => {" & @CRLF & _
			"        try {" & @CRLF & _
			"            if (window.chrome && window.chrome.webview) {" & @CRLF & _
			"                window.chrome.webview.postMessage(JSON.stringify(data));" & @CRLF & _
			"            }" & @CRLF & _
			"        } catch (e) {" & @CRLF & _
			"            // Silent fail if bridge is not fully ready" & @CRLF & _
			"        }" & @CRLF & _
			"    };" & @CRLF & _
			"" & @CRLF & _
			"    /**" & @CRLF & _
			"     * Console Hijacking Logic" & @CRLF & _
			"     */" & @CRLF & _
			"    const originalConsole = {" & @CRLF & _
			"        log: console.log," & @CRLF & _
			"        error: console.error," & @CRLF & _
			"        warn: console.warn," & @CRLF & _
			"        info: console.info" & @CRLF & _
			"    };" & @CRLF & _
			"" & @CRLF & _
			"    const createWrappedConsole = (type) => {" & @CRLF & _
			"        return function() {" & @CRLF & _
			"            // Send to AutoIt" & @CRLF & _
			"            dispatchToAutoIt({" & @CRLF & _
			"                type: ""CONSOLE_LOG""," & @CRLF & _
			"                level: type.toUpperCase()," & @CRLF & _
			"                message: Array.from(arguments).map(arg => " & @CRLF & _
			"                    (typeof arg === 'object') ? JSON.stringify(arg) : String(arg)" & @CRLF & _
			"                ).join(' ')," & @CRLF & _
			"                timestamp: new Date().toISOString()" & @CRLF & _
			"            });" & @CRLF & _
			"            // Keep original browser behavior" & @CRLF & _
			"            originalConsole[type].apply(console, arguments);" & @CRLF & _
			"        };" & @CRLF & _
			"    };" & @CRLF & _
			"" & @CRLF & _
			"    // Replace standard console methods" & @CRLF & _
			"    console.log = createWrappedConsole('log');" & @CRLF & _
			"    console.error = createWrappedConsole('error');" & @CRLF & _
			"    console.warn = createWrappedConsole('warn');" & @CRLF & _
			"    console.info = createWrappedConsole('info');" & @CRLF & _
			"" & @CRLF & _
			"    /**" & @CRLF & _
			"     * 2. Global Runtime Error Handler" & @CRLF & _
			"     */" & @CRLF & _
			"    window.onerror = function(message, source, lineno, colno, error) {" & @CRLF & _
			"        dispatchToAutoIt({" & @CRLF & _
			"            type: ""JS_ERROR""," & @CRLF & _
			"            message: message," & @CRLF & _
			"            source: source," & @CRLF & _
			"            line: lineno," & @CRLF & _
			"            column: colno," & @CRLF & _
			"            stack: error ? error.stack : """"" & @CRLF & _
			"        });" & @CRLF & _
			"        return false; // Let browser handle it as well" & @CRLF & _
			"    };" & @CRLF & _
			"" & @CRLF & _
			"    // Signal that bridge is active" & @CRLF & _
			"    dispatchToAutoIt({ type: ""SYSTEM"", message: ""Core Bridge Injected"" });" & @CRLF & _
			"})();"
	Return $sJS
EndFunc   ;==>__Get_Core_Bridge_JS

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_freezer
; Description ...: freez/unfreeze $oWebV2M
; Syntax ........: __NetWebView2_freezer($oWebV2M, ByRef $idPic)
; Parameters ....: $oWebV2M             - an object.
;                  $idPic               - [in/out] an integer value.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_freezer($oWebV2M, ByRef $idPic)
	Local $hWebView2_Window = WinGetHandle($oWebV2M.BrowserWindowHandle)
	#Region ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content
	If $idPic Then
		_SendMessage($hWebView2_Window, $WM_SETREDRAW, True, 0) ; Enables
		_WinAPI_RedrawWindow($hWebView2_Window, 0, 0, BitOR($RDW_FRAME, $RDW_INVALIDATE, $RDW_ALLCHILDREN))  ; Repaints
		GUICtrlDelete($idPic)
		$idPic = 0
		Return
	EndIf
	#EndRegion ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content

	#Region ; freeze $hWebView2_Window

	#Region ; add PIC to parent window
	Local $hMainGUI_Window = _WinAPI_GetWindow($hWebView2_Window, $GW_HWNDPREV)
	Local $aPos = WinGetPos($hWebView2_Window)
;~ 	_ArrayDisplay($aPos, '$aPos ' & @ScriptLineNumber)
	Local $hPrev = GUISwitch($hMainGUI_Window)
	$idPic = GUICtrlCreatePic('', 0, 0, $aPos[2], $aPos[3])
	Local $hPic = GUICtrlGetHandle($idPic)
	GUISwitch($hPrev)
	#EndRegion ; add PIC to parent window

	; Create bitmap
	Local $hDC = _WinAPI_GetDC($hPic)
	Local $hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $aPos[2], $aPos[3])
	Local $hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
	Local $hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $aPos[2], $aPos[3])
	Local $hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBmp)
	_WinAPI_PrintWindow($hWebView2_Window, $hSrcDC, 2)
	_WinAPI_BitBlt($hDestDC, 0, 0, $aPos[2], $aPos[3], $hSrcDC, 0, 0, $MERGECOPY)

	_WinAPI_ReleaseDC($hPic, $hDC)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)
	_WinAPI_DeleteObject($hBmp)

	; Set bitmap to control
	_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
	Local $hObj = _SendMessage($hPic, $STM_GETIMAGE)
	If $hObj <> $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf

	_SendMessage($hWebView2_Window, $WM_SETREDRAW, False, 0) ; Disables ; https://www.autoitscript.com/forum/topic/199172-disable-gui-updating-repainting/
	Return $idPic
	#EndRegion ; freeze $hWebView2_Window
EndFunc   ;==>__NetWebView2_freezer

#EndRegion ; NetWebView2Lib UDF - #INTERNAL_USE_ONLY#

#Region ; NetWebView2Lib UDF - === EVENT HANDLERS ===
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_COMErrFunc
; Description ...:
; Syntax ........: __NetWebView2_COMErrFunc($oError)
; Parameters ....: $oError              - an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_COMErrFunc($oError) ; COM Error Function used by COM Error Handler
	If @Compiled Then Return
	Local $s_INFO = _
			"COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF
	__NetWebView2_Log($oError.scriptline, $s_INFO, 1)
	$oError = 0 ; Explicitly release the COM reference inside the volatile scopeEndFunc
EndFunc   ;==>__NetWebView2_COMErrFunc

Volatile Func __NetWebView2_fake_COMErrFunc($oError) ; COM Error Function used by COM Error Handler
	#forceref $oError
	; this is only to silently handle _NetWebView2_IsRegisteredCOMObject()
	$oError = 0 ; Explicitly release the COM reference inside the volatile scopeEndFunc
EndFunc   ;==>__NetWebView2_fake_COMErrFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnMessageReceived
; Description ...: Handles native WebView2 events
; Syntax ........: __NetWebView2_Events__OnMessageReceived($oWebV2M, $hGUI, $sMsg)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sMsg                - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2.webmessagereceived?view=webview2-dotnet-1.0.3650.58
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	Local Const $s_Prefix = "[EVENT: OnMessageReceived]: GUI:" & $hGUI

	#Region ; Message parsing
;~ 	https://github.com/ioa747/NetWebView2Lib/pull/85#issuecomment-3890305808
;~ 	Local $bWasError = False
;~ 	#forceref $bWasError ; 2026/02/12 do not know where or ho to use it
;~ 	If StringLeft($sMsg, 6) = "ERROR|" Then
;~ 		$bWasError = True
;~ 		$sMsg = StringTrimLeft($sMsg, 6)
;~ 	EndIf
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Local Static $sCommand_static = ""
	If $_g_bNetWebView2_DebugDev And $sCommand_static <> $sCommand Then ; show the log - for DEV only
;~ 		ConsoleWrite("TEST IFNC: " & $s_Prefix & " @SLN=" & @ScriptLineNumber & " " & $sCommand & " Data=" & (StringLen($sData) > 120 ? StringLeft($sData, 120) & "..." : $sData) & @CRLF) ; FOR DEV TESTING ONLY
		$sCommand_static = $sCommand
	EndIf
	#EndRegion ; Message parsing

	Switch $sCommand
		Case "WINDOW_RESIZED"
			Local Static $sData_static = Null
			If $sData_static <> $sData Then
				$sData_static = $sData
				$aParts = StringSplit($sData, "|")

				If $aParts[0] >= 2 Then
					Local $iW = Int($aParts[1]), $iH = Int($aParts[2])
					; Filter minor resize glitches
					If $iW > 50 And $iH > 50 Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand & ":" & $iW & "x" & $iH, 1)
				EndIf
				__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__WINDOW_RESIZED)
			EndIf

		Case "INIT_FAILED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__INIT_FAILED)

		Case "INIT_READY"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__INIT_READY)

		Case "WebView2 Profile not ready."
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__PROFILE_NOT_READY)

		Case "NAV_STARTING"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__NAV_STARTING)

		Case "URL_CHANGED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__URL_CHANGED)

		Case "NAV_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__NAV_ERROR)
			$oWebV2M.Stop()
			ConsoleWrite("> TEST NAV_ERR: __NetWebView2_LastMessage_KEEPER($oWebV2M)=" & __NetWebView2_LastMessage_KEEPER($oWebV2M) & " SLN=" & @ScriptLineNumber & @CRLF)

		Case "NAV_COMPLETED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__NAV_COMPLETED)

		Case "TITLE_CHANGED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand & " >> " & $oWebV2M.GetDocumentTitle(), 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED)

		Case "EXTENSION"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__EXTENSION)

		Case "EXTENSION_LOADED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__EXTENSION_LOADED)

		Case "EXTENSION_FAILED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__EXTENSION_FAILED)

		Case "EXTENSION_REMOVED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__EXTENSION_REMOVED)

		Case "EXTENSION_NOT_FOUND"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__EXTENSION_NOT_FOUND)

		Case "REMOVE_EXTENSION_FAILED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__REMOVE_EXTENSION_FAILED)

		Case "SELECTED_TEXT"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__SELECTED_TEXT)

		Case "INNER_TEXT"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__INNER_TEXT)

		Case "INNER_TEXT_FAILED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__INNER_TEXT_FAILED)

		Case "HTML_SOURCE"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__HTML_SOURCE)

		Case "CAPTURE_SUCCESS"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__CAPTURE_SUCCESS)

		Case "CAPTURE_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__CAPTURE_ERROR)

		Case "PRINT_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__PRINT_ERROR)

		Case "PDF_EXPORT_SUCCESS"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__PDF_EXPORT_SUCCESS)

		Case "PDF_EXPORT_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__PDF_EXPORT_ERROR)

		Case "CDP_RESULT"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__CDP_RESULT)

		Case "CDP_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__CDP_ERROR)

		Case "DATA_CLEARED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DATA_CLEARED)

		Case "COOKIES_B64"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__COOKIES_B64)

		Case "COOKIES_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__COOKIES_ERROR)

		Case "COOKIE_ADD_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__COOKIE_ADD_ERROR)

		Case "BLOCKED_AD"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BLOCKED_AD)

		Case "DOWNLOAD_STARTING"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DOWNLOAD_STARTING)

		Case "BROWSER_GOT_FOCUS"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BROWSER_GOT_FOCUS)

		Case "BROWSER_LOST_FOCUS"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COMMAND:" & $sCommand, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BROWSER_LOST_FOCUS)

		Case "ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " ! CRITICAL ERROR:" & $sData, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__CRITICAL_ERROR)

		Case Else
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " ! UNKNOWN MESSAGE:" & (StringLen($sMsg) > 200 ? StringLeft($sMsg, 200) & "..." : $sMsg), 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__UNKNOWN_MESSAGE)
	EndSwitch

EndFunc   ;==>__NetWebView2_Events__OnMessageReceived

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_JSEvents__OnMessageReceived
; Description ...: Handles custom messages from JavaScript (window.chrome.webview.postMessage)
; Syntax ........: __NetWebView2_JSEvents__OnMessageReceived($oWebV2M, $hGUI, $sMsg)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sMsg                - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_JSEvents__OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M

	Local Const $s_Prefix = "[JSEvents__OnMessageReceived]: GUI:" & $hGUI
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " MSG=" & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg), 1)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. Modern JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Processing JSON message...", 1)
		Local $oJSON = _NetJson_CreateParser()
		If @error Or Not IsObj($oJSON) Then
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " ERROR: Failed to create NetJson object.", 1)
			Return SetError(@error, @extended, $oJSON)
		EndIf

		$oJSON.Parse($sMsg)
		Local $sJobType = $oJSON.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " COM_TEST Confirmed: " & $oJSON.GetTokenValue("status"), 1)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Processing Delimited message...", 1)
		Local $sCommand, $sData, $iSplitPos
		$iSplitPos = StringInStr($sMsg, "|") - 1

		If $iSplitPos < 0 Then
			$sCommand = StringStripWS($sMsg, 3)
			$sData = ""
		Else
			$sCommand = StringStripWS(StringLeft($sMsg, $iSplitPos), 3)
			$sData = StringTrimLeft($sMsg, $iSplitPos + 1)
		EndIf

		Switch $sCommand
			Case "ERROR"
				__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Status General " & $sCommand & ": " & $sData, 1)

			Case "NAV_ERROR"
				__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Status " & $sCommand & ": " & $sData, 1)

			Case "COM_TEST"
				__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Status Legacy " & $sCommand & ": " & $sData, 1)

			Case "JSON_CLICKED"
				Local $aClickData = StringSplit($sData, "=", 2) ; Split "Key = Value"
				If UBound($aClickData) >= 2 Then
					Local $sKey = StringStripWS($aClickData[0], 3)
					Local $sVal = StringStripWS($aClickData[1], 3)
					__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " " & $sCommand & ": Property: " & $sKey & " | Value: " & $sVal, 1)
				EndIf

		EndSwitch
	EndIf

EndFunc   ;==>__NetWebView2_JSEvents__OnMessageReceived

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnBrowserGotFocus
; Description ...:
; Syntax ........: __NetWebView2_Events__OnBrowserGotFocus($oWebV2M, $hGUI, $iReason)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $iReason             - an integer value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnBrowserGotFocus($oWebV2M, $hGUI, $iReason)
	Local Const $s_Prefix = "[EVENT: OnBrowserGotFocus]: GUI:" & $hGUI & " REASON: " & $iReason
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BROWSER_GOT_FOCUS)
EndFunc   ;==>__NetWebView2_Events__OnBrowserGotFocus

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnBrowserLostFocus
; Description ...:
; Syntax ........: __NetWebView2_Events__OnBrowserLostFocus($oWebV2M, $hGUI, $iReason)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $iReason             - an integer value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnBrowserLostFocus($oWebV2M, $hGUI, $iReason)
	Local Const $s_Prefix = "[EVENT: OnBrowserLostFocus]: GUI:" & $hGUI & " REASON: " & $iReason
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BROWSER_LOST_FOCUS)
EndFunc   ;==>__NetWebView2_Events__OnBrowserLostFocus

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnZoomChanged
; Description ...:
; Syntax ........: __NetWebView2_Events__OnZoomChanged($oWebV2M, $hGUI, $iFactor)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $iFactor             - an integer value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnZoomChanged($oWebV2M, $hGUI, $iFactor)
	Local Const $s_Prefix = "[EVENT: OnZoomChanged]: GUI:" & $hGUI & " FACTOR: " & $iFactor
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__ZOOM_CHANGED)
EndFunc   ;==>__NetWebView2_Events__OnZoomChanged

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnURLChanged
; Description ...:
; Syntax ........: __NetWebView2_Events__OnURLChanged($oWebV2M, $hGUI, $sURL)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sURL                - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnURLChanged($oWebV2M, $hGUI, $sURL)
	Local Const $s_Prefix = "[EVENT: OnURLChanged]: GUI:" & $hGUI & " URL: " & $sURL
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__URL_CHANGED)
EndFunc   ;==>__NetWebView2_Events__OnURLChanged

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnTitleChanged
; Description ...:
; Syntax ........: __NetWebView2_Events__OnTitleChanged($oWebV2M, $hGUI, $sTITLE)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sTITLE              - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnTitleChanged($oWebV2M, $hGUI, $sTITLE)
	#forceref $oWebV2M

	Local Const $s_Prefix = "[EVENT: OnTitleChanged]: GUI:" & $hGUI & " TITLE: " & $sTITLE
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
;~ 	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED)
	If $_g_bNetWebView2_DebugDev Then ConsoleWrite("> IFNC: TEST LOAD WAIT: __NetWebView2_LastMessage_Navigation($oWebV2M)=" & __NetWebView2_LastMessage_Navigation($oWebV2M) & ' SLN=' & @ScriptLineNumber & @CRLF)
EndFunc   ;==>__NetWebView2_Events__OnTitleChanged

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnNavigationStarting
; Description ...:
; Syntax ........: __NetWebView2_Events__OnNavigationStarting($oWebV2M, $hGUI, $sURL)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sURL                - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnNavigationStarting($oWebV2M, $hGUI, $sURL)
	Local Const $s_Prefix = "[EVENT: OnNavigationStarting]: GUI:" & $hGUI & " URL: " & $sURL
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__NAV_STARTING)
EndFunc   ;==>__NetWebView2_Events__OnNavigationStarting

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnNavigationCompleted
; Description ...:
; Syntax ........: __NetWebView2_Events__OnNavigationCompleted($oWebV2M, $hGUI, $bIsSuccess, $iWebErrorStatus)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $bIsSuccess          - a boolean value.
;                  $iWebErrorStatus     - an integer value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnNavigationCompleted($oWebV2M, $hGUI, $bIsSuccess, $iWebErrorStatus)
	Local Const $s_Prefix = "[EVENT: OnNavigationCompleted]: GUI:" & $hGUI & " " & ($bIsSuccess ? "SUCCESS" : "ERROR ( WebErrorStatus:" & $iWebErrorStatus & ")")
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__NAV_COMPLETED)
EndFunc   ;==>__NetWebView2_Events__OnNavigationCompleted

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnContextMenuRequested
; Description ...:
; Syntax ........: __NetWebView2_Events__OnContextMenuRequested($oWebV2M, $hGUI, $sLink, $iX, $iY, $sSelection)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sLink               - a string value.
;                  $iX                  - an integer value.
;                  $iY                  - an integer value.
;                  $sSelection          - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnContextMenuRequested($oWebV2M, $hGUI, $sLink, $iX, $iY, $sSelection)
	#forceref $oWebV2M

	Local Const $s_Prefix = "[EVENT: OnContextMenuRequested]: GUI:" & $hGUI & " LINK: " & $sLink & " X: " & $iX & " Y: " & $iY & " SELECTION: " & $sSelection
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
EndFunc   ;==>__NetWebView2_Events__OnContextMenuRequested

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnContextMenu
; Description ...:
; Syntax ........: __NetWebView2_Events__OnContextMenu($oWebV2M, $hGUI, $sMenuData)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sMenuData           - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnContextMenu($oWebV2M, $hGUI, $sMenuData)
	#forceref $oWebV2M

	Local Const $s_Prefix = "[EVENT: OnContextMenu]: GUI:" & $hGUI & " MENUDATA: " & $sMenuData
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
EndFunc   ;==>__NetWebView2_Events__OnContextMenu

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnWebResourceResponseReceived
; Description ...:
; Syntax ........: __NetWebView2_Events__OnWebResourceResponseReceived($oWebV2M, $hGUI, $iStatusCode, $sReasonPhrase,
;                  $sRequestUrl)
; Parameters ....: $oWebV2M             - WebView2 object that fired the event
;                  $hGUI                - a handle to Window that fired the event
;                  $iStatusCode         - HTTP StatusCode
;                  $sReasonPhrase       - StatusCode rephrased to human resonable string
;                  $sRequestUrl         - the URL that fired the event
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2.webresourceresponsereceived?view=webview2-dotnet-1.0.2849.39
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnWebResourceResponseReceived($oWebV2M, $hGUI, $iStatusCode, $sReasonPhrase, $sRequestUrl)
	Local Const $s_Prefix = "[EVENT: OnWebResourceResponseReceived]: GUI:" & $hGUI & " HTTPStatusCode: " & $iStatusCode & " (" & $sReasonPhrase & ")  URL: " & $sRequestUrl
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__RESPONSE_RECEIVED)
EndFunc   ;==>__NetWebView2_Events__OnWebResourceResponseReceived

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnDownloadStarting
; Description ...:
; Syntax ........: __NetWebView2_Events__OnDownloadStarting($oWebV2M, $hGUI, $sURL, $sDefaultPath)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sURL                - a string value.
;                  $sDefaultPath        - a string value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnDownloadStarting($oWebV2M, $hGUI, $sURL, $sDefaultPath)
	Local Const $s_Prefix = "[EVENT: OnDownloadStarting]: GUI:" & $hGUI & " URL: " & $sURL & " DEFAULT_PATH: " & $sDefaultPath
	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DOWNLOAD_STARTING)
EndFunc   ;==>__NetWebView2_Events__OnDownloadStarting

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnDownloadStateChanged
; Description ...:
; Syntax ........: __NetWebView2_Events__OnDownloadStateChanged($oWebV2M, $hGUI, $sState, $sURL, $iTotal_Bytes,
;                  $iReceived_Bytes)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $sState              - a string value.
;                  $sURL                - a string value.
;                  $iTotal_Bytes        - an integer value.
;                  $iReceived_Bytes     - an integer value.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnDownloadStateChanged($oWebV2M, $hGUI, $sState, $sURL, $iTotal_Bytes, $iReceived_Bytes)
	Local Const $s_Prefix = "[EVENT: OnDownloadStateChanged]: GUI:" & $hGUI & " State: " & $sState & " URL: " & $sURL & " Total_Bytes: " & $iTotal_Bytes & " Received_Bytes: " & $iReceived_Bytes
	Local $iPercent = 0
	If $iTotal_Bytes > 0 Then $iPercent = Round(($iReceived_Bytes / $iTotal_Bytes), 5) * 100

	; Convert to MB for easy-to-read log
	Local $iReceived_MegaBytes = Round($iReceived_Bytes / 1024 / 1024)
	Local $iTotal_MegaBytes = Round($iTotal_Bytes / 1024 / 1024)

	Local Const $s_Message = " " & $iPercent & "% (" & $iReceived_MegaBytes & " / " & $iTotal_MegaBytes & " Mega Bytes)"
	Switch $sState
		Case "InProgress"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & $s_Message, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DOWNLOAD_IN_PROGRESS)
		Case "Interrupted"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & $s_Message, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DOWNLOAD_INTERRUPTED)
		Case "Completed"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & $s_Message, 1)
			__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__DOWNLOAD_COMPLETED)
	EndSwitch
EndFunc   ;==>__NetWebView2_Events__OnDownloadStateChanged

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnAcceleratorKeyPressed
; Description ...:
; Syntax ........: __NetWebView2_Events__OnAcceleratorKeyPressed($oWebV2M, $hGUI, $oArgs)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $oArgs               - an object.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnAcceleratorKeyPressed($oWebV2M, $hGUI, $oArgs)
	#forceref $oWebV2M
	Local Const $sArgsList = _
			'[VirtualKey=' & $oArgs.VirtualKey & _ ; The VK code of the key.
			'; KeyEventKind=' & $oArgs.KeyEventKind & _             ; Type of key event (Down, Up, etc.).
			'; Handled=' & $oArgs.Handled & _                       ; Set to `True` to stop the browser from processing the key.
			'; RepeatCount=' & $oArgs.RepeatCount & _               ; The number of times the key has repeated.
			'; ScanCode=' & $oArgs.ScanCode & _                     ; Hardware scan code.
			'; IsExtendedKey=' & $oArgs.IsExtendedKey & _           ; True if it's an extended key (e.g., right Alt).
			'; IsMenuKeyDown=' & $oArgs.IsMenuKeyDown & _           ; True if Alt is pressed.
			'; WasKeyDown=' & $oArgs.WasKeyDown & _                 ; True if the key was already down.
			'; IsKeyReleased=' & $oArgs.IsKeyReleased & _           ; True if the event is a key up.
			'; KeyEventLParam=' & $oArgs.KeyEventLParam & ']'       ; Gets the LPARAM value that accompanied the window message.
	Local Const $s_Prefix = "[EVENT: OnAcceleratorKeyPressed]: GUI:" & $hGUI & " $oArgs: " & ((IsObj($oArgs)) ? ($sArgsList) : ('ERROR'))

;~ 	https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2acceleratorkeypressedeventargs?view=webview2-dotnet-1.0.705.50
	If $oArgs.VirtualKey = 27 Then ; ESC 27 1b 033 Escape, next character is not echoed ; https://www.autoitscript.com/autoit3/docs/appendix/ascii.htm
;~ 		$oWebV2M.CancelDownloads($_sURLDownload_InProgress)
	EndIf

	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
	$oArgs = 0 ; Explicitly release the COM reference inside the volatile scopeEndFunc
EndFunc   ;==>__NetWebView2_Events__OnAcceleratorKeyPressed

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnProcessFailed
; Description ...: Fired when a renderer or other browser process fails/crashes.
; Syntax ........: __NetWebView2_Events__OnProcessFailed($oWebV2M, $hGUI, $oArgs)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $oArgs               - an object.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnProcessFailed($oWebV2M, $hGUI, $oArgs)
	Local Const $sArgsList = _
			'[Kind=' & $oArgs.ProcessFailedKind & _
			'; Reason=' & $oArgs.Reason & _
			'; ExitCode=' & $oArgs.ExitCode & _
			'; Description=' & $oArgs.ProcessDescription & ']'
	Local Const $s_Prefix = "[EVENT: OnProcessFailed]: GUI:" & $hGUI & " $oArgs: " & $sArgsList

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__PROCESS_FAILED)
	$oArgs = 0
EndFunc   ;==>__NetWebView2_Events__OnProcessFailed

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Events__OnBasicAuthenticationRequested
; Description ...:  event is raised when WebView encounters a Basic HTTP Authentication request as described in https://developer.mozilla.org/docs/Web/HTTP/Authentication, a Digest HTTP Authentication request as described in https://developer.mozilla.org/docs/Web/HTTP/Headers/Authorization#digest, an NTLM authentication or a Proxy Authentication request.
; Syntax ........: __NetWebView2_Events__OnBasicAuthenticationRequested($oWebV2M, $hGUI, $oArgs)
; Parameters ....: $oWebV2M             - an object.
;                  $hGUI                - a handle value.
;                  $oArgs               - an object.
; Return values .: None
; Author ........: ioa747, mLipok
; Modified ......:
; Remarks .......: The host can provide a response with credentials for the authentication or cancel the request.
;                  If the host sets the Cancel property to false but does not provide either UserName or Password properties on the Response property, then WebView2 will show the default authentication challenge dialog prompt to the user.
; Related .......:
; Link ..........: https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2.basicauthenticationrequested?view=webview2-dotnet-1.0.2903.40
; Example .......: No
; ===============================================================================================================================
Volatile Func __NetWebView2_Events__OnBasicAuthenticationRequested($oWebV2M, $hGUI, $oArgs)
	Local Const $sArgsList = _
			'[Uri=' & $oArgs.Uri & _
			'; Challenge=' & $oArgs.Challenge & ']'
	Local Const $s_Prefix = "[EVENT: OnBasicAuthenticationRequested]: GUI:" & $hGUI & " $oArgs: " & $sArgsList

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	__NetWebView2_LastMessage_KEEPER($oWebV2M, $NETWEBVIEW2_MESSAGE__BASIC_AUTHENTICATION_REQUESTED)
	; Note: User should handle $oArgs.UserName / $oArgs.Password and call $oArgs.Complete() in their script.
	$oArgs = 0
EndFunc   ;==>__NetWebView2_Events__OnBasicAuthenticationRequested

#Region ; NetWebView2Lib UDF - === EVENT HANDLERS === #TODO


#Region ; NetWebView2Lib UDF - === EVENT HANDLERS === FRAME RELATED
Volatile Func __NetWebView2_Events__OnFrameCreated()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#framecreated
EndFunc   ;==>__NetWebView2_Events__OnFrameCreated

Volatile Func __NetWebView2_Events__OnContentLoading()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#contentloading
EndFunc   ;==>__NetWebView2_Events__OnContentLoading

Volatile Func __NetWebView2_Events__OnDOMContentLoaded()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#domcontentloaded
EndFunc   ;==>__NetWebView2_Events__OnDOMContentLoaded

Volatile Func __NetWebView2_Events__OnDestroyed()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#destroyed
EndFunc   ;==>__NetWebView2_Events__OnDestroyed

Volatile Func __NetWebView2_Events__OnNameChanged()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#namechanged
EndFunc   ;==>__NetWebView2_Events__OnNameChanged

;~ is this followed navigationcompleted are the same as __NetWebView2_Events__OnNavigationCompleted() ?
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#navigationcompleted

;~ is this followed navigationstarting are the same as __NetWebView2_Events__OnNavigationStarting() ?
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#navigationstarting

Volatile Func __NetWebView2_Events__OnScreenCaptureStarting()
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#screencapturestarting
EndFunc   ;==>__NetWebView2_Events__OnScreenCaptureStarting

;~ is this followed webmessagereceived are the same as __NetWebView2_Events__OnMessageReceived() ?
;~ https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/winrt/microsoft_web_webview2_core/corewebview2frame?view=webview2-winrt-1.0.3595.46#webmessagereceived

#EndRegion ; NetWebView2Lib UDF - === EVENT HANDLERS === FRAME RELATED

#EndRegion ; NetWebView2Lib UDF - === EVENT HANDLERS === #TODO

#EndRegion ; NetWebView2Lib UDF - === EVENT HANDLERS ===
