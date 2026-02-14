#RequireAdmin
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Tidy_Parameters=/reel

#include <MsgBoxConstants.au3>
#include "..\NetWebView2Lib.au3"

_Register()

Func _Register()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	; === Configuration ===
	Local $sDllName = "NetWebView2Lib.dll"
	Local $sNet4_x86 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe"
	Local $sNet4_x64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe"

	Local $bSuccess = False
	Local $sLog = "Registration Report:" & @CRLF & "--------------------" & @CRLF

	; === Check for WebView2 Runtime ===
	Local $sWV2Version = WebView2Exist()

	If $sWV2Version <> "" Then
		$sLog &= "[+] WebView2 Runtime: Found (" & $sWV2Version & ")" & @CRLF
	Else
		Local $sUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
		$sLog &= "[-] WebView2 Runtime: NOT FOUND" & @CRLF

		; Ask the user to install
		Local $iAnswer = MsgBox($MB_YESNO + $MB_ICONEXCLAMATION, "Runtime Missing", _
				"The Microsoft Edge WebView2 Runtime is required to run this application." & @CRLF & @CRLF & _
				"Would you like to open the download page now?" & @CRLF & @CRLF & _
				"Note: Please return and click YES after the installation is complete.")

		If $iAnswer = $IDYES Then
			ShellExecute($sUrl)
			; Wait for user confirmation that installation is done
			MsgBox($MB_ICONINFORMATION, "Waiting", "Click OK once the WebView2 installation is finished to proceed with DLL registration.")
		Else
			$sLog &= "[!] User skipped WebView2 installation. Aborting." & @CRLF
			MsgBox($MB_ICONSTOP, "Aborted", "Registration cannot continue without WebView2 Runtime.")
			Exit ; Stop the script
		EndIf
	EndIf

	; === Registration 'NetWebView2Lib.dll' COM ===
	Local $iExitCode

	; Registration for x86 (32-bit)
	If FileExists($sNet4_x86) Then
		$iExitCode = RunWait('"' & $sNet4_x86 & '" "' & @ScriptDir & '\' & $sDllName & '" /codebase /tlb', @ScriptDir, @SW_HIDE)
		If $iExitCode = 0 Then
			$sLog &= "[+] x86 Registration: SUCCESS" & @CRLF
			$bSuccess = True
		Else
			$sLog &= "[-] x86 Registration: FAILED (Code: " & $iExitCode & ")" & @CRLF
		EndIf
	Else
		$sLog &= "[!] x86 RegAsm not found" & @CRLF
	EndIf

	; Registration for x64 (64-bit)
	If FileExists($sNet4_x64) Then
		$iExitCode = RunWait('"' & $sNet4_x64 & '" "' & @ScriptDir & '\' & $sDllName & '" /codebase /tlb', @ScriptDir, @SW_HIDE)
		If $iExitCode = 0 Then
			$sLog &= "[+] x64 Registration: SUCCESS" & @CRLF
			$bSuccess = True
		Else
			$sLog &= "[-] x64 Registration: FAILED (Code: " & $iExitCode & ")" & @CRLF
		EndIf
	Else
		$sLog &= "[!] x64 RegAsm not found" & @CRLF
	EndIf

	; === Final Message ===
	If $bSuccess Then
		MsgBox($MB_ICONINFORMATION, "Registration Complete", $sLog)
	Else
		MsgBox($MB_ICONERROR, "Registration Error", "Library registration failed." & @CRLF & @CRLF & $sLog)
	EndIf

EndFunc   ;==>_Register

;---------------------------------------------------------------------------------------
Func WebView2Exist()
	Local $aKeys[3] = [ _
			"HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients", _
			"HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients", _
			"HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\Clients" _
			]
	Local $sSubKey, $sName, $sPv, $iIndex

	For $sRootKey In $aKeys
		For $iIndex = 1 To 500
			$sSubKey = RegEnumKey($sRootKey, $iIndex)
			If @error Then ExitLoop ; No more keys
			$sName = RegRead($sRootKey & "\" & $sSubKey, "name")
			If $sName = "Microsoft Edge WebView2 Runtime" Then
				$sPv = RegRead($sRootKey & "\" & $sSubKey, "pv")
				If $sPv <> "" Then Return $sPv ; Found it
			EndIf
		Next
	Next

	Local $sSysPathX86 = @WindowsDir & "\System32\Microsoft-Edge-WebView\EBWebView\x86\EmbeddedBrowserWebView.dll"
	Local $sSysPathX64 = @WindowsDir & "\System32\Microsoft-Edge-WebView\EBWebView\x64\EmbeddedBrowserWebView.dll"

	If FileExists($sSysPathX86) Or FileExists($sSysPathX64) Then
		Return "Detected via System Files"
	EndIf

	Return "" ; Not found
EndFunc   ;==>WebView2Exist
