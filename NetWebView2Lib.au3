;~ #AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebViewEvents__*,__NetWebView2_JSEvents__*

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIShPath.au3>
#include <WindowsConstants.au3>

#REMARK This UDF is marked as WorkInProgress - you may use them, but do not blame me if I do ScriptBreakingChange and as so far do not ask me for description or help till I remove this remark ; mLipok

#TODO UDF HEADER - anybody - feel free to make it done - just do not hesitate to full fill this part
#TODO UDF INDEX - anybody - feel free to make it done - just do not hesitate to full fill this part
#TODO FUNCTION HEADERS SUPLEMENTATION & CHECK - anybody - feel free to make it done - just do not hesitate to full fill this part

#TODO ; https://learn.microsoft.com/pl-pl/microsoft-edge/webview2/concepts/distribution?tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed

; Global objects
Global $_g_bNetWebView2_DebugInfo = True
Global $_g_sNetWebView2_User_JSEvents = ""
Global $_g_sNetWebView2_User_WebViewEvents = ""
Global $_g_oWeb

Global Enum _ ; $NETWEBVIEW2_MESSAGE__* are set by __NetWebView2_WebViewEvents__OnMessageReceived()
		$NETWEBVIEW2_MESSAGE__NONE, _ ; UDF setting - not related directly to API REFERENCES
		$NETWEBVIEW2_MESSAGE__INIT_READY, _
		$NETWEBVIEW2_MESSAGE__NAV_STARTING, _
		$NETWEBVIEW2_MESSAGE__URL_CHANGED, _
		$NETWEBVIEW2_MESSAGE__COMPLETED, _
		$NETWEBVIEW2_MESSAGE__TITLE_CHANGED, _
		$NETWEBVIEW2_MESSAGE__NAV_ERROR, _
		$NETWEBVIEW2_MESSAGE__SELECTED_TEXT, _
		$NETWEBVIEW2_MESSAGE__INNER_TEXT, _
		$NETWEBVIEW2_MESSAGE__HTML_SOURCE

#Region ; NetWebView2Lib UDF - _NetWebView2_* core functions
; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_Initialize
; Description ...:
; Syntax ........: _NetWebView2_Initialize(ByRef $oWebV2M, $hGUI, $sProfileDirectory[, $i_Left = 0[, $i_Top = 0[, $i_Width = 0[,
;                  $i_Height = 0[, $b_LoadWait = True[, $b_SetAutoResize = True[, $b_AreDevToolsEnabled = True[,
;                  $i_ZoomFactor = 1.0[, $s_BackColor = "0x2B2B2B"]]]]]]]]])
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $hGUI                - a handle value.
;                  $sProfileDirectory   - a string value.
;                  $i_Left              - [optional] an integer value. Default is 0.
;                  $i_Top               - [optional] an integer value. Default is 0.
;                  $i_Width             - [optional] an integer value. Default is 0.
;                  $i_Height            - [optional] an integer value. Default is 0.
;                  $b_LoadWait          - [optional] a boolean value. Default is True.
;                  $b_SetAutoResize     - [optional] a boolean value. Default is True.
;                  $b_AreDevToolsEnabled- [optional] a boolean value. Default is True.
;                  $i_ZoomFactor        - [optional] an integer value. Default is 1.0.
;                  $s_BackColor         - [optional] a string value. Default is "0x2B2B2B".
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_Initialize(ByRef $oWebV2M, $hGUI, $sProfileDirectory, $i_Left = 0, $i_Top = 0, $i_Width = 0, $i_Height = 0, $b_LoadWait = True, $b_SetAutoResize = True, $b_AreDevToolsEnabled = True, $i_ZoomFactor = 1.0, $s_BackColor = "0x2B2B2B")
	Local Const $s_Prefix = "[_NetWebView2_Initialize]:" & " GUI:" & $hGUI & " ProfileDirectory:" & $sProfileDirectory & " LEFT:" & $i_Left & " TOP:" & $i_Top & " WIDTH" & $i_Width & " HEIGHT:" & $i_Height & " LOADWAIT:" & $b_LoadWait & " SETAUTORESIZE:" & $b_SetAutoResize & " SetAutoResize:" & $b_AreDevToolsEnabled & " ZoomFactor:" & $i_ZoomFactor & " BackColor:" & $s_BackColor

	; Important: Pass $hGUI in parentheses to maintain Pointer type for COM
	Local $iInit = $oWebV2M.Initialize(($hGUI), $sProfileDirectory, $i_Left, $i_Top, $i_Width, $i_Height)
	If @error Then Return SetError(@error, @extended, $iInit)

	If $b_LoadWait Then _NetWebView2_LoadWait($oWebV2M, $NETWEBVIEW2_MESSAGE__INIT_READY)
	If @error Then Return SetError(@error, @extended, $iInit)

	; WebView2 Configuration
	$oWebV2M.SetAutoResize($b_SetAutoResize) ; Using SetAutoResize(True) to skip WM_SIZE
	$oWebV2M.AreDevToolsEnabled = $b_AreDevToolsEnabled ; Allow F12
	$oWebV2M.ZoomFactor = $i_ZoomFactor
	$oWebV2M.BackColor = $s_BackColor
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Manager Creation ERROR", 1)
	Return SetError(@error, $oWebV2M.GetBrowserProcessId(), '')
