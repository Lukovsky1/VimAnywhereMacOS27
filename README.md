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
