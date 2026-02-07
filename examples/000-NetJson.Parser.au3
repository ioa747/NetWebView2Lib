;~ #AutoIt3Wrapper_UseX64=y

; NetWebView2Lib.JsonParser - Tutorial Script

#include <Array.au3>
#include <MsgBoxConstants.au3>

; Global objects handler for COM objects
Global $oMyError = ObjEvent("AutoIt.Error", _ErrFunc)


_Example()
Exit

Func _Example()
	; Initialize the COM Object
	Local $oJson = ObjCreate("NetJson.Parser")
	If Not IsObj($oJson) Then
		MsgBox(16, "Error", "Could not create NetWebView2Lib.JsonParser. Make sure the DLL is registered.")
		Return
	EndIf

	ConsoleWrite(@CRLF & "=== STARTING NETJSON TUTORIAL ===" & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 1. PARSING & BASICS <+" & @CRLF)
	; ---------------------------------------------------------
	Local $sRaw = '{"user": "John", "roles": ["Admin", "Tester"], "active": true}'
	$oJson.Parse($sRaw)
	ConsoleWrite("Full JSON: " & $oJson.GetJson() & @CRLF)

	; Check if a path exists
	If $oJson.Exists("user") Then
		ConsoleWrite("- User exists: " & $oJson.GetTokenValue("user") & @CRLF)
	EndIf

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 2. ARRAY OPERATIONS <+" & @CRLF)
	; ---------------------------------------------------------
	; Get length of the 'roles' array
	Local $iRolesCount = $oJson.GetArrayLength("roles")
	ConsoleWrite("- Roles count: " & $iRolesCount & @CRLF)

	; Get specific element from array
	ConsoleWrite("- First role: " & $oJson.GetTokenValue("roles[0]") & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 2b. DEEP PATH NOTATION (The Power of JSON Path) <+" & @CRLF)
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
	ConsoleWrite(@CRLF & "+> 3. MODIFICATION (SetTokenValue) <+" & @CRLF)
	; ---------------------------------------------------------
	$oJson.SetTokenValue("user", "George")
	$oJson.SetTokenValue("active", "false") ; Note: Values are sent as strings
	ConsoleWrite("- Updated User: " & $oJson.GetTokenValue("user") & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 4. FILE I/O <+" & @CRLF)
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
	ConsoleWrite(@CRLF & "+> 5. FORMATTING (Pretty vs Minified) <+" & @CRLF)
	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "--- PRETTY JSON ---" & @CRLF)
	ConsoleWrite($oJson.GetPrettyJson() & @CRLF)

	ConsoleWrite(@CRLF & "--- MINIFIED JSON ---" & @CRLF)
	ConsoleWrite($oJson.GetMinifiedJson() & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 6. ESCAPING TOOLS (Utility Methods) <+" & @CRLF)
	; ---------------------------------------------------------
	Local $sDirtyString = 'Hello "World" \ Name'
	Local $sEscaped = $oJson.EscapeString($sDirtyString)
	ConsoleWrite("- Escaped: " & $sEscaped & @CRLF)
	ConsoleWrite("- Unescaped: " & $oJson.UnescapeString($sEscaped) & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7. ADVANCED DATA INTELLIGENCE (v1.4.1) <+" & @CRLF)
	; ---------------------------------------------------------

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.1 MERGE EXAMPLE <+" & @CRLF)
	; ---------------------------------------------------------
	; Let's merge some new data into our current JSON
	Local $sUpdate = '{"user": "Admin_SmartUser", "preferences": {"theme": "Dark", "notifications": true}}'
	$oJson.Merge($sUpdate)
	ConsoleWrite("- After Merge (User Updated & Prefs Added): " & $oJson.GetTokenValue("user") & @CRLF)
	ConsoleWrite("- New Nested Value: " & $oJson.GetTokenValue("preferences.theme") & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.2 TYPE CHECKING <+" & @CRLF)
	; ---------------------------------------------------------
	; Check what kind of data we have at a specific path
	Local $sThemeType = $oJson.GetTokenType("preferences")
	Local $sUserType = $oJson.GetTokenType("user")
	ConsoleWrite("- 'preferences' type: " & $sThemeType & @CRLF) ; Should return Object
	ConsoleWrite("- 'user' type: " & $sUserType & @CRLF)    ; Should return String

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.3 SEARCH (JSONPath) <+" & @CRLF)
	; ---------------------------------------------------------
	; $..* Returns everything in a flat list (all values).
	; $.store.book[*].author Returns all authors in the book array.
	; $..book[0] Returns the first book, wherever the book array is.
	; $..price Returns all prices from all objects.
	; Let's find all titles in our store (from section 2b)
	Local $sTitlesFound = $oJson.Search("$..title")
	ConsoleWrite("- Search results (All Titles): " & $sTitlesFound & @CRLF)

	; Query Explanation:
	; $..book -> Search everywhere for the array "book"
	; [?(@.price > 15)] -> Filter the objects where the price property is > 15
	; .title -> Of the ones found, return only the title
	Local $sExpensiveBooks = $oJson.Search("$..book[?(@.price > 15)].title")

	ConsoleWrite("- Books pricier than 15: " & $sExpensiveBooks & @CRLF)
	; Expected result: ["AutoIt Guru"]
	Local $sFullObjects = $oJson.Search("$..book[?(@.price > 15)]")
	ConsoleWrite("- Full Objects : " & $sFullObjects & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.4 FLATTEN <+" & @CRLF)
	; ---------------------------------------------------------
	; Convert the complex nested structure into a flat key-value list
	Local $sFlatJson = $oJson.Flatten()
	ConsoleWrite("- FLATTENED VIEW (Key.Path = Value)" & @CRLF)
	ConsoleWrite($sFlatJson & @CRLF)

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.5 REMOVE TOKEN <+" & @CRLF)
	; ---------------------------------------------------------
	; Remove the 'preferences' object completely
	Local $bRemoved = $oJson.RemoveToken("preferences")

	If $bRemoved Then
		ConsoleWrite("- 'preferences' removal command sent." & @CRLF)
	Else
		ConsoleWrite("! Error: Path 'preferences' not found to remove." & @CRLF)
	EndIf

	If $oJson.Exists("preferences") Then
		ConsoleWrite("! Verify existence: Still there (Something went wrong)" & @CRLF)
		ConsoleWrite("! Current JSON: " & $oJson.GetMinifiedJson() & @CRLF)
	Else
		ConsoleWrite("- Verify existence: Gone! (Success)" & @CRLF)
	EndIf

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.6 CLONE LOGIC <+" & @CRLF)
	; ---------------------------------------------------------
	; Check if we can backup our data
	If $oJson.CloneTo("BackupInstance") Then
		ConsoleWrite("- Data integrity check for cloning: OK" & @CRLF)
	EndIf

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "+> 7.7 FLATTEN TO TABLE (_ArrayFromString ready) <+" & @CRLF)
	; ---------------------------------------------------------
	Local $sTable = $oJson.FlattenToTable("|", @CRLF)
	Local $aFinalGrid = _ArrayFromString($sTable, "|", @CRLF, True)

	If Not @error Then
		ConsoleWrite("- Array successfully created from FlattenToTable!" & @CRLF)
		;_ArrayDisplay($aFinalGrid, "v1.4.1 Final Table View")
		For $i = 0 To UBound($aFinalGrid) - 1
			ConsoleWrite($i & ") " & $aFinalGrid[$i][0] & " = " & $aFinalGrid[$i][1] & @CRLF)
		Next
	EndIf

	; ---------------------------------------------------------
	ConsoleWrite(@CRLF & "--- TUTORIAL COMPLETED ---" & @CRLF)
	; ---------------------------------------------------------
	; Clean up object
	$oJson = Null

	; ---------------------------------------------------------

EndFunc   ;==>_Example

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
