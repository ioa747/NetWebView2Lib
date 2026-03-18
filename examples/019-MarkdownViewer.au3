#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
;~ #AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include "..\NetWebView2Lib.au3"

$_g_bNetWebView2_DebugInfo = False

; 019-MarkdownViewer.au3

; Global Objects & Handles
Global $oWebV2M, $oJSBridge
Global $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
Global $g_hMainGUI, $g_hBrowserGui, $g_idSplitter, $g_idEdtMarkdown, $Bar
Global $g_iSplitRatio = 0.5 ; Initial 50/50 split
Global $g_sLastDir = @ScriptDir, $g_iSaved = 1

_MainGUI()

Func _MainGUI() ; Creates the primary application window and starts the message loop
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	; Use $WS_CLIPCHILDREN to prevent flickering when resizing child windows
	$g_hMainGUI = GUICreate("NetWebView2 - Markdown Project", 1000, 800, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $g_hMainGUI)

	Local $sMarkdownContent = "# 019-Markdown Project" & @CRLF & _
			"## Subtitle" & @CRLF & _
			"1. First item" & @CRLF & _
			"2. Second item with **Bold** and *Italic*" & @CRLF & @CRLF & _
			"> This is a blockquote to see the CSS styling." & @CRLF & @CRLF & _
			"---" & @CRLF & _
			"Check the `marked.umd.js` file to see the source code!" & @CRLF & @CRLF & _
			"🏆 Thanks to 🌐https://github.com/markedjs/marked/"
	$g_idEdtMarkdown = GUICtrlCreateEdit($sMarkdownContent, 5, 30, 490, 780, BitOR($ES_WANTRETURN, $WS_VSCROLL, $ES_MULTILINE), 0)
	Local $iFontSz = 11
	GUICtrlSetFont(-1, $iFontSz, $FW_NORMAL, $GUI_FONTNORMAL, "Segoe UI")
	GUICtrlSetColor(-1, 0xFBFBFB)
	GUICtrlSetBkColor(-1, 0x33373A)


	; Splitter
	$g_idSplitter = GUICtrlCreateLabel("▒", 505, 30, 5, 780, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetFont(-1, 25)
	GUICtrlSetColor(-1, 0x999999)
	GUICtrlSetCursor(-1, 13) ; SizeWE cursor

	Local $sExtras = "New, -, Close"
	$Bar = _Web_MakeBar($g_hMainGUI, $sExtras, 0)

	; Register Windows Message
	GUIRegisterMsg($WM_SIZE, _WM_SIZE) ; Handle the WinAPI message for window resizing.
	GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")

	; Initialize WebView2
	$g_hBrowserGui = GUICreate("", 490, 780, 505, 30, BitOR($WS_CHILD, $WS_CLIPCHILDREN), -1, $g_hMainGUI)

	$oWebV2M = _NetWebView2_CreateManager("", "Web_Events_")
	If @error Then Return ConsoleWrite("!> Error: Failed to create $oWebV2M object , error: " & @error & ", extended:" & @extended & @CRLF)

	; Initialize JavaScript Bridge
	$oJSBridge = _NetWebView2_GetBridge($oWebV2M)
	If @error Then Return ConsoleWrite("!> Error: Failed to create $oJSBridge object , error: " & @error & ", extended:" & @extended & @CRLF)

	_NetWebView2_Initialize($oWebV2M, $g_hBrowserGui, $sProfileDirectory, 0, 0, 0, 0, True, True, 0.8, "0x2B2B2B", False)

	_RenderMarkdown($oWebV2M, $sMarkdownContent)
	GUISetState(@SW_SHOWNOACTIVATE, $g_hBrowserGui)

	; Show the main window
	GUISetState(@SW_SHOW, $g_hMainGUI)

	_UpdateLayout_Simple()

	Local $nMsg, $iZoom
	; Main Message Loop
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			; ~~~ $Bar Controls ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $GUI_EVENT_CLOSE, $Bar.ctx_Close
				ExitLoop

			Case $Bar.FileOpen
				_Menu_FileOpen()

			Case $Bar.FileSave
				_Menu_FileSave()

			Case $Bar.Italic
				_Markdown_WrapSelection("*")

			Case $Bar.Underline
				_Markdown_WrapSelection("<u>", "</u>")

			Case $Bar.Bold
				_Markdown_WrapSelection("**")

			Case $Bar.CodeBox
				_Markdown_WrapSelection("`")

			Case $Bar.Erase
				GUICtrlSetState($g_idEdtMarkdown, $GUI_FOCUS)
				Send("{DEL}")

			Case $Bar.BulletedList
				_Markdown_WrapSelection("- ", "")

			Case $Bar.FontDecrease
				$iFontSz -= 1
				If $iFontSz < 8 Then $iFontSz = 8
				GUICtrlSetFont($g_idEdtMarkdown, $iFontSz)

			Case $Bar.FontIncrease
				$iFontSz += 1
				If $iFontSz > 15 Then $iFontSz = 15
				GUICtrlSetFont($g_idEdtMarkdown, $iFontSz)

			Case $Bar.ViewPane
				$g_iSplitRatio = 0.001
				_UpdateLayout_Simple()

			Case $Bar.ReadingMode
				$g_iSplitRatio = 0.5
				_UpdateLayout_Simple()

			Case $Bar.EditPane
				$g_iSplitRatio = 0.990
				_UpdateLayout_Simple()

			Case $Bar.ZoomIn
				$iZoom = $oWebV2M.ZoomFactor * 100
				$iZoom += 5
				If $iZoom > 150 Then $iZoom = 150
				$oWebV2M.ZoomFactor = $iZoom / 100

			Case $Bar.ZoomOut
				$iZoom = $oWebV2M.ZoomFactor * 100
				$iZoom -= 5
				If $iZoom < 80 Then $iZoom = 80
				$oWebV2M.ZoomFactor = $iZoom / 100

			Case $Bar.CopyFormated
				_WebView2_CopyHTML()

				; ~~~ $Bar.ctx_ : ContexMenu ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $Bar.GlobalNavButton
				MouseClick("right")

			Case $Bar.ctx_New
				If Not $g_iSaved Then
					Local $iMsgBoxAnswer = MsgBox(563, "Save Changes?", "The current file has unsaved changes." & @CRLF & _
							"Do you want to save them before creating a new one?", 0, $g_hMainGUI)
					Select
						Case $iMsgBoxAnswer = 6 ;Yes
							_Menu_FileSave()
							_ClearEditor()

						Case $iMsgBoxAnswer = 7 ;No
							_ClearEditor()
					EndSelect
				Else
					_ClearEditor()
				EndIf

			Case $Bar.ctx_About
				MsgBox(0, "About", "NetWebView2 v(" & _NetWebView2_GetVersion($oWebV2M) & ")", 0, $g_hMainGUI)

				; ~~~ Dragging Handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $GUI_EVENT_PRIMARYDOWN
				_HandleSplitter()

		EndSwitch
	WEnd

	GUIDelete($g_hMainGUI)
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)