EndFunc   ;==>_NetWebView2_Initialize

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
	Local Const $s_Prefix = "[_NetWebView2_CreateManager]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oWebV2M = ObjCreate("NetWebView2.Manager") ; REGISTERED VERSION
;~ 	__NetWebView2_ObjName_FlagsValue($oWebV2M)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " Manager Creation ERROR", 1)
	If $sUserAgent Then $oWebV2M.SetUserAgent($sUserAgent)
	If $s_AddBrowserArgs Then $oWebV2M.AdditionalBrowserArguments = $s_AddBrowserArgs
	If $s_fnEventPrefix Then $_g_sNetWebView2_User_WebViewEvents = $s_fnEventPrefix
	ObjEvent($oWebV2M, "__NetWebView2_WebViewEvents__", "IWebViewEvents")
	Return SetError(@error, @extended, $oWebV2M)
EndFunc   ;==>_NetWebView2_CreateManager

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetBridge
; Description ...:
; Syntax ........: _NetWebView2_GetBridge(ByRef $oWebV2M[, $s_fnEventPrefix = ""])
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $s_fnEventPrefix     - [optional] a string value. Default is "".
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetBridge(ByRef $oWebV2M, $s_fnEventPrefix = "")
	Local Const $s_Prefix = "[_NetWebView2_GetBridge]:" & " fnEventPrefix:" & $s_fnEventPrefix
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $oWebJS = $oWebV2M.GetBridge()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " : Manager.GetBridge() ERROR", 1)

	If $s_fnEventPrefix Then $_g_sNetWebView2_User_JSEvents = $s_fnEventPrefix
	ObjEvent($oWebJS, "__NetWebView2_JSEvents__", "IBridgeEvents")
	Return SetError(@error, @extended, $oWebJS)
EndFunc   ;==>_NetWebView2_GetBridge

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_ExecuteScript
; Description ...:
; Syntax ........: _NetWebView2_ExecuteScript(ByRef $oWebV2M, $sJavaScript)
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $sJavaScript         - a string value.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_ExecuteScript(ByRef $oWebV2M, $sJavaScript)
	Local Const $s_Prefix = "[_NetWebView2_ExecuteScript]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $iRet = $oWebV2M.ExecuteScript($sJavaScript)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $iRet)
EndFunc   ;==>_NetWebView2_ExecuteScript

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

	Local $iRet = $oWebV2M.Cleanup()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	If @error Then Return SetError(@error, @extended, $iRet)

	$oWebV2M = 0
	$oJSBridge = 0
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $iRet)
EndFunc   ;==>_NetWebView2_CleanUp

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_LoadWait
; Description ...:
; Syntax ........: _NetWebView2_LoadWait(ByRef $oWebV2M[, $iWaitNavStatus = $NETWEBVIEW2_MESSAGE__INIT_READY[, $iTimeOut_ms = 0]])
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $iWaitNavStatus             - [optional] an integer value. Default is $NETWEBVIEW2_MESSAGE__INIT_READY.
;                  $iTimeOut_ms         - [optional] an integer value. Default is 0.
; Return values .: Success      - True
;                  Failure      - False and set @error
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_LoadWait(ByRef $oWebV2M, $iWaitNavStatus = $NETWEBVIEW2_MESSAGE__INIT_READY, $iTimeOut_ms = 0)
	Local Const $s_Prefix = "[_NetWebView2_LoadWait]: iStatus:" & $iWaitNavStatus
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $RETURN_VALUE = False
	If $iWaitNavStatus = $NETWEBVIEW2_MESSAGE__NONE Then
		$RETURN_VALUE = False
	ElseIf $iWaitNavStatus > $NETWEBVIEW2_MESSAGE__NAV_ERROR Then ; higher messsages are not for NAVIGATION thus not checking in _NetWebView2_LoadWait()
		$RETURN_VALUE = False
		SetError(1)
	Else
		Local $hTimer = TimerInit() ; Begin the timer and store the handle in a variable.

		; Wait for WebView2 to be ready
		While Sleep(10)
			If $iTimeOut_ms And TimerDiff($hTimer) > $iTimeOut_ms Then
				SetError(2)
				$RETURN_VALUE = False
				ExitLoop
			EndIf

			If $oWebV2M.IsReady Then
				Local $iStatus_check = __NetWebView2_NavigationStatus()
				If $iStatus_check >= $iWaitNavStatus And $iStatus_check <= $NETWEBVIEW2_MESSAGE__NAV_ERROR Then
					$RETURN_VALUE = True
					ExitLoop
				EndIf
			EndIf
		WEnd
	EndIf

	Local $iEndStatus = __NetWebView2_NavigationStatus()
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " : END STATUS=" & $iEndStatus & ' RETURN_VALUE=' & $RETURN_VALUE, 1)
	__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__NONE) ; reset

