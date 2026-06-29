Tentu, berikut adalah versi README yang telah disempurnakan untuk menjadi lebih profesional, terstruktur, dan menarik secara visual, tanpa mengurangi konten aslinya:

```markdown
<div align="center">

# Hoshi Development Tools

> *A single-file, production-grade Lua suite for Roblox map development, testing, and quality assurance.*

<br />

[![Version](https://img.shields.io/badge/version-2.1.0-00ffa0?style=for-the-badge&logo=semver&logoColor=white)](#)
[![Lua](https://img.shields.io/badge/Lua-5.1+-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/license-MIT-00ffa0?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Status](https://img.shields.io/badge/status-Active-00ffa0?style=for-the-badge)](#)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Installation](#-installation)
- [Features](#-features)
- [Interface](#-interface)
- [Architecture](#-architecture)
- [Performance](#-performance)
- [Error Handling](#-error-handling)
- [Requirements](#-requirements)
- [Compatibility](#-compatibility)
- [Disclaimer](#-disclaimer)

---

## 📖 Overview

**Hoshi Development Tools** is a production-ready, single-file Lua script meticulously crafted for privately developed Roblox maps. It delivers a robust and structured suite of developer tools—including player tracking, teleport safety, speed testing, hitbox observation, and collision analysis—all wrapped in a premium, dark-themed user interface that meets the standard of a professional desktop application.

> [!IMPORTANT]
> This script is intended **exclusively for the map owner** during active development. It is not designed for, and should never be used on, public games owned by other developers.

---

## ⚡ Installation

Getting started is as simple as pasting a single line into your executor:

```lua
loadstring(game:HttpGet("LINK_SCRIPT_HERE"))()
```

No additional files, modules, or dependencies are required. The entire toolkit is self-contained within one `.lua` file, making it incredibly portable and easy to manage.

---

## ✨ Features

### 📍 ESP Player
Renders persistent, informative overlays on all players in the server.
- **Billboard GUI** displaying name, role, health bar, and real-time distance.
- **Role-based color coding** (Killer, Survivor, Unknown) for instant identification.
- **Highlight instances** with fill and outline per player.
- Auto-registers on player join and seamlessly re-registers on respawn.
- Throttled update loop designed to minimize impact on frame rate.
- Performs a full cleanup of all instances on toggle off or player disconnect.

### 🛡️ Teleport Safety
Intelligently finds and teleports you to a safe position when a threat is detected nearby.
- **Advanced candidate search** using ring-based and grid-based algorithms.
- **Raycast validation** on every candidate, guaranteeing no wall clipping, void falling, or blocked overheads.
- Scores positions by minimum distance from all detected Killers to find the optimal safe spot.
- Includes a fallback search if primary candidates are invalid.
- Fully configurable: detection radius, safe distance, and cooldown.
- **Auto mode** triggers on proximity, with a manual mode also available via button.

### 🏃 Speed Run
Gives you complete control over your WalkSpeed for efficient movement testing.
- Multiplier range from **1x to 10x**.
- Adjustable via an intuitive slider or direct text input for precise values.
- Applied in real-time and automatically restored on character respawn.

### 👁️ POV Circle
Renders a clean, screen-space crosshair overlay perfectly synchronized to your camera.
- Positioned at the exact viewport center every `RenderStepped` frame.
- Consists of a circle outline, a center dot, and directional crosshair lines.
- All properties (radius, thickness, transparency, color) are adjustable and animate smoothly via `TweenService`.

### 🎯 Observation Target
A powerful tool for tracking Survivor positions within a defined screen-space radius, rendering per-target indicators.
- Uses `Camera:WorldToViewportPoint()` for pixel-accurate screen projection.
- Indicators follow targets in real-time, staying synchronized with camera movement.
- Applies a highlight overlay on observed targets for clear visual feedback.
- Cleans up all indicators and highlights when targets leave the observation area or the server.
- Purpose-built for hitbox analysis, collision testing, and damage area tracking.

### ⚙️ Settings
Fine-tune the toolkit to your exact preferences.
- **Animation speed** multiplier.
- **Background blur** toggle for increased UI focus.
- **RGB-based accent color** adjustment.
- Reset all settings to defaults with one click.
- **Script self-destruct** button that triggers a complete, residue-free cleanup.

---

## 🖥️ Interface

The interface is designed with a professional, dark aesthetic, focusing on usability and clarity.

| Component | Details |
|---|---|
| **Window** | Fully draggable, resizable via a corner handle, and supports minimize, maximize, and close actions. |
| **Sidebar** | Tab navigation with a smooth, animated active-line indicator. |
| **Tabs** | ESP, Teleport, Speed, POV, Observe, Settings |
| **Floating Button** | A draggable `H` icon with an idle pulse glow that appears when the main window is closed. |
| **Watermark** | Displays real-time FPS, ping, clock, and active status. |
| **Notifications** | A slide-in queue from the top-right with per-notification progress bars and auto-dismiss. |
| **Splash Screen** | Animated logo scale-in, blur transition, dynamic loading text, and a smooth fade-out. |

### ✨ Animations
All UI animations are powered by `TweenService` with carefully chosen easing curves for a premium feel.

| Interaction | Easing Style |
|---|---|
| Window open / close | Quart Out |
| Tab switch | Quart Out |
| Sidebar indicator | Quart Out |
| Button hover / click | Quart Out |
| Ripple effect | Quart Out |
| Notification slide | Quart Out |
| Pulse / breathing | Sine InOut |
| Progress bars | Linear |

---

## 🏗️ Architecture

The script is a masterclass in organization, structured into clearly separated logical sections within a single file for maximum portability.

```
Services                # Roblox service references
Variables & Config      # Centralized configuration and state
Theme                   # Comprehensive color palette
Utility Functions       # Reusable helper functions
UI Builder Core         # Foundational UI creation logic
Splash Screen           # Boot sequence and loading animation
Window System           # Main window creation and management
Floating Button         # Minimized-state button system
Watermark               # Real-time performance/stats display
Notification System     # Toast notification engine
Component Builders      # Factory functions for UI elements
Sidebar & Tab System    # Navigation and tab management
ESP Player System       # Player overlay system
Teleport Safety System  # Auto-flee system
Speed Run System        # WalkSpeed controller
POV Circle System       # Screen-space crosshair
Observation Target System # Target tracking and analysis
Settings Tab            # User preferences panel
Initialization          # Startup and bootstrap logic
Cleanup                 # Full resource teardown
```

### 🧱 Component Builders
Reusable builder functions serve as a factory for all interactive UI components, ensuring a consistent look and feel.

| Builder | Output |
|---|---|
| `buildToggle` | Animated ON/OFF toggle with callback |
| `buildSlider` | Draggable value slider with fill and knob |
| `buildTextInput` | Labeled text box with focus stroke |
| `buildButton` | Ripple-effect button with hover scaling |
| `buildSectionLabel` | Accent-colored section heading |
| `buildStatusLabel` | Secondary text status line |

---

## 🚀 Performance

Performance is a top priority, ensuring the toolkit never interferes with your development experience.

- `RenderStepped` is used **only** where camera-dependent updates are critical (POV Circle, Observation Target).
- ESP runs on a throttled `task.spawn` loop at a configurable interval to save resources.
- All tweens use cancellable references, preventing stacking and memory leaks.
- Every event connection is stored in a tracked table and disconnected on cleanup.
- Zero unbounded `while true do` loops without `task.wait` yields.
- Instances are reused wherever possible and destroyed immediately when no longer needed.

---

## 🛡️ Error Handling

Every operation that interacts with the game state is meticulously guarded to ensure stability.

- Existence of Character, Humanoid, and HumanoidRootPart is verified before any action.
- Camera validity is checked on every `RenderStepped` callback.
- Player and target existence is confirmed before ESP and observation updates.
- All potentially failing calls are wrapped in `pcall`.
- Graceful handling of player disconnect, character respawn, and nil object access.
- **Zero errors or warnings** are produced in the Developer Console during normal operation.

---

## 🧹 Cleanup

Triggering the destroy function or using the Settings destroy button initiates a complete and thorough cleanup.

- All tracked event connections are disconnected.
- All ESP `BillboardGui` and `Highlight` instances are destroyed.
- All observation indicators and highlights are destroyed.
- WalkSpeed is restored to its default value.
- `BlurEffect` is removed from `Lighting`.
- The `ScreenGui` is removed from `CoreGui`.

---

## 📋 Requirements

- A Roblox script executor with `loadstring` and `HttpGet` support.
- `CoreGui` write access (the script gracefully falls back to `PlayerGui` if unavailable).

---

## 🔗 Compatibility

The toolkit leverages standard Roblox APIs for broad compatibility.

| Feature | Dependency |
|---|---|
| GUI rendering | `ScreenGui` with `IgnoreGuiInset` enabled |
| Background blur | `BlurEffect` in `Lighting` |
| ESP overlays | `BillboardGui`, `Highlight` |
| Teleport validation | `Workspace:Raycast()` |
| Screen projection | `Camera:WorldToViewportPoint()` |
| Ping display | `Stats.Network.ServerStatsItem` |
| Animations | `TweenService` |

---

## ⚠️ Disclaimer

**Hoshi Development Tools** is built for private use by the map owner during the development process.

- It is **not intended** for use on public games owned by other developers.
- It is **not intended** for use as a cheating tool or exploit in any live game.
- The developer assumes **no responsibility** for any misuse of this software.

---

<div align="center">
<br />
<sub>Hoshi Development Tools &nbsp;·&nbsp; Single File &nbsp;·&nbsp; Private Use Only</sub>
</div>
```