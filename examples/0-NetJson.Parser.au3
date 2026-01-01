;~ #AutoIt3Wrapper_UseX64=y

; NetWebView2Lib.JsonParser - Tutorial Script

#include <MsgBoxConstants.au3>

; Global objects handler for COM objects
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc")

; Initialize the COM Object
Local $oJson = ObjCreate("NetJson.Parser")
If Not IsObj($oJson) Then
    MsgBox(16, "Error", "Could not create NetWebView2Lib.JsonParser. Make sure the DLL is registered.")
    Exit
EndIf

ConsoleWrite("=== STARTING NETJSON TUTORIAL ===" & @CRLF)

; ---------------------------------------------------------
 ConsoleWrite("+> 1. PARSING & BASICS <+" & @CRLF)
; ---------------------------------------------------------
Local $sRaw = '{"user": "John", "roles": ["Admin", "Tester"], "active": true}'
$oJson.Parse($sRaw)
ConsoleWrite("Full JSON: " & $oJson.GetJson() & @CRLF)

; Check if a path exists
If $oJson.Exists("user") Then
    ConsoleWrite("- User exists: " & $oJson.GetTokenValue("user") & @CRLF)
EndIf

; ---------------------------------------------------------
 ConsoleWrite("+> 2. ARRAY OPERATIONS <+" & @CRLF)
; ---------------------------------------------------------
; Get length of the 'roles' array
Local $iRolesCount = $oJson.GetArrayLength("roles")
ConsoleWrite("- Roles count: " & $iRolesCount & @CRLF)

; Get specific element from array
ConsoleWrite("- First role: " & $oJson.GetTokenValue("roles[0]") & @CRLF)

; ---------------------------------------------------------
 ConsoleWrite("+> 2b. DEEP PATH NOTATION (The Power of JSON Path) <+" & @CRLF)
; ---------------------------------------------------------
Local $sComplex = '{"store": {"book": [{"title": "Coding 101", "price": 10}, {"title": "AutoIt Guru", "price": 25}], "location": "Athens"}}'
$oJson.Parse($sComplex)

; Direct access to a deep value using dots and brackets
; Path: store -> book -> second element [1] -> title
Local $sTitle = $oJson.GetTokenValue("store.book[1].title")
Local $iPrice = $oJson.GetTokenValue("store.book[1].price")

ConsoleWrite("- Deep Search (Title): " & $sTitle & @CRLF)
ConsoleWrite("- Deep Search (Price): " & $iPrice & @CRLF)

; Check existence of a deep path
If $oJson.Exists("store.location") Then
    ConsoleWrite("- Store Location: " & $oJson.GetTokenValue("store.location") & @CRLF)
EndIf

; ---------------------------------------------------------
 ConsoleWrite("+> 3. MODIFICATION (SetTokenValue) <+" & @CRLF)
; ---------------------------------------------------------
$oJson.SetTokenValue("user", "George")
$oJson.SetTokenValue("active", "false") ; Note: Values are sent as strings
ConsoleWrite("- Updated User: " & $oJson.GetTokenValue("user") & @CRLF)

; ---------------------------------------------------------
 ConsoleWrite("+> 4. FILE I/O <+" & @CRLF)
; ---------------------------------------------------------
; Save current state to a file
$oJson.SaveToFile(@ScriptDir & "\settings.json")
ConsoleWrite("JSON saved to file." & @CRLF)

; Clear and Reload from file
$oJson.Clear()
ConsoleWrite("- After Clear, Json is: " & $oJson.GetJson() & @CRLF)

$oJson.LoadFromFile(@ScriptDir & "\settings.json")
ConsoleWrite("- Reloaded from file, User is: " & $oJson.GetTokenValue("user") & @CRLF)

; ---------------------------------------------------------
 ConsoleWrite("+> 5. FORMATTING (Pretty vs Minified) <+" & @CRLF)
; ---------------------------------------------------------
ConsoleWrite(@CRLF & "--- PRETTY JSON ---" & @CRLF)
ConsoleWrite($oJson.GetPrettyJson() & @CRLF)

ConsoleWrite(@CRLF & "--- MINIFIED JSON ---" & @CRLF)
ConsoleWrite($oJson.GetMinifiedJson() & @CRLF)

; ---------------------------------------------------------
 ConsoleWrite("+> 6. ESCAPING TOOLS (Utility Methods) <+" & @CRLF)
; ---------------------------------------------------------
Local $sDirtyString = 'Hello "World" \ Name'
Local $sEscaped = $oJson.EscapeString($sDirtyString)
ConsoleWrite("- Escaped: " & $sEscaped & @CRLF)
ConsoleWrite("- Unescaped: " & $oJson.UnescapeString($sEscaped) & @CRLF)

ConsoleWrite("--- TUTORIAL COMPLETED ---" & @CRLF)

; Clean up object
$oJson = Null

; ---------------------------------------------------------

Func _ErrFunc($oError) ; User's COM error function. Will be called if COM error occurs
	; Do anything here.
	ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