;~ 	Return SetError(@error, $iEndStatus, $RETURN_VALUE)
	Return

EndFunc   ;==>_NetWebView2_LoadWait

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_Navigate
; Description ...:
; Syntax ........: _NetWebView2_Navigate(ByRef $oWebV2M, $sURL[, $iWaitNavStatus = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED[,
;                  $iTimeOut_ms = 0]])
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $sURL                - a string value.
;                  $iWaitNavStatus      - [optional] an integer value. Default is $NETWEBVIEW2_MESSAGE__TITLE_CHANGED.
;                  $iTimeOut_ms         - [optional] an integer value. Default is 0.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_Navigate(ByRef $oWebV2M, $sURL, $iWaitNavStatus = $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $iTimeOut_ms = 0)
	Local Const $s_Prefix = "[_NetWebView2_LoadWait]: URL:" & $sURL & " WAIT:" & $iWaitNavStatus
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $iNavigation = $oWebV2M.Navigate($sURL)
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	If @error Then Return SetError(@error, @extended, $iNavigation)

	If $iWaitNavStatus Then _NetWebView2_LoadWait($oWebV2M, $iWaitNavStatus, $iTimeOut_ms)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, '')
EndFunc   ;==>_NetWebView2_Navigate

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetSource
; Description ...:
; Syntax ........: _NetWebView2_GetSource(ByRef $oWebV2M)
; Parameters ....: $oWebV2M             - [in/out] an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetSource(ByRef $oWebV2M)
	Local Const $s_Prefix = "[_NetWebView2_GetSource]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $sSource = $oWebV2M.GetSource()
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, $sSource)
EndFunc   ;==>_NetWebView2_GetSource


; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_NavigateToString
; Description ...:
; Syntax ........: _NetWebView2_NavigateToString(ByRef $oWebV2M, $s_HTML[, $b_LoadWait = True])
; Parameters ....: $oWebV2M             - [in/out] an object.
;                  $s_HTML              - a string value.
;                  $b_LoadWait          - [optional] a boolean value. Default is True.
; Return values .: None
; Author ........: mLipok, ioa747
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_NavigateToString(ByRef $oWebV2M, $s_HTML, $b_LoadWait = True)
	Local Const $s_Prefix = "[_NetWebView2_NavigateToString]:" & " HTML Size:" & StringLen($s_HTML) & " LoadWait:" & $b_LoadWait
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $iNavigation = $oWebV2M.NavigateToString($s_HTML)
	If @error Then Return SetError(@error, @extended, $iNavigation)

	If $b_LoadWait Then _NetWebView2_LoadWait($oWebV2M)
	If @error Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	Return SetError(@error, @extended, '')
EndFunc   ;==>_NetWebView2_NavigateToString

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_ExportPageData
; Description ...:
; Syntax ........: _NetWebView2_ExportPageData(ByRef $oWebV2M, $iFormat[, $sFilePath = ''])
; Parameters ....: $oWebV2M             - [in/out] an object.
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
Func _NetWebView2_ExportPageData(ByRef $oWebV2M, $iFormat, $sFilePath = '')
	#TODO $sParameters - search for  => "name": "captureSnapshot" ; https://github.com/ChromeDevTools/devtools-protocol/blob/master/json/browser_protocol.json
	#TODO https://github.com/ioa747/NetWebView2Lib/issues/15
	#TODO https://github.com/ioa747/NetWebView2Lib/pull/16

	Local Const $s_Prefix = "[_NetWebView2_ExportPageData]:" & " Format:" & $iFormat & " FilePath:" & (($sFilePath) ? ($sFilePath) : ('"EMPTY"'))
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $s_Result = $oWebV2M.ExportPageData($iFormat, $sFilePath)
	If StringLeft($s_Result, 6) = 'ERROR:' Then SetError(1)
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " RESULT:" & ((@error) ? ($s_Result) : ("SUCCESS")), 1)
	Return SetError(@error, @extended, $s_Result)
