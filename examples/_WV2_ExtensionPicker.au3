#include-once
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; _WV2_ExtensionPicker.au3
; Extension Manager v0.0.2 for NetWebView2Lib

#include <File.au3>
#include <WindowsStylesConstants.au3>
#include <WinAPISysWin.au3>
#include <GUIConstantsEx.au3>

; Global variables for Modal Instance management
Global $__oWeb, $__oBridge, $__hPop, $__hWND, $__iOldEventMode, $__sGoBackLabel
Global $__sExtSourcePath, $__sActiveExtensionsBase

; #FUNCTION# ====================================================================================================================
; Name...........: _WV2_ShowExtensionPicker
; Description....: Opens a modal Extension Manager with Back-navigation and Dynamic UI.
; Parameters.....: $iWidth         - Window width
;                  $iHeight        - Window height
;                  $hWND           - Handle of the parent window
;                  $sExtSourcePath - Path to your Extensions Library folder (Format: Name_ID)
;                  $sUserDataPath  - Path to the current WebView2 User Data Folder
; ===============================================================================================================================
Func _WV2_ShowExtensionPicker($iWidth = 500, $iHeight = 650, $hWND = 0, $sExtSourcePath = "", $sUserDataPath = "")

	If Not FileExists($sExtSourcePath) Then Return MsgBox(48, "Extension Manager", "Extension Libpary is empty" & _
			@CRLF & "or path not exist")

	If Not FileExists($sUserDataPath) Then Return MsgBox(48, "Extension Manager", "User Data profile is empty" & _
			@CRLF & "or path not exist")

	$__sExtSourcePath = $sExtSourcePath
	ConsoleWrite("$__sExtSourcePath=" & $__sExtSourcePath & @CRLF)
	$__hWND = $hWND

	; Save current GUI mode and enable OnEvent mode for Bridge handling
	$__iOldEventMode = Opt("GUIOnEventMode")
	Opt("GUIOnEventMode", 1)

	; Create Modal GUI
	$__hPop = GUICreate("Extension Manager", $iWidth, $iHeight, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN), -1, $hWND)
	GUISetBkColor(0x1A1A1A, $__hPop)
	GUISetOnEvent($GUI_EVENT_CLOSE, "__ExtensionPickerEvents")

	$__sGoBackLabel = GUICtrlCreateLabel("GoBack", 30, 10, 100, 24)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER)
	GUICtrlSetColor(-1, 0x00FFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, "__ExtensionPickerEvents")

	; Initialize WebView2 Manager Instance
	$__oWeb = ObjCreate("NetWebView2.Manager")
	If Not IsObj($__oWeb) Then Return MsgBox(16, "Error", "NetWebView2Lib DLL is not registered!")

	; Register Events and Setup Bridge
	ObjEvent($__oWeb, "__PopWebView_", "IWebViewEvents")
	$__oBridge = $__oWeb.GetBridge()
	ObjEvent($__oBridge, "__PopBridge_", "IBridgeEvents")

	; Use the UserDataPath folder for the picker's internal data
	$__oWeb.Initialize($__hPop, $sUserDataPath, 0, 35, $iWidth, $iHeight - 35)
	$__oWeb.SetAutoResize(True)

	; Wait for the engine to be ready
	Do
		Sleep(10)
	Until $__oWeb.IsReady

	Local $bAllowPopups = $__oWeb.AreBrowserPopupsAllowed
	ConsoleWrite(">>>$bAllowPopups=" & $bAllowPopups & @CRLF)

	; Path where WebView2 stores active extensions
	; UserDataPath\EBWebView\Default\Local Extension Settings
	$__sActiveExtensionsBase = $sUserDataPath & "\EBWebView\Default\Local Extension Settings"

	; Initial Navigation
	$__oWeb.NavigateToString(__ExtensionPickerLoad())
	GUISetState(@SW_SHOW, $__hPop)
	GUISetState(@SW_DISABLE, $hWND)
EndFunc   ;==>_WV2_ShowExtensionPicker

