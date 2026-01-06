
---

1. Finding Elements (Selectors)

| **Command**                        | **Description**                                       |
| ---------------------------------- | ----------------------------------------------------- |
| `document.querySelector('.class')` | Finds the **first** element with this specific class. |
| `document.querySelectorAll('a')`   | Finds **all** links (returns a list/collection).      |
| `element.parentElement`            | Moves one level up to the element's "parent".         |

2. Extracting Text & Content

| **Command**                    | **Description**                                |
| ------------------------------ | ---------------------------------------------- |
| `element.innerText`            | Gets only the visible, clean text.             |
| `element.innerHTML`            | Gets the entire HTML code inside the element.  |
| `element.getAttribute('href')` | Retrieves the URL address of a link.           |
| `element.value`                | Retrieves text from an Input Box or Textarea.  |

3. Data Cleaning (Strings)

| **Command**          | **Description**                                                               |
| -------------------- | ----------------------------------------------------------------------------- |
| `.trim()`            | Removes whitespace from start and end (Similar to `StringStripWS` in AutoIt). |
| `.replace('A', 'B')` | Replaces text (Similar to `StringReplace`).                                   |
| `.split('\n')`       | Splits text into an array based on new lines.                                 |

4. Communication with AutoIt

| **Command**                               | **Description**                                                        |
| ----------------------------------------- | ---------------------------------------------------------------------- |
| `window.chrome.webview.postMessage(data)` | **The most important:** Sends the `data` to the AutoIt Event handler.  |

---

💡 The "Magic" Snippet for Table Scraping

If you find a table and want to extract all its data, use this code as your primary template:

JavaScript

```
// 
var results = [];
// 1. Find all rows
var rows = document.querySelectorAll('table tr');

rows.forEach(row => {
 // 2. Find cells for each row
 var cells = row.querySelectorAll('td');
   
 if (cells.length > 0) {
 // 3. Format the data structure (e.g., Column1 | Column2)
 var line = cells[0].innerText.trim() + " | " + cells[1].innerText.trim();
 results.push(line);
 }
});

// 4. Send everything back to AutoIt
window.chrome.webview.postMessage(results.join('\n'));
```

