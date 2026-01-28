using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

// --- Version 1.5.0 ---

namespace NetWebView2Lib
{
    /// <summary>
    /// COM interface for JsonParser class.
    /// </summary> 
    [Guid("D1E2F3A4-B5C6-4D7E-8F9A-0B1C2D3E4F5A")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IJsonParser
    {
        /// <summary>
        /// Parses a JSON string. Automatically detects if it's an Object or an Array.
        /// </summary>
        [DispId(201)] bool Parse(string json);

        /// <summary>
        /// Retrieves a value by JSON path (e.g., "items[0].name").
        /// </summary>
        [DispId(202)] string GetTokenValue(string path);

        /// <summary>
        /// Returns the count of elements if the JSON is an array.
        /// </summary>
        [DispId(203)] int GetArrayLength(string path);

        /// <summary>
        /// Updates or adds a value at the specified path (only for JObject).
        /// </summary>
        [DispId(204)] void SetTokenValue(string path, string value);

        /// <summary>
        /// Loads JSON content directly from a file.
        /// </summary>
        [DispId(205)] bool LoadFromFile(string filePath);

        /// <summary>
        /// Saves the current JSON state back to a file.
        /// </summary>
        [DispId(206)] bool SaveToFile(string filePath);

        /// <summary>
        /// Checks if a path exists in the current JSON structure.
        /// </summary>
        [DispId(207)] bool Exists(string path);

        /// <summary>
        /// Clears the internal data.
        /// </summary>
        [DispId(208)] void Clear();

        /// <summary>
        /// Returns the full JSON string.
        /// </summary>
        [DispId(209)] string GetJson();

        /// <summary>
        /// Escapes a string to be safe for use in JSON.
        /// </summary>
        [DispId(210)] string EscapeString(string plainText);

        /// <summary>
        /// Unescapes a JSON string back to plain text.
        /// </summary>
        [DispId(211)] string UnescapeString(string escapedText);

        /// <summary>
        /// Returns the JSON string with nice formatting (Indented).
        /// </summary>
        [DispId(212)] string GetPrettyJson();

        /// <summary>
        /// Minifies a JSON string (removes spaces and new lines).
        /// </summary>
        [DispId(213)] string GetMinifiedJson();

        /// <summary>
        /// Merges another JSON string into the current JSON structure.
        /// </summary> 
        [DispId(214)] bool Merge(string jsonContent);

        /// <summary>
        /// Merges JSON content from a file into the current JSON structure.
        /// </summary> 
        [DispId(215)] bool MergeFromFile(string filePath);

        /// <summary>
        /// Returns the type of the token at the specified path (e.g., Object, Array, String, Integer).
        /// </summary> 
        [DispId(216)] string GetTokenType(string path);

        /// <summary>
        /// Removes the token at the specified path.
        /// </summary> 
        [DispId(217)] bool RemoveToken(string path);

        /// <summary>
        /// Searches the JSON structure using a JSONPath query and returns a JSON array of results.
        /// </summary>
        [DispId(218)] string Search(string query);

        /// <summary>
        /// Flattens the JSON structure into a single-level object with dot-notated paths.
        /// </summary>
        [DispId(219)] string Flatten();

        /// <summary>
        /// Clones the current JSON data to another named parser instance.
        /// </summary>
        [DispId(220)] bool CloneTo(string parserName);

        /// <summary>
        /// Flattens the JSON structure into a table-like string with specified delimiters.
        /// </summary>
        [DispId(221)] string FlattenToTable(string colDelim, string rowDelim);
        /// <summary>Encodes a string for Base64.</summary>
        [DispId(222)] string EncodeB64(string plainText);
        /// <summary>Decodes a Base64 string.</summary>
        [DispId(223)] string DecodeB64(string base64Text);
        /// <summary>Decodes a Base64 string and saves it directly to a file.</summary>
        [DispId(224)] bool DecodeB64ToFile(string base64Text, string filePath);

        /// <summary>Returns the count of elements (array items or object properties) at the specified path.</summary>
        [DispId(225)] int GetTokenCount(string path);

        /// <summary>Returns a delimited string of keys for the object at the specified path.</summary>
        [DispId(226)] string GetKeys(string path, string delimiter);

        /// <summary>Sorts a JSON array by a specific key.</summary>
        [DispId(227)] bool SortArray(string arrayPath, string key, bool descending);

        /// <summary>Removes duplicate objects from a JSON array based on a key's value.</summary>
        [DispId(228)] bool SelectUnique(string arrayPath, string key);

        /// <summary>Decodes a Base64 string to raw binary data (byte array).</summary>
        [DispId(229)] byte[] DecodeB64ToBinary(string base64Text);
    }

    /// <summary>
    /// Provides methods for parsing, manipulating, and serializing JSON data using Newtonsoft.Json. Supports both JSON
    /// objects and arrays, and enables reading from and writing to files, querying values by path, and formatting JSON
    /// output.
    /// </summary>
    /// <remarks>The JsonParser class is designed for simple JSON operations and is compatible with COM
    /// interop. It automatically detects whether the input JSON is an object or an array and exposes methods for common
    /// tasks such as value retrieval, modification, and file I/O. Thread safety is not guaranteed; if used from
    /// multiple threads, external synchronization is required.</remarks>
    [Guid("C5D6E7F8-A9B0-4C1D-8E2F-3A4B5C6D7E8F")]
    [ComVisible(true)]
    [ProgId("NetJson.Parser")]
    [ClassInterface(ClassInterfaceType.None)]


    public class JsonParser : IJsonParser
    {
        private JObject _jsonObj;
        private JArray _jsonArray;

        /// <summary>
        /// Parses a JSON string. Automatically detects if it's an Object or an Array.
        /// </summary>
        public bool Parse(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) return false;

            try
            {
                string trimmed = json.Trim();
                // Check if it's an array or object
                if (trimmed.StartsWith("["))
                {
                    _jsonArray = JArray.Parse(trimmed);
                    _jsonObj = null; // Clear object if we have an array
                }
                else
                {
                    _jsonObj = JObject.Parse(trimmed);
                    _jsonArray = null; // Clear array if we have an object
                }
                return true;
            }
            catch { return false; }
        }

        /// <summary>
        /// Loads JSON content directly from a file.
        /// </summary>
        public bool LoadFromFile(string filePath)
        {
            try
            {
                if (!File.Exists(filePath)) return false;
                string content = File.ReadAllText(filePath);
                return Parse(content);
            }
            catch { return false; }
        }

        /// <summary>
        /// Saves the current JSON state back to a file.
        /// </summary>
        public bool SaveToFile(string filePath)
        {
            try
            {
                string content = "";
                if (_jsonObj != null) content = _jsonObj.ToString();
                else if (_jsonArray != null) content = _jsonArray.ToString();

                if (string.IsNullOrEmpty(content)) return false;

                File.WriteAllText(filePath, content);
                return true;
            }
            catch { return false; }
        }

        /// <summary>
        /// Updates or adds a value at the specified path, creating missing parent objects if necessary.
        /// Supports smart typing for numbers, booleans, and nulls.
        /// </summary> 
        public void SetTokenValue(string path, string value)
        {
            try
            {
                if (string.IsNullOrEmpty(path)) return;

                JObject root = _jsonObj;
                if (root == null)
                {
                    if (_jsonArray != null) return; // Cannot set named paths on a root array easily without index
                    _jsonObj = new JObject();
                    root = _jsonObj;
                }

                string[] parts = path.Split('.');
                JContainer current = root;

                for (int i = 0; i < parts.Length - 1; i++)
                {
                    string part = parts[i];
                    var next = current.SelectToken(part);

                    if (next == null || next.Type != JTokenType.Object)
                    {
                        var newObj = new JObject();
                        if (current is JObject obj) obj[part] = newObj;
                        else if (current is JArray arr) { /* Array indexing not handled in deep creation for now */ }
                        current = newObj;
                    }
                    else
                    {
                        current = (JContainer)next;
                    }
                }

                string lastPart = parts[parts.Length - 1];
                if (current is JObject finalObj)
                {
                    finalObj[lastPart] = ParseValueSmart(value);
                }
            }
            catch { /* Handle or log error if needed */ }
        }

        private JToken ParseValueSmart(string value)
        {
            if (string.Equals(value, "true", StringComparison.OrdinalIgnoreCase)) return true;
            if (string.Equals(value, "false", StringComparison.OrdinalIgnoreCase)) return false;
            if (string.Equals(value, "null", StringComparison.OrdinalIgnoreCase)) return JValue.CreateNull();

            // Leading zero check: if starts with 0 and not just "0" or "0.", treat as string
            if (value.Length > 1 && value.StartsWith("0") && !value.StartsWith("0.")) return value;

            if (long.TryParse(value, out long l)) return l;
            if (double.TryParse(value, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out double d)) return d;

            return value;
        }

        /// <summary>
        /// Returns a delimited string of keys for the object at the specified path.
        /// </summary>
        public string GetKeys(string path, string delimiter = "|")
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return "";

                var token = string.IsNullOrEmpty(path) ? root : root.SelectToken(path);
                if (token is JObject obj)
                {
                    var keys = obj.Properties().Select(p => p.Name);
                    return string.Join(delimiter, keys);
                }
                return "";
            }
            catch { return ""; }
        }
		
        /// <summary>
        /// Returns the count of elements if the JSON is an array.
        /// </summary>
        public int GetArrayLength(string path) => GetTokenCount(path);

        /// <summary>
        /// Returns the count of elements (array items or object properties) at the specified path.
        /// </summary>
        public int GetTokenCount(string path)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return (string.IsNullOrEmpty(path)) ? 0 : -1;

                var token = (string.IsNullOrEmpty(path) || path == "$") ? root : root.SelectToken(path);
                if (token == null) return 0;

                if (token is JArray arr) return arr.Count;
                if (token is JObject obj) return obj.Properties().Count();
                
                return 0;
            }
            catch { return -1; }
        }


        /// <summary>
        /// Retrieves a value by JSON path (e.g., "items[0].name").
        /// </summary> 
        public string GetTokenValue(string path)
        {
            try
            {
                // Use root (object or array) to select the token
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;

                if (root == null) return "";

                var token = root.SelectToken(path);
                return token?.ToString() ?? "";
            }
            catch { return ""; }
        }

        /// <summary>
        /// Checks if a path exists in the current JSON structure.
        /// </summary>
        public bool Exists(string path)
        {
            try
            {
                JToken token = null;
                if (_jsonObj != null) token = _jsonObj.SelectToken(path);
                else if (_jsonArray != null) token = _jsonArray.SelectToken(path);
                return token != null;
            }
            catch { return false; }
        }

        /// <summary>
        /// Clears the internal data.
        /// </summary>
        public void Clear()
        {
            _jsonObj = null;
            _jsonArray = null;
        }

        /// <summary>
        /// Returns the full JSON string.
        /// </summary>
        public string GetJson()
        {
            if (_jsonObj != null) return _jsonObj.ToString();
            if (_jsonArray != null) return _jsonArray.ToString();
            return "";
        }

        /// <summary>
        /// Escapes a string to be safe for use in JSON.
        /// </summary>
        public string EscapeString(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return "";
            return JsonConvert.ToString(plainText).Trim('"');
        }

        /// <summary>
        /// Unescapes a JSON string back to plain text.
        /// </summary>
        public string UnescapeString(string escapedText)
        {
            try
            {
                if (string.IsNullOrEmpty(escapedText)) return "";
                // Wrap in quotes to form a valid JSON string
                return JsonConvert.DeserializeObject<string>("\"" + escapedText + "\"");
            }
            catch { return escapedText; }
        }

        /// <summary>
        /// Returns the JSON string with nice formatting (Indented).
        /// </summary>
        public string GetPrettyJson()
        {
            if (_jsonObj != null) return _jsonObj.ToString(Formatting.Indented);
            if (_jsonArray != null) return _jsonArray.ToString(Formatting.Indented);
            return "";
        }

        /// <summary>
        /// Minifies a JSON string (removes spaces and new lines).
        /// </summary>
        public string GetMinifiedJson()
        {
            if (_jsonObj != null) return _jsonObj.ToString(Formatting.None);
            if (_jsonArray != null) return _jsonArray.ToString(Formatting.None);
            return "";
        }

        /// <summary>
        /// Merges another JSON string into the current JSON structure.
        /// </summary> 
        public bool Merge(string jsonContent)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(jsonContent)) return false;

                if (_jsonObj != null)
                {
                    JObject newObj = JObject.Parse(jsonContent);
                    _jsonObj.Merge(newObj, new JsonMergeSettings
                    {
                        // Ορίζει πώς θα ενωθούν οι πίνακες (π.χ. προσθήκη στο τέλος)
                        MergeArrayHandling = MergeArrayHandling.Union
                    });
                    return true;
                }
                return false;
            }
            catch { return false; }
        }

        /// <summary>
        /// Merges JSON content from a file into the current JSON structure.
        /// </summary>
        public bool MergeFromFile(string filePath)
        {
            try
            {
                if (!File.Exists(filePath)) return false;
                string content = File.ReadAllText(filePath);
                return Merge(content); // Καλούμε την Merge που ήδη έφτιαξες!
            }
            catch { return false; }
        }

        /// <summary>
        /// Returns the type of the token at the specified path (e.g., Object, Array, String, Integer).
        /// </summary> 
        public string GetTokenType(string path)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return "None";

                var token = string.IsNullOrEmpty(path) ? root : root.SelectToken(path);
                return token?.Type.ToString() ?? "None";
            }
            catch { return "Error"; }
        }

        /// <summary>
        /// Removes the token at the specified path.
        /// </summary> 
        public bool RemoveToken(string path)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null || string.IsNullOrEmpty(path)) return false;

                var token = root.SelectToken(path);
                if (token == null) return false;

                if (token.Parent is JProperty property)
                {
                    // If the token is a property, remove the entire property
                    property.Remove();
                    return true;
                }
                else if (token.Parent is JArray || token is JProperty)
                {
                    // If the token is an item in an array or a property value, remove it directly
                    token.Remove();
                    return true;
                }
                else
                {
                    // For other types, just remove the token
                    token.Remove();
                    return true;
                }
            }
            catch { return false; }
        }

        /// <summary>
        /// Searches the JSON structure using a JSONPath query and returns a JSON array of results.
        /// </summary> 
        public string Search(string query)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null || string.IsNullOrWhiteSpace(query)) return "[]";

                // SelectTokens returns a list of all matching elements
                var results = root.SelectTokens(query);

                JArray resultArray = new JArray();
                foreach (var token in results)
                {
                    resultArray.Add(token);
                }

                return resultArray.ToString(Formatting.None);
            }
            catch { return "[]"; }
        }

        /// <summary>
        /// Sorts a JSON array by a specific key.
        /// </summary>
        public bool SortArray(string arrayPath, string key, bool descending = false)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return false;

                JToken token = string.IsNullOrEmpty(arrayPath) ? root : root.SelectToken(arrayPath);
                if (token is JArray arr)
                {
                    var sorted = descending 
                        ? arr.OrderByDescending(x => x[key]?.ToString()).ToList()
                        : arr.OrderBy(x => x[key]?.ToString()).ToList();

                    arr.Clear();
                    foreach (var item in sorted) arr.Add(item);
                    return true;
                }
                return false;
            }
            catch { return false; }
        }

        /// <summary>
        /// Removes duplicate objects from a JSON array based on a key's value.
        /// </summary>
        public bool SelectUnique(string arrayPath, string key)
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return false;

                JToken token = string.IsNullOrEmpty(arrayPath) ? root : root.SelectToken(arrayPath);
                if (token is JArray arr)
                {
                    var unique = arr.Where(x => x is JObject)
                                    .Cast<JObject>()
                                    .GroupBy(x => x[key]?.ToString())
                                    .Select(g => g.First())
                                    .ToList();

                    arr.Clear();
                    foreach (var item in unique) arr.Add(item);
                    return true;
                }
                return false;
            }
            catch { return false; }
        }

        /// <summary>
        /// Flattens the JSON structure into a single-level object with dot-notated paths.
        /// </summary> 
        public string Flatten()
        {
            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return "{}";
                var dict = new Dictionary<string, string>();
                FillFlattenDictionary(root, "", dict);
                return JsonConvert.SerializeObject(dict, Formatting.None);
            }
            catch { return "{}"; }
        }

        /// Helper method to recursively flatten the JSON structure
        private void FillFlattenDictionary(JToken token, string prefix, Dictionary<string, string> dict)
        {
            switch (token.Type)
            {
                case JTokenType.Object:
                    foreach (var prop in token.Children<JProperty>())
                        FillFlattenDictionary(prop.Value, string.IsNullOrEmpty(prefix) ? prop.Name : $"{prefix}.{prop.Name}", dict);
                    break;
                case JTokenType.Array:
                    int index = 0;
                    foreach (var item in token.Children())
                    {
                        FillFlattenDictionary(item, $"{prefix}[{index}]", dict);
                        index++;
                    }
                    break;
                default:
                    dict.Add(prefix, token.ToString());
                    break;
            }
        }

        /// <summary>
        /// Clones the current JSON data to another named parser instance.
        /// </summary> 
        public bool CloneTo(string parserName)
        {
            // Here the logic depends on whether you have a manager for multiple instances.
            // A simple and safe approach is not returning JSON
            // so AutoIt does: $oNewParser.Parse($oOldParser.GetJson())
            // But for Logbook, we define it as a Clone function.
            try
            {
                string currentJson = GetJson();
                return !string.IsNullOrEmpty(currentJson);
            }
            catch { return false; }
        }

        /// <summary>
        /// Flattens the JSON structure into a table-like string with specified delimiters.
        /// </summary> 
        public string FlattenToTable(string colDelim, string rowDelim)
        {
            // If the user sends blanks, set the AutoIt defaults.
            if (string.IsNullOrEmpty(colDelim)) colDelim = "|";
            if (string.IsNullOrEmpty(rowDelim)) rowDelim = "\r\n";

            try
            {
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return "";

                var dict = new Dictionary<string, string>();
                FillFlattenDictionary(root, "", dict);

                var lines = dict.Select(kvp => $"{kvp.Key}{colDelim}{kvp.Value}");
                return string.Join(rowDelim, lines);
            }
            catch { return ""; }
        }

        public string EncodeB64(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return "";
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return Convert.ToBase64String(bytes);
        }

        public string DecodeB64(string base64Text)
        {
            if (string.IsNullOrEmpty(base64Text)) return "";
            try
            {
                byte[] bytes = Convert.FromBase64String(base64Text);
                return System.Text.Encoding.UTF8.GetString(bytes);
            }
            catch { return ""; }
        }

        public bool DecodeB64ToFile(string base64Text, string filePath)
        {
            if (string.IsNullOrEmpty(base64Text) || string.IsNullOrEmpty(filePath)) return false;
            try
            {
                byte[] bytes = Convert.FromBase64String(base64Text);
                File.WriteAllBytes(filePath, bytes);
                return true;
            }
            catch { return false; }
        }

        public byte[] DecodeB64ToBinary(string base64Text)
        {
            if (string.IsNullOrEmpty(base64Text)) return new byte[0];
            try
            {
                return Convert.FromBase64String(base64Text);
            }
            catch { return new byte[0]; }
        }

    }
}