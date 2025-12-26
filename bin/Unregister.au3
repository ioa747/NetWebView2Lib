#RequireAdmin
#include <MsgBoxConstants.au3>

; === Configuration ===
Local $sDllName = "NetWebView2Lib.dll"
Local $sTlbName = "NetWebView2Lib.tlb"
Local $sNet4_x86 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe"
Local $sNet4_x64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe"

Local $sLog = "Unregistration Report:" & @CRLF & "----------------------" & @CRLF

; === Unregister x86 ===
If FileExists($sNet4_x86) Then
    Local $iExitCode = RunWait('"' & $sNet4_x86 & '" /u "' & @ScriptDir & '\' & $sDllName & '"', @ScriptDir, @SW_HIDE)
    $sLog &= ($iExitCode = 0 ? "[+] x86 Unregistration: SUCCESS" : "[-] x86 Unregistration: FAILED") & @CRLF
EndIf

; === Unregister x64 ===
If FileExists($sNet4_x64) Then
    Local $iExitCode = RunWait('"' & $sNet4_x64 & '" /u "' & @ScriptDir & '\' & $sDllName & '"', @ScriptDir, @SW_HIDE)
    $sLog &= ($iExitCode = 0 ? "[+] x64 Unregistration: SUCCESS" : "[-] x64 Unregistration: FAILED") & @CRLF
EndIf


MsgBox($MB_ICONINFORMATION, "Cleanup Complete", $sLog)