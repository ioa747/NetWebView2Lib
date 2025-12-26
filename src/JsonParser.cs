using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

namespace NetWebView2Lib
{


    /// <summary>
    /// COM interface for JsonParser class.
    /// </summary> 
    [Guid("D1E2F3A4-B5C6-4D7E-8F9A-0B1C2D3E4F5A")]
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
        /// Updates or adds a value at the specified path (only for JObject).
        /// </summary>
        public void SetTokenValue(string path, string value)
        {
            try
            {
                if (_jsonObj != null)
                {
                    _jsonObj[path] = value;
                }
            }
            catch { /* Handle or log error if needed */ }
        }


        /// <summary>
        /// Returns the count of elements if the JSON is an array.
        /// </summary>
        public int GetArrayLength(string path)
        {
            try
            {
                // If path is empty, check which root container is active
                if (string.IsNullOrEmpty(path) || path == "$")
                {
                    if (_jsonArray != null) return _jsonArray.Count;
                    if (_jsonObj != null) return 0; // It's an object, not an array
                }

                // If path is provided, use the active container to find the token
                JToken root = (_jsonArray != null) ? (JToken)_jsonArray : (JToken)_jsonObj;
                if (root == null) return 0;

                var token = root.SelectToken(path);
                return (token is JArray arr) ? arr.Count : 0;
            }
            catch { return 0; }
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

    }
}