#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

; CoreWebView2PdfToolbarItems Enumeration (Bitwise flags)
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_NONE = 0
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_SAVE = 1
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_PRINT = 2
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_SAVE_AS = 4
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_ZOOM = 8
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_PAGE_LAYOUT = 16
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_FULL_SCREEN = 32
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_MORE_SETTINGS = 64
Global Const $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_SEARCH = 128

Global $hGUI, $idLabelStatus

Main()

Func Main()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; === GUI Creation ===
	Local $iHeight = 800
	Local $sDefTitle = "WebView2 .NET Manager - v1.4.3 Demo"
	$hGUI = GUICreate($sDefTitle, 1000, $iHeight, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetState(@SW_SHOW)

	; === WebView2 Initialization ===
	Local $oWebV2M = _NetWebView2_CreateManager()
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; ### STEP 1: Navigating to AutoIt...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 1: Navigating to AutoIt...")
	Local $sUrl = "https://www.autoitscript.com"
	_NetWebView2_Navigate($oWebV2M, $sUrl)

	Sleep(2000)

	; ### STEP 2: Creating MHTML Web Archive...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 2: Creating MHTML Web Archive...")
	Local $sMhtmlPath = @ScriptDir & "\AutoIt_archive.mhtml"
	; Exports the current page data as HTML (0) or MHTML (1).
	; If FilePath is provided, it saves to disk; otherwise, it returns the content as a string.
	Local $sDllResponse = $oWebV2M.ExportPageData(1, $sMhtmlPath)
	ConsoleWrite("! DLL Response: " & $sDllResponse & @CRLF)
	; Check if DLL actually reported success
	If Not StringInStr($sDllResponse, "SUCCESS") Then ConsoleWrite("! Critical Error: DLL failed to export MHTML." & @CRLF)

	Sleep(2000)

	; ### STEP 3: Capturing PDF stream to RAM (Base64)...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 3: Capturing PDF stream to RAM (Base64)...")
	;Captures the current page as a PDF and returns the content as a Base64-encoded string.
	Local $sBase64PDF = $oWebV2M.PrintToPdfStream()

	Sleep(2000)

	; ### STEP 4: Exporting traditional PDF file...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 4: Exporting traditional PDF file...")
	Local $sClassicPdfPath = @ScriptDir & "\AutoIt_traditional.pdf"
	; Saves the current page as a PDF file.
	$oWebV2M.ExportToPdf($sClassicPdfPath)

	Sleep(2000)

	; ### STEP 5: Loading protected PDF (Toolbar buttons hidden)...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 5: Loading protected PDF (Toolbar buttons hidden)...")
	Local $iHiddenItems = $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_SAVE + $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_SAVE_AS + $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_PRINT
	; Controls the visibility of buttons in the PDF viewer toolbar using a bitwise combination of CoreWebView2PdfToolbarItems (e.g., 1=Save, 2=Print, 4=Search).
	$oWebV2M.HiddenPdfToolbarItems = $iHiddenItems
	Local $sLocalPdfUrl = "file:///" & StringReplace($sClassicPdfPath, "\", "/")
	_NetWebView2_Navigate($oWebV2M, $sLocalPdfUrl)

	Sleep(5000)

	; ### STEP 6: Show all buttons in the PDF viewer toolbar...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 6: Show all buttons in the PDF viewer toolbar...")
	$iHiddenItems = $COREWEBVIEW2_PDF_TOOLBAR_ITEMS_NONE
	; Show all buttons in the PDF viewer toolbar
	$oWebV2M.HiddenPdfToolbarItems = $iHiddenItems
	$oWebV2M.Reload()

	Sleep(5000)

	; ### STEP 7: Load the MHTML Archive we created in Step 2
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 7: Load the MHTML Archive we created in Step 2")
	Local $sMhtmlUrl = "file:///" & StringReplace($sMhtmlPath, "\", "/")
	_NetWebView2_Navigate($oWebV2M, $sMhtmlUrl)

	Sleep(5000)

	; ### STEP 8: Clear view and Displaying recovered PDF from memory...
	WinSetTitle($hGUI, "", $sDefTitle & @TAB & ">>> STEP 8: Clear view and Displaying recovered PDF from memory...")
	_NetWebView2_Navigate($oWebV2M, "about:blank")
	Local $oJson = _NetJson_CreateParser()
	Local $sRecoveredPath = @ScriptDir & "\AutoIt_From_Memory.pdf"
	$oJson.DecodeB64ToFile($sBase64PDF, $sRecoveredPath)
	Local $sRecoveredUrl = "file:///" & StringReplace($sRecoveredPath, "\", "/")
	_NetWebView2_Navigate($oWebV2M, $sRecoveredUrl)

	Sleep(5000)

	WinSetTitle($hGUI, "", $sDefTitle & @TAB & "Tested Successfully!")

	; === Main Loop ===
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)
	$oWebV2M.Cleanup()
EndFunc   ;==>Main
