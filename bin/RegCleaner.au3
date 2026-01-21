#RequireAdmin
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Tidy_Parameters=/reel

#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

_Cleaner()

Func _Cleaner()
	; === Configuration ===
	Local $sSearchTerm = "NetWebView2"
	Local $aTargets[2] = ["HKEY_LOCAL_MACHINE64\SOFTWARE\Classes", "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Classes"]

	; GUICreate
	Local $iWidth = @DesktopWidth * 0.7, $iHeight = @DesktopHeight * 0.9
	Local $hGUI = GUICreate("NetWebView2 - Registry Deep Cleaner", $iWidth, $iHeight)
	#forceref $hGUI

	GUISetFont(9, 400, 0, "Segoe UI")
	$iWidth -= 20
	$iHeight -= 90
	Local $idListView = GUICtrlCreateListView("Registry Key Path|Details", 10, 10, $iWidth, $iHeight, $LVS_REPORT + $LVS_SHOWSELALWAYS)
	_GUICtrlListView_SetExtendedListViewStyle($idListView, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
	_GUICtrlListView_SetColumnWidth($idListView, 0, $iWidth * 0.6)
	_GUICtrlListView_SetColumnWidth($idListView, 1, $iWidth * 0.4)
	$iHeight += 20
	Local $idStatus = GUICtrlCreateLabel("Scanning registry... please wait...", 10, $iHeight, $iWidth - 210 - 10, 20)
	$iHeight += 20
	Local $idBtnCancel = GUICtrlCreateButton("Cancel", $iWidth - 100, $iHeight, 100, 40)
	Local $idBtnDelete = GUICtrlCreateButton("Delete Selected", $iWidth - 210, $iHeight, 100, 40)
	GUISetState(@SW_SHOW)

	; Scan
	Local $iTotalFound = 0
	Local $bCanceled = False
	For $sRoot In $aTargets
		__Registry_Scan_Recursive($sRoot, $sSearchTerm, $idListView, $iTotalFound, $idStatus, $idBtnCancel)
		If @error Then
			$bCanceled = True
			ExitLoop
		EndIf
	Next
	If $bCanceled = True Then
		GUICtrlSetData($idStatus, "Scan canceled. Found " & $iTotalFound & " keys.")
	Else
		GUICtrlSetData($idStatus, "Scan complete. Found " & $iTotalFound & " keys.")
	EndIf

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit

			Case $idBtnDelete
				Local $iCheckedCount = 0
				; Count checked items first
				For $i = 0 To _GUICtrlListView_GetItemCount($idListView) - 1
					If _GUICtrlListView_GetItemChecked($idListView, $i) Then $iCheckedCount += 1
				Next

				If $iCheckedCount = 0 Then
					MsgBox($MB_ICONEXCLAMATION, "Nothing selected", "Please check the keys you want to remove.")
					ContinueLoop
				EndIf

				If MsgBox($MB_YESNO + $MB_ICONWARNING, "Confirm Deletion", "Are you sure you want to delete the " & $iCheckedCount & " selected keys?") = $IDYES Then
					__Delete_Checked_Items($idListView)
					MsgBox($MB_ICONINFORMATION, "Done", "Cleanup finished successfully.")
					Exit
				EndIf
		EndSwitch
	WEnd

EndFunc   ;==>_Cleaner

;---------------------------------------------------------------------------------------
Func __Registry_Scan_Recursive($sKey, $sSearch, $hLV, ByRef $iCount, $idStatus, $idBtnCancel)
	Local $iIndex = 1
	While 1
		Local $sSubKey = RegEnumKey($sKey, $iIndex)
		If @error Then ExitLoop

		If Mod($iIndex, 100) = 0 Then
			GUICtrlSetData($idStatus, "Scanning: " & $iIndex & " keys in " & StringLeft($sKey, 40) & "...")
			If GUIGetMsg() = $idBtnCancel Then Return SetError(1)
		EndIf

		Local $sFull = $sKey & "\" & $sSubKey
		Local $sData = RegRead($sFull, "")

		If StringInStr($sSubKey, $sSearch) Or StringInStr($sData, $sSearch) Then
			$iCount += 1
			Local $sDisplayData = ($sData <> "" ? $sData : "Folder/Container")
			GUICtrlCreateListViewItem($sFull & "|" & $sDisplayData, $hLV)
			_GUICtrlListView_SetItemChecked($hLV, _GUICtrlListView_GetItemCount($hLV) - 1)
		EndIf

		__Registry_Scan_Recursive($sFull, $sSearch, $hLV, $iCount, $idStatus, $idBtnCancel)
		If @error Then Return SetError(1)

		$iIndex += 1
	WEnd
EndFunc   ;==>__Registry_Scan_Recursive

;---------------------------------------------------------------------------------------
Func __Delete_Checked_Items($hLV)
	; backwards deletion to avoid index shifting
	For $i = _GUICtrlListView_GetItemCount($hLV) - 1 To 0 Step -1
		If _GUICtrlListView_GetItemChecked($hLV, $i) Then
			Local $sKeyPath = _GUICtrlListView_GetItemText($hLV, $i)
			If RegDelete($sKeyPath) Then
				ConsoleWrite("[-] Deleted: " & $sKeyPath & @CRLF)
			EndIf
		EndIf
	Next
EndFunc   ;==>__Delete_Checked_Items
;---------------------------------------------------------------------------------------