EndFunc   ;==>_MainGUI
;---------------------------------------------------------------------------------------
#Region ; === Core ===
Volatile Func Web_Events_OnNavigationStarting($oWebV2M, $hGUI, $oArgs)
	#forceref $oWebV2M, $hGUI
	Local $sURL = $oArgs.Uri
	If StringLeft($sURL, 4) = "http" Then
		ShellExecute($sURL)
		$oArgs.Cancel = True ; Cancel navigation in WebView2
		ConsoleWrite("!!! External Link Intercepted: " & $sURL & @CRLF)
	EndIf
EndFunc   ;==>Web_Events_OnNavigationStarting

Func _Menu_FileOpen() ; File Open dialog to select a Markdown file
	Local $sFileMask = "Markdown Files (*.md;*.txt)|All Files (*.*)"
	Local $sFilePath = FileOpenDialog("Select Markdown File", $g_sLastDir, $sFileMask, 1, "", $g_hMainGUI)
	If @error Then Return ; User cancelled

	; Read the file content
	Local $hFile = FileOpen($sFilePath, 0)
	If $hFile = -1 Then
		MsgBox(16, "Error", "Could not open the file.", 0, $g_hMainGUI)
		Return
	EndIf

	$g_sLastDir = StringLeft($sFilePath, StringInStr($sFilePath, "\", 2, -1) - 1)
	$g_iSaved = 1

	Local $sContent = FileRead($hFile)
	FileClose($hFile)

	; Update the Edit Control
	GUICtrlSetData($g_idEdtMarkdown, $sContent)

	; Update the WebView2
	_RenderMarkdown($oWebV2M, $sContent)
EndFunc   ;==>_Menu_FileOpen

Func _Menu_FileSave() ; File Save Dialog to Save the current Markdown file
	Local $sTextToSave = GUICtrlRead($g_idEdtMarkdown)
	Local $sFileMask = "Markdown Files (*.md)|All Files (*.*)"
	Local $sFilePath = FileSaveDialog("Save Markdown File", $g_sLastDir, $sFileMask, 18, "document.md", $g_hMainGUI)
	If @error Then Return ; User cancelled

	; Ensure the file has a .md extension
	If Not StringInStr($sFilePath, ".") Then $sFilePath &= ".md"

	Local $hFile = FileOpen($sFilePath, 2 + 256)
	If $hFile = -1 Then
		MsgBox(16, "Error", "Could not write to file.", 0, $g_hMainGUI)
		Return
	EndIf
	$g_sLastDir = StringLeft($sFilePath, StringInStr($sFilePath, "\", 2, -1) - 1)
	$g_iSaved = FileWrite($hFile, $sTextToSave)
	FileClose($hFile)

EndFunc   ;==>_Menu_FileSave

Func _Markdown_WrapSelection($sOpen, $sClose = Default)
	If $sClose = Default Then $sClose = $sOpen
	Local $hWndEdit = GUICtrlGetHandle($g_idEdtMarkdown)

	; Get the current selection start and end positions
	Local $aSel = _GUICtrlEdit_GetSel($hWndEdit)
	Local $iStart = $aSel[0]
	Local $iEnd = $aSel[1]

	; Get the full text and extract the selected part
	Local $sFullText = GUICtrlRead($g_idEdtMarkdown)
	Local $sSelectedText = StringMid($sFullText, $iStart + 1, $iEnd - $iStart)

	; Create the new formatted text
	Local $sNewText = $sOpen & $sSelectedText & $sClose

	; Replace the selection in the Edit control
	_GUICtrlEdit_ReplaceSel($hWndEdit, $sNewText)

	; Focus back to the Edit control
	GUICtrlSetState($g_idEdtMarkdown, $GUI_FOCUS)

	; Note: The _WM_COMMAND will automatically
	; trigger the preview update because the text changed!
EndFunc   ;==>_Markdown_WrapSelection

Func _WebView2_CopyHTML()
	; Send JavaScript to get the HTML content of the "view" div
	Local $sHTML = _NetWebView2_ExecuteScript($oWebV2M, "document.getElementById('view').innerHTML", $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)

	$sHTML = StringTrimLeft($sHTML, 1)
	$sHTML = StringTrimRight($sHTML, 1)

	$sHTML = StringReplace($sHTML, '\"', '"')
	$sHTML = StringReplace($sHTML, '\n', @CRLF)

	If $sHTML <> "" Then
		ClipPut($sHTML)
		ConsoleWrite("> HTML copied to clipboard!" & @CRLF)
		ToolTip("HTML Copied!", MouseGetPos(0), MouseGetPos(1))
		Sleep(2000)
		ToolTip("")
	Else
		MsgBox(16, "Error", "Nothing to copy or preview is empty.", 0, $g_hMainGUI)
	EndIf
EndFunc   ;==>_WebView2_CopyHTML

Func _ClearEditor()
	GUICtrlSetData($g_idEdtMarkdown, "")
	_RenderMarkdown($oWebV2M, "")
	$g_iSaved = 1
EndFunc   ;==>_ClearEditor
#EndRegion ; === Core ===

#Region ; === GUI helper ===
Func _Web_MakeBar($hGUI, $ctx_list = "", $bAddress = 1) ; Make a Basic ToolBar for Browsing navigation
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = [[59136, "GlobalNavButton"] _
			, [59448, "FileOpen"] _
			, [59276, "FileSave"] _
			, [59611, "Italic"] _
			, [59612, "Underline"] _
			, [59613, "Bold"] _
			, [59222, "CodeBox"] _
			, [59228, "Erase"] _
			, [59645, "BulletedList"] _
			, [59623, "FontDecrease"] _
			, [59624, "FontIncrease"] _
			, [59551, "EditPane"] _
			, [59190, "ReadingMode"] _
			, [59552, "ViewPane"] _
			, [59592, "CopyFormated"] _
			, [59555, "ZoomIn"] _
			, [59167, "ZoomOut"] _
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

	; Creating the Address Bar ??
	Local $aCsz = WinGetClientSize($hGUI)
	Local $iInputW = $aCsz[0] - $iX

	$m.Address = GUICtrlCreateInput("", $iX, $iY, $iInputW, $iH)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
	If Not $bAddress Then GUICtrlSetState(-1, $GUI_HIDE)

	; Creating the Context Menu (adding to GlobalNavButton)
	$m.ctx = GUICtrlCreateContextMenu($m.GlobalNavButton)

	; List combination: Extra items + Separator + Basic items
	Local $sFinalList = $ctx_list
	If $sFinalList <> "" Then $sFinalList &= ",-,"
	$sFinalList &= "About"

	Local $aItems = StringSplit($sFinalList, ",")
	Local $sName
	For $i = 1 To $aItems[0]
		$sName = StringReplace(StringStripWS($aItems[$i], 3), " ", "_")
		If $sName = "-" Then
			GUICtrlCreateMenuItem("", $m.ctx)  ; Create a separator line
		Else
			$m["ctx_" & $sName] = GUICtrlCreateMenuItem($sName, $m.ctx)
		EndIf
	Next

	Return $m
EndFunc   ;==>_Web_MakeBar

Func _WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam
	Local $iCode = BitShift($wParam, 16) ; Notification code
	Local $iID = BitAND($wParam, 0xFFFF) ; Control ID

	; If the Markdown Edit control changed
	If $iID = $g_idEdtMarkdown And $iCode = 0x300 Then ; 0x300 = $EN_CHANGE
		Local $sNewText = GUICtrlRead($g_idEdtMarkdown)
		_RenderMarkdown($oWebV2M, $sNewText)
		$g_iSaved = 0
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_COMMAND

Func _WM_SIZE($hWnd, $iMsg, $wParam, $lParam) ; Handle the WinAPI message for window resizing.
	#forceref $iMsg, $lParam
	If $hWnd = $g_hMainGUI And $wParam <> 1 Then _UpdateLayout_Simple()
	Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_SIZE

Func _HandleSplitter() ; Handles the logic for resizing the main GUI window splitter.
	Local $aCursor = GUIGetCursorInfo($g_hMainGUI)
	If Not IsArray($aCursor) Or $aCursor[4] <> $g_idSplitter Then Return

	If $aCursor[2] Then
		While $aCursor[2] ; While you hold down the mouse
			$aCursor = GUIGetCursorInfo($g_hMainGUI)
			Local $aWin = WinGetClientSize($g_hMainGUI)
			If $aWin[0] > 0 Then
				$g_iSplitRatio = $aCursor[0] / $aWin[0]
				If $g_iSplitRatio < 0.001 Then $g_iSplitRatio = 0.001
				If $g_iSplitRatio > 0.990 Then $g_iSplitRatio = 0.990
				_UpdateLayout_Simple()
			EndIf
			Sleep(10)
		WEnd
		_WinAPI_RedrawWindow($g_hMainGUI, 0, 0, $RDW_INVALIDATE + $RDW_UPDATENOW + $RDW_ALLCHILDREN)
	EndIf

EndFunc   ;==>_HandleSplitter

Func _UpdateLayout_Simple() ; Updates the layout of the main GUI by adjusting the positions and sizes of various controls.
	Local $aWin = WinGetClientSize($g_hMainGUI)
	Local $iW = $aWin[0], $iH = $aWin[1]
	Local $iGap = 8

	; Calculating the width of the left side
	Local $iW1 = Int($iW * $g_iSplitRatio)
	Local $iW2 = $iW - $iW1 - $iGap

	; EdtMarkdown Move
	GUICtrlSetPos($g_idEdtMarkdown, 5, 30, $iW1 - 5, $iH - 35)

	; Browser Move
	WinMove($g_hBrowserGui, "", $iW1 + $iGap + 1, 30, $iW2 - 6, $iH - 35)

	; Splitter Move
	GUICtrlSetPos($g_idSplitter, $iW1 + 2, 30, $iGap, $iH - 35)

EndFunc   ;==>_UpdateLayout_Simple
#EndRegion ; === GUI helper ===

#Region ; === Markdown ===
Func _RenderMarkdown($oWebV2M, $sMarkdown)
	Local Static $bInitialized = False

	; If it's the first time, load the whole shell
	If Not $bInitialized Then
		Local $sLibraryCode = FileRead(@ScriptDir & "\JS_Lib\marked\marked.umd.js")
		Local $sStyle = _CSS()
		Local $sHTML = "<html><head><meta charset='utf-8'><style>" & $sStyle & "</style></head><body>" & _
				"<div id='view'></div>" & _
				"<script>" & @CRLF & _
				$sLibraryCode & @CRLF & _
				"window.updateView = (md) => { document.getElementById('view').innerHTML = marked.parse(md); };" & @CRLF & _
				"</script></body></html>"

		_NetWebView2_NavigateToString($oWebV2M, $sHTML)
		$bInitialized = True
		; Give it a small moment to load before the first injection
		Sleep(200)
	EndIf

	; Efficiently update only the content via JS Bridge
	Local $sJSScript = "if(window.updateView) window.updateView(" & _EscapeForJS($sMarkdown) & ");"
	_NetWebView2_ExecuteScript($oWebV2M, $sJSScript)
EndFunc   ;==>_RenderMarkdown

Func _CSS()
	Local $sCSS = _
			"body {" & _
			"    font-family: 'Segoe UI', system-ui, sans-serif;" & _
			"    padding: 40px;" & _
			"    line-height: 1.6;" & _
			"    max-width: 850px;" & _
			"    margin: auto;" & _
			"    /* Background and Text Colors */" & _
			"    background-color: #1a1a1a; " & _
			"    color: #e0e0e0; " & _
			"}" & _
			"h1, h2, h3 {" & _
			"    color: #ffffff;" & _
			"    border-bottom: 1px solid #333;" & _
			"    padding-bottom: 5px;" & _
			"}" & _
			"code {" & _
			"    background-color: #2d2d2d;" & _
			"    color: #f8f8f2;" & _
			"    padding: 2px 5px;" & _
			"    border-radius: 4px;" & _
			"    font-family: 'Cascadia Code', Consolas, monospace;" & _
			"}" & _
			"blockquote {" & _
			"    border-left: 5px solid #4CAF50;" & _ ; Green accent for quotes
			"    background-color: #252525;" & _
			"    margin: 1.5em 0;" & _
			"    padding: 10px 20px;" & _
			"    color: #aaaaaa;" & _
			"}" & _
			"a {" & _
			"    color: #4da6ff;" & _     ; Light blue for links
			"}"
	Return $sCSS
EndFunc   ;==>_CSS

Func _EscapeForJS($sText)
	$sText = StringReplace($sText, "\", "\\")
	$sText = StringReplace($sText, "'", "\'")
	$sText = StringReplace($sText, @CRLF, "\n")
	$sText = StringReplace($sText, @CR, "\n")
	$sText = StringReplace($sText, @LF, "\n")
	Return "'" & $sText & "'"
EndFunc   ;==>_EscapeForJS
#EndRegion ; === Markdown ===