; #INTERNAL_CALLBACK# ===========================================================================================================
Func __ExtensionPickerLoad()
	; Generate Header and Styles
	Local $sHTML_Header = "<html><head><title>Extension Manager</title><style>" & _
			"body { font-family: 'Segoe UI', sans-serif; background: #1a1a1a; color: #e0e0e0; padding: 20px; margin:0; }" & _
			".top-bar { display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #333; padding: 15px 20px; background: #222; position: sticky; top: 0; z-index: 100; }" & _
			"h2 { margin: 0; color: #fff; font-size: 18px; }" & _
			".btn-back { background: #444; color: white; border: none; padding: 6px 14px; border-radius: 4px; cursor: pointer; display: none; font-weight: bold; }" & _
			".btn-back:hover { background: #555; }" & _
			".container { padding: 20px; }" & _
			".card { background: #252525; border: 1px solid #333; border-radius: 10px; padding: 15px; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 6px rgba(0,0,0,0.3); }" & _
			".info { flex-grow: 1; }" & _
			".status-tag { font-size: 10px; font-weight: bold; text-transform: uppercase; padding: 2px 6px; border-radius: 3px; margin-bottom: 5px; display: inline-block; }" & _
			".active { background: #1b4721; color: #81c784; border: 1px solid #2e7d32; }" & _
			".missing { background: #422a2a; color: #e57373; border: 1px solid #c62828; }" & _
			".name { font-size: 16px; font-weight: bold; color: #fff; }" & _
			".id-text { font-size: 10px; color: #666; font-family: 'Consolas', monospace; margin-top: 3px; }" & _
			".actions { display: flex; gap: 8px; }" & _
			".btn { border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-weight: 600; transition: 0.2s; min-width: 70px; }" & _
			".btn-launch { background: #0078d4; color: white; }" & _
			".btn-launch:hover { background: #1085e0; }" & _
			".btn-add { background: #28a745; color: white; }" & _
			".btn-add:hover { background: #218838; }" & _
			".btn-remove { background: #b91c1c; color: white; }" & _
			".btn-remove:hover { background: #dc2626; }" & _
			"</style></head><body>" & _
			"<div class='top-bar'>" & _
			"<h2 id='ui-title'>Extension Manager</h2>" & _
			"<button id='btn-back' class='btn-back' onclick='window.chrome.webview.postMessage(""GO_BACK_TO_LIST"")'>&larr; Back</button>" & _
			"</div><div class='container' id='content'>"

	Local $oJson = ObjCreate("NetJson.Parser") ; Use the built-in JSON parser
	Local $sListBody = ""
	Local $aFolders = _FileListToArray($__sExtSourcePath, "*", 2)

	If Not @error Then
		For $i = 1 To $aFolders[0]
			Local $sDisplayName = $aFolders[$i], $sExtensionID = ""
			If StringInStr($aFolders[$i], "_") Then
				Local $aData = StringSplit($aFolders[$i], "_")
				$sDisplayName = $aData[1]
				$sExtensionID = $aData[2]
			EndIf

			If StringLen($sExtensionID) = 32 Then
				Local $bIsActive = FileExists($__sActiveExtensionsBase & "\" & $sExtensionID)

				; finding the Popup Path from the manifest
				Local $sPopupPath = "index.html" ; Default
				Local $sManifestPath = $__sExtSourcePath & "\" & $aFolders[$i] & "\manifest.json"
				If FileExists($sManifestPath) And IsObj($oJson) Then
					$oJson.Parse(FileRead($sManifestPath))
					; 1. Test for Manifest V3 (action)
					Local $sFound = $oJson.GetTokenValue("action.default_popup")
					; 2. Test for Manifest V2 if V3 is empty (browser_action)
					If $sFound == "" Then $sFound = $oJson.GetTokenValue("browser_action.default_popup")
					; 3. Test for page-action (rare but exists)
					If $sFound == "" Then $sFound = $oJson.GetTokenValue("page_action.default_popup")
					; 4. apply if Found
					If $sFound <> "" Then $sPopupPath = $sFound
				EndIf

				$sListBody &= '<div class="card"><div class="info">'
				If $bIsActive Then
					$sListBody &= '<span class="status-tag active">Installed & Active</span>'
				Else
					$sListBody &= '<span class="status-tag missing">Not Installed</span>'
				EndIf

				$sListBody &= '<div class="name">' & $sDisplayName & '</div>' & _
						'<div class="id-text">' & $sExtensionID & '</div></div><div class="actions">'

				If $bIsActive Then
					$sListBody &= '<button class="btn btn-launch" onclick="window.chrome.webview.postMessage(''NAV_EXT|' & $sExtensionID & '|' & $sPopupPath & ''')">Launch</button>'
					$sListBody &= '<button class="btn btn-remove" onclick="window.chrome.webview.postMessage(''REMOVE_EXT|' & $sExtensionID & ''')">Remove</button>'
				Else
					$sListBody &= '<button class="btn btn-add" onclick="window.chrome.webview.postMessage(''ADD_EXT|' & $aFolders[$i] & ''')">Add Extension</button>'
				EndIf
				$sListBody &= '</div></div>'
			EndIf
		Next
	Else
		$sListBody &= "<p>Library path empty or not found.</p>"
	EndIf

	Return $sHTML_Header & $sListBody & "</div></body></html>"

EndFunc   ;==>__ExtensionPickerLoad

; #INTERNAL_CALLBACK# ===========================================================================================================
Func __PopWebView_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $hGUI
	ConsoleWrite("+PopWebViewMessage=" & $sMessage & @CRLF)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)
	Switch $sCommand
		Case "EXTENSION_LOADED"

		Case "EXTENSION_REMOVED"
			$oWebV2M.NavigateToString(__ExtensionPickerLoad())

		Case "TITLE_CHANGED"
			Local $sTitle = $aParts[2]

			If $sTitle = "Extension Manager" Then
				ConsoleWrite("> Extension Manager" & @CRLF)
				GUICtrlSetState($__sGoBackLabel, $GUI_HIDE)
			Else
				ConsoleWrite("> Changed to: " & $sTitle & @CRLF)
				GUICtrlSetState($__sGoBackLabel, $GUI_SHOW)
			EndIf

	EndSwitch
EndFunc   ;==>__PopWebView_OnMessageReceived

; #INTERNAL_CALLBACK# ===========================================================================================================
Func __PopBridge_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $hGUI
	ConsoleWrite("-PopBridgeMessage=" & $sMessage & @CRLF)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "GO_BACK_TO_LIST"
			$oWebV2M.NavigateToString(__ExtensionPickerLoad())

		Case "NAV_EXT" ; NAV_EXT|ID|PopupPath
			If $aParts[0] > 2 Then
				Local $sTargetID = $aParts[2]
				Local $sPopupPath = $aParts[3]

				ConsoleWrite("> Launching Extension: " & $sTargetID & " Path: " & $sPopupPath & @CRLF)
				$oWebV2M.Navigate("extension://" & $sTargetID & "/" & $sPopupPath)
			EndIf

		Case "ADD_EXT"
			Local $sExtPath = $__sExtSourcePath & "\" & $aParts[2]
			ConsoleWrite("> Loading Extension: " & $sExtPath & @CRLF)
			$oWebV2M.AddExtension($sExtPath)

		Case "REMOVE_EXT"
			ConsoleWrite("> Remove Extension: " & $aParts[2] & @CRLF)
			$oWebV2M.RemoveExtension($aParts[2])

	EndSwitch
EndFunc   ;==>__PopBridge_OnMessageReceived

; #INTERNAL_CALLBACK# ===========================================================================================================
Func __ExtensionPickerEvents()
	Switch @GUI_CtrlId
		Case $GUI_EVENT_CLOSE
			$__oWeb.Cleanup()
			GUIDelete($__hPop)
			$__oWeb = 0
			$__oBridge = 0
			Opt("GUIOnEventMode", $__iOldEventMode)
			GUISetState(@SW_ENABLE, $__hWND)
			Sleep(100)
			WinActivate($__hWND)

		Case $__sGoBackLabel
			$__oWeb.NavigateToString(__ExtensionPickerLoad())

	EndSwitch
EndFunc   ;==>__ExtensionPickerEvents

