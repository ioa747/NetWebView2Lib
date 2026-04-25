#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Tidy_Parameters=/tcb=-1

; 023-epubJS-Static_EPUB_Viewer.au3			Script Version: 0.0.4.0
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ⚠️ Requirements:
; 1. epub.min.js & jszip.min.js in @ScriptDir & "\JS_Lib\epubjs\"
; 2. epub_viewer.html in the same directory.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"
#include <Array.au3>
#include <String.au3>

$_g_bNetWebView2_DebugInfo = False

Global $Bar ; Global Toolbar Map

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	Local $hGUI = GUICreate("WebView2 - EPUB reader", 800, 1000, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x33373A)

	; Get the WebView2 Manager object and register events
	Local $oWebV2M = _NetWebView2_CreateManager("", "", "--allow-file-access-from-files --disable-web-security")

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 25, 800, 1000 - 25, True, True, 1, 0x33373A)

	; Get the bridge object and register events
	Local $oBridge = _NetWebView2_GetBridge($oWebV2M, "_UserEventHandler_Bridge_")

	; Make a Basic ToolBar for Browsing navigation
	$Bar = _Web_MakeBar()

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION


	; Loading .epub
	Local $sEpubFile = @ScriptDir & "\chesterton-wisdom-of-father-brown.epub"

	; A. For Kindle style (Pages, no scrollbar):
