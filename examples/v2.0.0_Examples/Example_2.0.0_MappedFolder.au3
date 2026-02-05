#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; Example_2.0.0_MappedFolder.au3
; Demonstrates Virtual Host Mapping, Binary Encoding, and Script Management.

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\..\NetWebView2Lib.au3"

Opt("GUIOnEventMode", 1)
OnAutoItExitRegister("_ExitApp")

Global $oWeb, $hGUI, $sProfile = @ScriptDir & "\UserDataFolder"
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc")

_Main()

Func _Main()
    $hGUI = GUICreate("NetWebView2Lib v2.0.0 - MappedFolder Demo", 1000, 600)
    GUISetOnEvent($GUI_EVENT_CLOSE, "_ExitApp")

    $oWeb = ObjCreate("NetWebView2.Manager")

    ; First Initialize
    $oWeb.Initialize(($hGUI), $sProfile, 0, 0, 0, 0)

    ; Waiting for Ready
    While Not $oWeb.IsReady
        Sleep(10)
    WEnd

    ; Now that it is Ready, we define Mapping & Scripts
    Local $sLocalFolder = @ScriptDir & "\MappedFolder"
    $oWeb.SetVirtualHostNameToFolderMapping("myapp.local", $sLocalFolder, 0)

;~     ; Add Script (Now it will return a normal ID and not an Error)
;~     Local $sScriptId = $oWeb.AddInitializationScript("window.onload = function() { if(window.setScriptStatus) window.setScriptStatus('Script Running (v2.0.0 Ready)'); };")
;~     ConsoleWrite("+++ [Script Management]: Added Init Script. ID: " & $sScriptId & @CRLF)

    ; Finish Navigate
    $oWeb.Navigate("https://myapp.local/index.html")
	Sleep(1500)

    GUISetState(@SW_SHOW)

    While 1
        Sleep(100)
    WEnd
EndFunc

Func _ErrFunc($oError)
    ConsoleWrite('@@ COM Error: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc

Func _ExitApp()
    If IsObj($oWeb) Then $oWeb.Cleanup()
    $oWeb = 0
    Exit
EndFunc
