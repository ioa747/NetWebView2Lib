**Current Version:** 1.3.0 (2025-12-25)

---

## Version 1.3.0  - (2025-12-25)

### Added

- **Multi-Instance Support**: Added the ability to create and manage multiple independent WebView2 instances within the same AutoIt application.
    
- **Extension Support**: Introduced the `AddExtension` method, allowing the loading of unpacked browser extensions (Manifest V2 and V3) per instance.
    
- **Independent User Profiles**: Each instance now supports a unique `UserDataFolder`, enabling isolated cookies, cache, and browser history (e.g., `Profile_1`, `Profile_2`).
    
- **Context Menu Control**: Added `SetContextMenuEnabled` to programmatically enable or disable the right-click menu.
    
- **DevTools Management**: Added `SetDevToolsEnabled` to toggle access to the browser's developer tools.
    

### Fixed

- **Event Routing**: Resolved an issue where JavaScript bridge messages were cross-talking between instances; messages are now correctly routed via unique prefixes (e.g., `Web1_`, `Web2_`).
    
- **Resource Locking**: Improved the `Cleanup()` method to ensure all WebView2 processes and profile files are properly released upon closing.
    
- **Initialization Sequence**: Fixed a race condition where calling methods before the engine was fully ready caused crashes; events now properly wait for the `INIT_READY` signal.
    

### Changed

- **Event-Driven Architecture**: Refactored the communication layer to be 100% event-driven, eliminating the need for `Sleep()` or polling loops.
    
- **Bridge Logic**: Optimized the `.NET` to `AutoIt` bridge to handle high-frequency messaging without UI blocking.
    
- **Resizing Logic**: Updated the recommended implementation to use `WM_SIZE` for smoother synchronization between AutoIt GUI containers and the WebView2 engine.


- ---
## Version 1.2.0 - 2024-11-15

### Added

- **JavaScript Bridge**: Initial implementation of `postMessage` communication from JavaScript to AutoIt.
    
- **ExecuteScript Method**: Added ability to run custom JS code from AutoIt directly into the WebView.
    
- **Navigation Events**: Introduced `NAV_STARTING` and `NAV_COMPLETED` events for better page load tracking.
    

### Changed

- **DLL Optimization**: Migrated core logic to a dedicated .NET DLL to handle complex COM interop.
    
- **Stability**: Improved memory management when reloading large websites.
    

---

## Version 1.1.0 - 2024-09-10

### Added

- **Custom Profile Path**: Introduced the ability to set a custom `UserDataFolder` for basic data persistence.
    
- **UserAgent Override**: Added method to change the browser's User-Agent string.
    
- **Zoom Factor**: Added support for manual zoom control (`SetZoomFactor`).
    

### Fixed

- **Object Cleanup**: Fixed a bug where `msedgewebview2.exe` processes remained active after AutoIt script exited.
    

---

## Version 1.0.0 - 2024-06-20 (Initial Release)

### Added

- **Core Engine**: Basic integration of WebView2 control into AutoIt GUI via COM.
    
- **Basic Navigation**: Implemented `Maps` and `MapsToString` methods.
    
- **Resize Support**: Fundamental resizing of the browser window relative to the parent GUI.

---