;~ 	_EPUB_SetupStatic($oWebV2M, $sEpubFile, "EPUB Loaded", 0)

	; B. For Web style (Continuous scroll with bar on the right):
	_EPUB_SetupStatic($oWebV2M, $sEpubFile, "EPUB Loaded", 1)


	; Export Meta Data
	_NetWebView2_ExecuteScript($oWebV2M, "EPUB_GetMetadata();")
	Local $sJson = Get_Data_Sync("", "EPUB_DATA_PACKAGE")
	_EPUB_GetMetaData($sJson)

	Local $iMsg, $sLastDir, $iZoom, $bIsDark = True

	; Main Loop
	While 1

		$iMsg = GUIGetMsg()

		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $Bar.Open_File
				Local $sFileMask = "EPUB Files (*.epub)"
				Local $sFilePath = FileOpenDialog("Select EPUB File", $sLastDir, $sFileMask, 1, "", $hGUI)
				If @error Then ContinueLoop ; User cancelled
				$sLastDir = StringLeft($sFilePath, StringInStr($sFilePath, "\", 2, -1) - 1)
				$sEpubFile = $sFilePath

				; B. For Web style (Continuous scroll with bar on the right):
				_EPUB_SetupStatic($oWebV2M, $sEpubFile, "EPUB Loaded", 1)

				_NetWebView2_ExecuteScript($oWebV2M, "EPUB_GetMetadata();")
				$sJson = Get_Data_Sync("", "EPUB_DATA_PACKAGE")
				_EPUB_GetMetaData($sJson)

			Case $Bar.GoBack
				_NetWebView2_ExecuteScript($oWebV2M, "window.EPUB_Prev();")

			Case $Bar.GoForward
				_NetWebView2_ExecuteScript($oWebV2M, "window.EPUB_Next();")

			Case $Bar.ZoomIn
				$iZoom = $oWebV2M.ZoomFactor * 100
				$iZoom += 5
				If $iZoom > 150 Then $iZoom = 150
				$oWebV2M.ZoomFactor = $iZoom / 100
				$oWebV2M.WebViewSetFocus()

			Case $Bar.ZoomOut
				$iZoom = $oWebV2M.ZoomFactor * 100
				$iZoom -= 5
				If $iZoom < 80 Then $iZoom = 80
				$oWebV2M.ZoomFactor = $iZoom / 100
				$oWebV2M.WebViewSetFocus()

			Case $Bar.TogleDark
				$bIsDark = Not $bIsDark

				Local $sTheme = "default"
				Local $iHexColor = 0xF0F0F0 ; Light Grey για το control

				If $bIsDark Then
					$sTheme = "dark"
					$iHexColor = 0x33373A ; Dark Grey για το control  0xE0E0E0
				EndIf

				_NetWebView2_ExecuteScript($oWebV2M, "window.EPUB_SetTheme('" & $sTheme & "');")
				$oWebV2M.BackColor = $iHexColor
				GUISetBkColor($iHexColor)

				; zoom as refresh
				$iZoom = $oWebV2M.ZoomFactor * 100
				$iZoom = ($bIsDark ? $iZoom - 5 : $iZoom + 5)
				If $iZoom < 80 Then $iZoom = 100
				$oWebV2M.ZoomFactor = $iZoom / 100
				$oWebV2M.WebViewSetFocus()
				ConsoleWrite("> Theme switched to: " & $sTheme & @CRLF)


			Case $Bar.GlobalNavButton
				MouseClick("right")

			Case $Bar.ctx_About
				MsgBox(0, "Book Info", "Title: " & $Bar.meta_Title & @CRLF & "Author: " & $Bar.meta_Author, 0, $hGUI)
				$oWebV2M.WebViewSetFocus()

			Case Else
				; Check if we have chapters and if the message is within the menu range
				If $Bar.ChaptersCnt > 0 Then
					; Calculate the index based on the first menu item's ID
					Local $iIdx = $iMsg - $Bar.ctx_Items[0]

					; Validate that the click actually belongs to our chapter menu items
					If $iIdx >= 0 And $iIdx < $Bar.ChaptersCnt Then
						Local $sHref = $Bar.Href[$iIdx]
						_NetWebView2_ExecuteScript($oWebV2M, "window.rendition.display('" & $sHref & "');", 0)
						ConsoleWrite("+ Navigating to Chapter [" & $iIdx & "]: " & $sHref & @CRLF)
					EndIf
				EndIf

		EndSwitch
	WEnd

	GUIDelete($hGUI)
	_NetWebView2_CleanUp($oWebV2M, $oBridge)
EndFunc   ;==>_Example

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Volatile Func _UserEventHandler_Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("$sMsg=" & $sMsg & @CRLF)
	ConsoleWrite(">>> [__EVENTS_Bridge]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	Local $sFirstChar = StringLeft($sMsg, 1)

	If $sFirstChar = "{" Or $sFirstChar = "[" Then ; 1. JSON Messaging
		ConsoleWrite("+> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = _NetJson_CreateParser($sMsg)
		If @error Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				ConsoleWrite("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)

			Case "PDF_DATA_PACKAGE", "EPUB_DATA_PACKAGE" ; 👈 Add support for EPUB
				Get_Data_Sync($sMsg, $sJobType)
		EndSwitch

	Else ; 2. Legacy / Native Pipe-Delimited Messaging
		ConsoleWrite("+> : Legacy / Native Pipe-Delimited Messaging..." & @CRLF)
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
			Case "COM_TEST"
				ConsoleWrite("- Status: Legacy COM_TEST: " & $sData & @CRLF)

			Case "PDF_TEXT_RESULT"
				ConsoleWrite("- PDF_TEXT_RESULT: " & @CRLF & $sData & @CRLF)

			Case "ERROR"
				ConsoleWrite("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>_UserEventHandler_Bridge_OnMessageReceived

Func Get_Data_Sync($sData = "", $sJobType = "DEFAULT", $iTimeout = 8000)
	; We use a Map to hold many different types of data at the same time.
	Local Static $mDataMap[]

	; If we send data (from the Event Handler)
	If $sData <> "" Then
		$mDataMap[$sJobType] = $sData
		Return True
	EndIf

	; If we request data (from the main Script)
	Local $iStart = TimerInit()
	While Not MapExists($mDataMap, $sJobType)
		If TimerDiff($iStart) > $iTimeout Then Return SetError(1, 0, "")
		Sleep(10)
	WEnd

	Local $sResult = $mDataMap[$sJobType]
	MapRemove($mDataMap, $sJobType) ; Cleaning for next time
	Return $sResult
EndFunc   ;==>Get_Data_Sync

Func _Web_MakeBar() ; Make a Basic ToolBar
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = _
			[ _
			[59136, "GlobalNavButton"], _
			[59448, "Open_File"], _
			[59555, "ZoomIn"], _
			[59167, "ZoomOut"], _
			[59297, "TogleDark"], _
			[59179, "GoBack"], _
			[59178, "GoForward"] _
			]

	Local $iX = 0, $iY = 0, $iH = 25, $iW = 25, $iCnt = UBound($Btn)
	Local $m[] ; Map object to return IDs

	; Creating the Buttons
	For $i = 0 To $iCnt - 1
		$m[$Btn[$i][1]] = GUICtrlCreateButton(ChrW($Btn[$i][0]), $iX, $iY, $iW, $iH)
		GUICtrlSetFont(-1, 12, 400, 0, "Segoe Fluent Icons")
		GUICtrlSetTip(-1, $Btn[$i][1])
		GUICtrlSetResizing(-1, $GUI_DOCKALL)
		$iX += $iW
	Next

	Return $m
EndFunc   ;==>_Web_MakeBar

Func _EPUB_SetupStatic(ByRef $oWebV2M, $s_EPUB_Path, $sExpectedTitle, $iFlow = 1)
	; $sFlow: 0="paginated" (like a book) or 1="scrolled" (continuous scroll)
	Local $sFlow = ($iFlow ? "scrolled" : "paginated")

	; Fix paths
	Local $sViewerPath = StringReplace(@ScriptDir & "\JS_Lib\epubjs\epub_viewer.html", "\", "/")
	Local $sEPUB_URL = "file:///" & StringReplace($s_EPUB_Path, "\", "/")

	; Build Parameterized URL
	Local $sParams = "?book=" & $oWebV2M.EncodeURI($sEPUB_URL)
	$sParams &= "&flow=" & $sFlow
	$sParams &= "&scroll=" & ($iFlow ? "1" : "0")

	Local $sFinalURL = "file:///" & $sViewerPath & $sParams

	ConsoleWrite("Navigating to: " & $sFinalURL & @CRLF)
	_NetWebView2_Navigate($oWebV2M, $sFinalURL, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle, 5000)
;~ 	$oWebV2M.DisableBrowserFeatures()
EndFunc   ;==>_EPUB_SetupStatic

Func _EPUB_GetMetaData($sJson)
    ; Clean up existing Menu and Data immediately
    If MapExists($Bar, "ctx_Menu_Handle") Then
        GUICtrlDelete($Bar.ctx_Menu_Handle)
        $Bar.ctx_Menu_Handle = 0
    EndIf

    ; Reset tracking variables to prevent Range Errors in the main loop
    $Bar.ChaptersCnt = 0
    Local $aEmpty[1] = [0]
    $Bar.ctx_Items = $aEmpty
    $Bar.Href = $aEmpty
    $Bar.Label = $aEmpty

    ; Validate New Data
    If $sJson = "" Then Return
    Local $oJson = _NetJson_CreateParser($sJson)
    If Not IsObj($oJson) Then Return

    ; Extract Metadata
    $Bar.meta_Title = $oJson.GetTokenValue("title")
    $Bar.meta_Author = $oJson.GetTokenValue("creator")

    Local $iCount = $oJson.GetArrayLength("toc")
    If $iCount <= 0 Then Return ; No chapters, exit safely with empty arrays

    ; Prepare New Arrays
    Local $aHref[$iCount], $aLabel[$iCount], $aItems[$iCount]

    ; Rebuild Menu
    $Bar.ctx_Menu_Handle = GUICtrlCreateContextMenu($Bar.GlobalNavButton)
	$Bar.ctx_About = GUICtrlCreateMenuItem("Book: " & $Bar.meta_Title, $Bar.ctx_Menu_Handle)
    GUICtrlCreateMenuItem("", $Bar.ctx_Menu_Handle)

    For $i = 0 To $iCount - 1
        $aLabel[$i] = $oJson.GetTokenValue("toc[" & $i & "].label")
        $aHref[$i]  = $oJson.GetTokenValue("toc[" & $i & "].href")
        $aItems[$i] = GUICtrlCreateMenuItem($aLabel[$i], $Bar.ctx_Menu_Handle)
    Next

    ; Final Sync
    $Bar.ChaptersCnt = $iCount
    $Bar.ctx_Items = $aItems
    $Bar.Href = $aHref
    $Bar.Label = $aLabel

    ConsoleWrite("+ Menu Rebuilt: " & $iCount & " chapters found." & @CRLF)
EndFunc   ;==>_EPUB_GetMetaData
