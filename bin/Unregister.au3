#RequireAdmin
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Tidy_Parameters=/reel

#include <MsgBoxConstants.au3>
#include "..\NetWebView2Lib.au3"

; Unregister.au3

_Unregister()

Func _Unregister()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	; === Configuration ===
	Local $sDllName = "NetWebView2Lib.dll"
	Local $sTlbName = "NetWebView2Lib.tlb"
	#forceref $sTlbName

	Local $sNet4_x86 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe"
	Local $sNet4_x64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe"

	Local $sLog = "Unregistration Report:" & @CRLF & "----------------------" & @CRLF
	Local $iExitCode

	; === Unregister x86 ===
	If FileExists($sNet4_x86) Then
		$iExitCode = RunWait('"' & $sNet4_x86 & '" /u "' & @ScriptDir & '\x86\' & $sDllName & '"', @ScriptDir, @SW_HIDE)
		$sLog &= ($iExitCode = 0 ? "[+] x86 Unregistration: SUCCESS" : "[-] x86 Unregistration: FAILED") & @CRLF
	EndIf

	; === Unregister x64 ===
	If FileExists($sNet4_x64) Then
		$iExitCode = RunWait('"' & $sNet4_x64 & '" /u "' & @ScriptDir & '\x64\' & $sDllName & '"', @ScriptDir, @SW_HIDE)
		$sLog &= ($iExitCode = 0 ? "[+] x64 Unregistration: SUCCESS" : "[-] x64 Unregistration: FAILED") & @CRLF
	EndIf

	MsgBox($MB_ICONINFORMATION, "Unregistration process completed", $sLog)
EndFunc   ;==>_Unregister