EndFunc   ;==>_NetWebView2_ExportPageData

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_PrintToPdfStream
; Description ...:
; Syntax ........: _NetWebView2_PrintToPdfStream(ByRef $oWebV2M)
; Parameters ....: $oWebV2M             - [in/out] an object.
; Return values .: Success      - String with Base64 encoded binary content of the PDF
;                  Failure      - string with error description "ERROR: ........." and set @error to 1
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_PrintToPdfStream(ByRef $oWebV2M)
	Local Const $s_Prefix = "[_NetWebView2_PrintToPdfStream]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $s_Result = $oWebV2M.PrintToPdfStream()
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
	If StringInStr($s_Result, 'ERROR:') Then SetError(1)

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " RESULT:" & ((@error) ? ($s_Result) : ("SUCCESS")), 1)
	Return SetError(@error, @extended, $s_Result)
EndFunc   ;==>_NetWebView2_PrintToPdfStream

#EndRegion ; NetWebView2Lib UDF - _NetWebView2_* core functions

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
	Local $oParser = ObjCreate("NetJson.Parser") ; REGISTERED VERSION
	If Not IsObj($oParser) Then Return SetError(1, 0, 0)
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

#Region ; NetWebView2Lib UDF - helper functions
#EndRegion ; NetWebView2Lib UDF - helper functions

#Region ; NetWebView2Lib UDF - #INTERNAL_USE_ONLY#

Func __NetWebView2_NavigationStatus($iStatus = Default, $iError = @error, $iExtended = @extended)
	Local Static $i_static = $NETWEBVIEW2_MESSAGE__NONE
	If $iStatus <> Default Then $i_static = $iStatus
	Return SetError($iError, $iExtended, $i_static)
EndFunc   ;==>__NetWebView2_NavigationStatus

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
			$sString = "! ( NetWebView2Lib UDF : Line=" & $s_ScriptLineNumber & ", @error=" & $iError & ", @extended=" & $iExtended & " ) :: " & $sString
		Else
			$sString = "+> ( NetWebView2Lib UDF : Line=" & $s_ScriptLineNumber & " ) :: " & $sString
		EndIf
	EndIf
	Local $iReturn = ConsoleWrite($sString & @CRLF)
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__NetWebView2_Log

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_ObjName_FlagsValue
; Description ...:
; Syntax ........: __NetWebView2_ObjName_FlagsValue(ByRef $oObj)
; Parameters ....: $oObj                - [in/out] an object.
; Return values .: None
; Author ........: AutoIt HelpFile ObjName Example 2
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_ObjName_FlagsValue(ByRef $oObj)
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
Func __NetWebView2_COMErrFunc($oError) ; COM Error Function used by COM Error Handler
	If @Compiled Then Return
	ConsoleWrite("NetWebView2Lib UDF (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>__NetWebView2_COMErrFunc

; Handles native WebView2 events
#TODO => Func __NetWebView2_WebViewEvents__OnMessageReceived(ByRef $oWebV2M, $hGUI, $sMsg)
Func __NetWebView2_WebViewEvents__OnMessageReceived($sMsg)
	Local Const $s_Prefix = "[WebViewEvents__OnMessageReceived]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Local Static $sCommand_static = ''

	If Not @Compiled And $sCommand_static <> $sCommand Then
		ConsoleWrite('TEST IFNC: ' & $s_Prefix & ' @SLN=' & @ScriptLineNumber & ' ' & $sCommand & @CRLF)
		$sCommand_static = $sCommand
	EndIf

	Switch $sCommand
		Case "WINDOW_RESIZED"
			$aParts = StringSplit($sData, "|")
			If $aParts[0] >= 2 Then
				Local $iW = Int($aParts[1]), $iH = Int($aParts[2])
				; Filter minor resize glitches
				If $iW > 50 And $iH > 50 Then __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & $iW & "x" & $iH, 1)
			EndIf
		Case "NAV_STARTING"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__NAV_STARTING)

		Case "INIT_READY"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__INIT_READY)

		Case "URL_CHANGED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__URL_CHANGED)

		Case "NAV_COMPLETED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__COMPLETED)

		Case "TITLE_CHANGED"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__TITLE_CHANGED)

		Case "NAV_ERROR"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__NAV_ERROR)
			$_g_oWeb.Stop()

		Case "SELECTED_TEXT"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__SELECTED_TEXT)

		Case "INNER_TEXT"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__INNER_TEXT)

		Case "HTML_SOURCE"
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & ' COMMAND:' & $sCommand, 1)
			__NetWebView2_NavigationStatus($NETWEBVIEW2_MESSAGE__HTML_SOURCE)

		Case Else
			__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg), 1)
	EndSwitch

	If $_g_sNetWebView2_User_WebViewEvents Then
		#TODO =>>>> Call($_g_sNetWebView2_User_WebViewEvents & 'OnMessageReceived', $oWebV2M, $hGUI, $sMsg)
		Call($_g_sNetWebView2_User_WebViewEvents & 'OnMessageReceived', $sMsg)
	EndIf

