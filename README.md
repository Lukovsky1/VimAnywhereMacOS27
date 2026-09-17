# VimAnywhere

VimAnywhere is a macOS utility that brings Vim-style keyboard navigation and editing commands to text fields across applications.

Instead of requiring a Vim-specific editor, VimAnywhere listens for global keyboard input and translates Vim commands into native macOS text-editing actions.

The goal is simple:

> Use Vim-style navigation almost anywhere you can type on macOS.

---

## Current Status

VimAnywhere is currently an early-stage prototype.

The core system is working, including:

- Global keyboard event monitoring
- Normal mode and Insert mode
- Floating mode indicator
- Vim-style cursor navigation
- Multi-key command handling
- Cross-application text-field detection using the macOS Accessibility API
- Synthetic keyboard input for text manipulation

The project is actively being developed and behavior may differ slightly between macOS applications.

---

## Features

### Modes

VimAnywhere currently supports:

- `NORMAL`
- `INSERT`

Press:

```text
i
```

to enter Insert mode.

Press:

```text
Esc
```

to return to Normal mode.

A small floating HUD displays the active mode.

---

## Supported Commands

### Movement

| Command | Action |
|---|---|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |
| `w` | Move forward by word |
| `b` | Move backward by word |
| `0` | Beginning of line |
| `$` | End of line |
| `gg` | Top of document |
| `G` | Bottom of document |

---

### Insert Commands

| Command | Action |
|---|---|
| `i` | Enter Insert mode |
| `I` | Move to beginning of line and enter Insert mode |
| `a` | Move right and enter Insert mode |
| `A` | Move to end of line and enter Insert mode |
| `o` | Open a new line below |
| `O` | Open a new line above |

---

### Delete Commands

| Command | Action |
|---|---|
| `x` | Delete character |
| `dd` | Delete current line |
| `dw` | Delete current word |
| `d$` | Delete to end of line |
| `d0` | Delete to beginning of line |

---

### Change Commands

| Command | Action |
|---|---|
| `cw` | Change current word |
| `c$` | Change to end of line |
| `c0` | Change to beginning of line |

Change commands delete the selected text and immediately enter Insert mode.

---

### Undo / Redo

| Command | Action |
|---|---|
| `u` | Undo |
| `Shift + R` | Redo |

These map to native macOS undo and redo commands.

---

## How It Works

VimAnywhere is built using Swift and native macOS frameworks.

The main components are:

```text
Keyboard Input
      ↓
CGEventTap
      ↓
KeyboardManager
      ↓
VimEngine
      ↓
Native macOS keyboard events
```

### `KeyboardManager`

Handles:

- Global keyboard events
- Vim key mappings
- Synthetic keyboard events
- Multi-key command sequences

### `VimEngine`

Tracks application state, including:

```text
NORMAL mode
INSERT mode
Pending commands
```

For example:

```text
d
```

sets the pending command to:

```text
.delete
```

Then:

```text
d + w
```

becomes:

```text
delete + word
```

while:

```text
d + d
```

becomes:

```text
delete + line
```

---

## macOS Integration

VimAnywhere uses several native macOS technologies:

- `CGEventTap`
- `CGEvent`
- `AXUIElement`
- `NSWorkspace`
- SwiftUI
- AppKit

The Accessibility API is used to determine whether the currently focused UI element is an editable text field.

This prevents Vim commands from activating when the user is interacting with unrelated UI elements.

---

## Permissions

VimAnywhere requires macOS permissions to monitor and generate keyboard events.

Depending on your version of macOS, you may need to enable:

```text
System Settings
→ Privacy & Security
→ Input Monitoring
```

and:

```text
System Settings
→ Privacy & Security
→ Accessibility
```

During development, VimAnywhere currently requires the Xcode **App Sandbox** capability to be disabled so the application can inspect text fields belonging to other applications.

---

## Requirements

Currently developed and tested with:

- macOS
- Xcode
- Swift
- SwiftUI
- AppKit
- CoreGraphics
- ApplicationServices

VimAnywhere is currently designed specifically for macOS.

---

## Building

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/VimAnywhere.git
```

Open the project:

```bash
open VimAnywhereApp.xcodeproj
```

Then build and run using Xcode.

You may need to grant Accessibility and Input Monitoring permissions the first time the application launches.

---

## Project Structure

A simplified project layout:

```text
VimAnywhereApp
│
├── VimAnywhereApp.swift
│
├── ContentView.swift
│
├── VimEngine.swift
│
├── KeyboardManager.swift
│
├── FocusedElementManager.swift
│
├── PermissionManager.swift
│
├── ModeIndicatorView.swift
│
└── ModeIndicatorWindow.swift
```

---

## Current Architecture

### Vim Modes

```swift
enum VimMode {
    case normal
    case insert
}
```

### Pending Commands

```swift
enum PendingCommand {
    case none
    case delete
    case change
    case go
}
```

This makes it possible to support Vim-style multi-key commands such as:

```text
dd
dw
d$
d0

cw
c$
c0

gg
```

without hardcoding every command as an unrelated shortcut.

---

## Known Limitations

VimAnywhere is still experimental.

Current limitations include:

- Word movement is based partly on native macOS word boundaries.
- Behavior may differ between applications.
- Some custom text editors may expose Accessibility information differently.
- Vim registers are not implemented.
- Visual mode is not implemented.
- Yank/paste commands are not implemented yet.
- Counts such as `3w` or `5dd` are not implemented.
- Text objects such as `ciw`, `diw`, and `da"` are not implemented.
- Search commands are not implemented.
- Replace mode is not implemented.
- Configuration and custom key mappings are not implemented yet.

---

## Planned Features

Some planned additions include:

```text
yy
yw
p
P

ciw
diw
daw

v
V

3w
5j
2dd

f<char>
t<char>

%
{
}

/
n
N
```

Longer-term goals include:

- Visual mode
- Vim registers
- Configurable key mappings
- Per-application exclusions
- Startup at login
- Menu-bar controls
- Better word-boundary detection
- Native Accessibility-based cursor movement
- Support for more complex Vim motions
- Improved mode HUD
- User preferences
- Packaging as a standalone macOS application

---

## Why VimAnywhere?

Vim-style navigation is efficient, but it is usually tied to a specific editor.

VimAnywhere explores what happens when Vim becomes a system-level input layer instead.

The long-term idea is:

```text
Safari
Notes
Messages
Xcode
TextEdit
Browsers
Search fields
Text areas
```

all using the same Vim muscle memory.

---

## Development Philosophy

VimAnywhere currently prioritizes:

1. Native macOS behavior
2. Low latency
3. Predictable keyboard handling
4. Minimal interference outside text fields
5. Gradual implementation of Vim's command grammar

The project intentionally starts with a small subset of Vim and expands from there.

---

## License

This project is licensed under the MIT License.

You are free to use, modify, and distribute the code, provided the original copyright and license notice are preserved.

See:

```text
LICENSE
```

for details.

---

## Author

Created by **Lucas Ulibarri**

VimAnywhere started as an experiment in bringing Vim-style text navigation to arbitrary macOS applications using Swift, CoreGraphics, and the macOS Accessibility API.

---

## Contributing

The project is still early, but contributions, bug reports, and ideas are welcome.

If you find an application where VimAnywhere behaves unexpectedly, opening an issue with:

- macOS version
- Application name
- Command used
- Expected behavior
- Actual behavior

would be especially helpful.

---

## Disclaimer

VimAnywhere is experimental software that interacts with global keyboard input and macOS Accessibility APIs.

Use it at your own risk, especially during early development.