EndFunc   ;==>__NetWebView2_WebViewEvents__OnMessageReceived

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
#TODO => Func __NetWebView2_JSEvents__OnMessageReceived(ByRef $oWebV2M, ByRef $oWebJS, $hGUI, $sMsg)
Func __NetWebView2_JSEvents__OnMessageReceived($sMsg)
	Local Const $s_Prefix = "[JSEvents__OnMessageReceived]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg), 1)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. Modern JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__NetWebView2_Log(@ScriptLineNumber, $s_Prefix & "Processing JSON message...", 1)
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

	If $_g_sNetWebView2_User_JSEvents Then
		#TODO =>>>> Call($_g_sNetWebView2_User_JSEvents & 'OnMessageReceived', $oWebV2M, $oWebJS, $hGUI, $sMsg)
		Call($_g_sNetWebView2_User_JSEvents & 'OnMessageReceived', $sMsg)
	EndIf

EndFunc   ;==>__NetWebView2_JSEvents__OnMessageReceived

Func __NetWebView2_WebViewEvents__OnBrowserGotFocus($iReason)
	Local Const $s_Prefix = "[WebViewEvents__OnBrowserGotFocus]: REASON: " & $iReason
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnBrowserGotFocus

Func __NetWebView2_WebViewEvents__OnBrowserLostFocus($iReason)
	Local Const $s_Prefix = "[WebViewEvents__OnBrowserLostFocus]: REASON: " & $iReason
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnBrowserLostFocus

Func __NetWebView2_WebViewEvents__OnZoomChanged($iFactor)
	Local Const $s_Prefix = "[WebViewEvents__OnZoomChanged]: FACTOR: " & $iFactor
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnZoomChanged

Func __NetWebView2_WebViewEvents__OnURLChanged($sNewUrl)
	Local Const $s_Prefix = "[WebViewEvents__OnURLChanged]: URL: " & $sNewUrl
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnURLChanged

Func __NetWebView2_WebViewEvents__OnTitleChanged($sNewTitle)
	Local Const $s_Prefix = "[WebViewEvents__OnTitleChanged]: TITLE: " & $sNewTitle
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnTitleChanged

Func __NetWebView2_WebViewEvents__OnNavigationStarting($sNewUrl)
	Local Const $s_Prefix = "[WebViewEvents__OnNavigationStarting]: URL: " & $sNewUrl
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnNavigationStarting

Func __NetWebView2_WebViewEvents__OnNavigationCompleted($bIsSuccess, $iWebErrorStatus)
	Local Const $s_Prefix = "[WebViewEvents__OnNavigationCompleted]: IsSuccess: " & $bIsSuccess & " WebErrorStatus: " & $iWebErrorStatus
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnNavigationCompleted

#TODO => Func __NetWebView2_WebViewEvents__OnContextMenuRequested(ByRef $oWebV2M, $sLink, $iX, $iY, $sSelection)
Func __NetWebView2_WebViewEvents__OnContextMenuRequested($sLink, $iX, $iY, $sSelection)
	Local Const $s_Prefix = "[WebViewEvents__OnContextMenuRequested]: LINK: " & $sLink & " X: " & $iX & " Y: " & $iY & " SELECTION: " & $sSelection
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnContextMenuRequested

Func __NetWebView2_WebViewEvents__OnContextMenu($sMenuData)
	Local Const $s_Prefix = "[WebViewEvents__OnContextMenu]: MENUDATA: " & $sMenuData
	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 1)
EndFunc   ;==>__NetWebView2_WebViewEvents__OnContextMenu
#EndRegion ; NetWebView2Lib UDF - === EVENT HANDLERS ===
