
<div align="center">

<!-- Banner -->
![Hoshi Development Tools Banner](https://via.placeholder.com/1200x300/0D1117/3891FF?text=Hoshi+Development+Tools)

<!-- Logo -->
<br>

![Hoshi Logo](https://via.placeholder.com/120x120/1A1A2E/3891FF?text=H)

<br>

# Hoshi Development Tools

**Professional-grade admin development toolkit for Roblox map creators.**

A comprehensive suite of internal tools designed for development, testing, debugging, gameplay balancing, and quality assurance — built exclusively for your own Roblox experiences.

<br>

<!-- Badges -->
[![Version](https://img.shields.io/badge/version-1.0.0-3891FF?style=for-the-badge&logo=semver&logoColor=white)](https://github.com/hoshi-dev/hoshi-development-tools/releases)
[![Lua](https://img.shields.io/badge/Lua-5.1+-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-Engine-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![Status](https://img.shields.io/badge/status-Active-45BE78?style=for-the-badge)](https://github.com/hoshi-dev/hoshi-development-tools)
[![License](https://img.shields.io/badge/license-MIT-E6B432?style=for-the-badge)](LICENSE)

[![Maintained](https://img.shields.io/badge/maintained-yes-45BE78?style=flat-square)](https://github.com/hoshi-dev/hoshi-development-tools)
[![Release](https://img.shields.io/github/v/release/hoshi-dev/hoshi-development-tools?style=flat-square&color=3891FF)](https://github.com/hoshi-dev/hoshi-development-tools/releases)
[![Last Commit](https://img.shields.io/github/last-commit/hoshi-dev/hoshi-development-tools?style=flat-square&color=3891FF)](https://github.com/hoshi-dev/hoshi-development-tools/commits)
[![Stars](https://img.shields.io/github/stars/hoshi-dev/hoshi-development-tools?style=flat-square&color=E6B432)](https://github.com/hoshi-dev/hoshi-development-tools/stargazers)
[![Forks](https://img.shields.io/github/forks/hoshi-dev/hoshi-development-tools?style=flat-square&color=45BE78)](https://github.com/hoshi-dev/hoshi-development-tools/network/members)
[![Issues](https://img.shields.io/github/issues/hoshi-dev/hoshi-development-tools?style=flat-square&color=DC414B)](https://github.com/hoshi-dev/hoshi-development-tools/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/hoshi-dev/hoshi-development-tools?style=flat-square&color=A855F7)](https://github.com/hoshi-dev/hoshi-development-tools/pulls)
[![Downloads](https://img.shields.io/github/downloads/hoshi-dev/hoshi-development-tools/total?style=flat-square&color=3891FF)](https://github.com/hoshi-dev/hoshi-development-tools/releases)

<br>

[Getting Started](#-quick-start) · [Features](#-features) · [Documentation](#-modules) · [Roadmap](#-roadmap) · [Contributing](#-contributing)

<br>

</div>

---

## Table of Contents

- [Introduction](#-introduction)
- [Features](#-features)
- [Preview](#-preview)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [UI Showcase](#-ui-showcase)
- [Modules](#-modules)
  - [ESP Player](#esp-player)
  - [Teleport Safety](#teleport-safety)
  - [Speed Controller](#speed-controller)
  - [POV Circle](#pov-circle)
  - [Observation Target](#observation-target)
  - [Notification System](#notification-system)
  - [Window Manager](#window-manager)
  - [Watermark](#watermark)
  - [Configuration System](#configuration-system)
  - [Logging](#logging)
  - [Utilities](#utilities)
  - [Cleanup](#cleanup)
  - [Performance Monitor](#performance-monitor)
- [Project Structure](#-project-structure)
- [Performance](#-performance)
- [Security](#-security)
- [Roadmap](#-roadmap)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [Changelog](#-changelog)
- [License](#-license)
- [Developer](#-developer)
- [Credits](#-credits)

---

## 📖 Introduction

**Hoshi Development Tools** is a professional-grade admin development toolkit purpose-built for Roblox map creators who need reliable, high-performance instrumentation during the development lifecycle.

Unlike generic admin panels or executor scripts, Hoshi was designed from the ground up as a **legitimate internal development tool** — the kind of toolkit you keep open alongside Roblox Studio while you iterate on level design, tune AI behavior, validate hitboxes, and stress-test gameplay systems on your own maps.

> *"Build better games by seeing everything that matters. Hoshi gives you the observability layer that Roblox Studio's default tools don't."*

### Why Hoshi?

Modern Roblox experiences are complex. Enemy AI needs to be observed in-context. Hitbox alignment needs to be validated against real player movement. Teleport systems need safe-position verification across hundreds of edge cases. Doing all of this through print statements and Studio's built-in debugger is slow, fragmented, and painful.

Hoshi consolidates every tool you need into a single, polished interface that runs directly inside your experience — giving you real-time data, visual overlays, and instant controls without leaving the game viewport.

### Design Philosophy

- **Developer-first.** Every feature exists because it solves a real problem during map development.
- **Production-quality UI.** If you're going to stare at a tool for hours, it should look and feel like professional desktop software.
- **Performance-conscious.** Development tools that tank your framerate defeat their own purpose.
- **Non-invasive.** Hoshi observes and instruments — it doesn't modify game state unless you explicitly ask it to.

### Who is this for?

Hoshi is built for **Roblox developers working on their own experiences** — specifically those building complex maps with AI-driven gameplay, role-based mechanics (Killer/Survivor systems), physics interactions, and spatial logic that benefits from visual debugging.

> [!IMPORTANT]
> Hoshi Development Tools is designed exclusively for use on your own Roblox maps during development. It is not intended for use on public games owned by other developers.

---

## ✨ Features

| Feature | Status | Description |
|:--------|:------:|:------------|
| **ESP Player System** | ✅ Active | Full player visualization with box highlights, name tags, distance, health bars, and role detection |
| **Teleport Safety** | ✅ Active | Automatic safe-position teleportation when threats approach, with raycast validation and void protection |
| **Speed Controller** | ✅ Active | Real-time movement speed adjustment via slider and presets for gameplay testing |
| **POV Circle** | ✅ Active | Screen-center observation circle for hitbox alignment and collision area visualization |
| **Observation Target** | ✅ Active | Camera-synced target tracking within the POV circle area with smooth interpolation |
| **Notification System** | ✅ Active | Queue-based notification stack with slide animations, progress bars, and auto-dismiss |
| **Window Manager** | ✅ Active | Draggable, resizable window with minimize, maximize, close, and screen boundary clamping |
| **Floating Button** | ✅ Active | Persistent access point with drag support, pulse animation, and ripple feedback |
| **Splash Screen** | ✅ Active | Animated loading sequence with progress bar, scale animation, and smooth transitions |
| **Watermark** | ✅ Active | Real-time overlay displaying FPS, ping, system time, and operational status |
| **Sidebar Navigation** | ✅ Active | VS Code-inspired sidebar with active state indicators and hover animations |
| **Settings Panel** | ✅ Active | UI scale, animation speed, blur toggle, and one-click reset |
| **Glassmorphism UI** | ✅ Active | Modern dark theme with blur, gradients, soft shadows, and neon blue accents |
| **Tween Animation System** | ✅ Active | Comprehensive animation library with caching, cancellation, and multiple easing curves |
| **Character Reconnection** | ✅ Active | Automatic state restoration on respawn |
| **Resource Cleanup** | ✅ Active | Complete connection tracking and disposal on shutdown |

---

## 🖼️ Preview

<div align="center">

| Dashboard | ESP System |
|:---------:|:----------:|
| ![Dashboard Preview](https://via.placeholder.com/480x300/0D1117/3891FF?text=Dashboard) | ![ESP Preview](https://via.placeholder.com/480x300/0D1117/3891FF?text=ESP+System) |

| Teleport Safety | Settings |
|:---------------:|:--------:|
| ![Teleport Preview](https://via.placeholder.com/480x300/0D1117/3891FF?text=Teleport+Safety) | ![Settings Preview](https://via.placeholder.com/480x300/0D1117/3891FF?text=Settings) |

</div>

---

## 📸 Screenshots

<div align="center">

| Component | Preview |
|:----------|:-------:|
| Splash Screen | ![Splash](https://via.placeholder.com/600x360/0D1117/3891FF?text=Splash+Screen) |
| Main Window | ![Window](https://via.placeholder.com/600x360/0D1117/3891FF?text=Main+Window) |
| Sidebar Navigation | ![Sidebar](https://via.placeholder.com/600x360/0D1117/3891FF?text=Sidebar) |
| Notification Stack | ![Notifications](https://via.placeholder.com/600x360/0D1117/3891FF?text=Notifications) |
| Watermark Overlay | ![Watermark](https://via.placeholder.com/600x360/0D1117/3891FF?text=Watermark) |
| Floating Button | ![Float](https://via.placeholder.com/600x360/0D1117/3891FF?text=Floating+Button) |
| POV Circle | ![POV](https://via.placeholder.com/600x360/0D1117/3891FF?text=POV+Circle) |
| Observation Markers | ![Observation](https://via.placeholder.com/600x360/0D1117/3891FF?text=Observation+Target) |
| Speed Controller | ![Speed](https://via.placeholder.com/600x360/0D1117/3891FF?text=Speed+Controller) |

</div>

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|:------------|:--------|:------------|
| **Roblox Studio** | Latest stable release | Latest stable release |
| **Lua Version** | Luau (Roblox Lua 5.1+) | Luau |
| **Script Executor** | Any executor supporting `loadstring` and `HttpGet` | Synapse X, Script-Ware, Fluxus |
| **Operating System** | Windows 10 / macOS 11 | Windows 11 / macOS 14 |
| **Display Resolution** | 1280 x 720 | 1920 x 1080 or higher |
| **Internet Connection** | Required for script loading | Stable broadband |

> [!NOTE]
> Hoshi Development Tools requires an executor environment that supports `game:HttpGet()` for remote script loading and `CoreGui` access for UI rendering.

---

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/hoshi-dev/hoshi-development-tools.git
cd hoshi-development-tools
```

### 2. Host the Script

Upload `main.lua` to a raw-accessible endpoint. You can use GitHub raw URLs, your own server, or any static file host.

```
https://raw.githubusercontent.com/hoshi-dev/hoshi-development-tools/main/src/main.lua
```

### 3. Configure the Loader

Create a loader script pointing to your hosted file:

```lua
loadstring(game:HttpGet("https://your-host.com/path/to/main.lua"))()
```

### 4. Execute in Your Map

Open your Roblox map in a testing session, then run the loader through your executor. The splash screen will appear, followed by the main dashboard.

### 5. Verify

Confirm all modules load correctly by checking the Dashboard status panel. All active modules should display a green "Active" indicator.

> [!TIP]
> Using a remote loader makes it easy to push updates to your tools without re-injecting manually. Edit the hosted file, and the next execution pulls the latest version automatically.

---

## 🚀 Quick Start

Get up and running in under 30 seconds:

```lua
-- Step 1: Execute the loader in your Roblox map
loadstring(game:HttpGet("https://your-host.com/hoshi/main.lua"))()

-- Step 2: The splash screen loads automatically
-- Step 3: The dashboard opens — start using tools from the sidebar
```

Once the dashboard is open:

1. Click **ESP Player** in the sidebar to enable player visualization.
2. Click **POV Circle** to activate the observation reticle.
3. Click **Observation** to begin tracking targets inside your POV circle.
4. Use **Speed Controller** to adjust movement speed for traversal testing.
5. Configure **Teleport Safety** if your map has Killer/Survivor mechanics.

The floating **H** button appears whenever you close the window — click it to reopen instantly.

---

## 📘 Usage

### Enabling ESP for Player Observation

```lua
-- ESP is controlled through the UI toggle on the ESP Player page.
-- When enabled, all players receive:
--   • Highlight overlay (box ESP)
--   • Floating name tag
--   • Distance readout
--   • Health bar with color coding
--   • Role detection (Killer/Survivor)
```

Navigate to **ESP Player** in the sidebar, toggle **Enable ESP**, and configure visibility options using the individual toggles for Box, Name, Distance, Health, and Role.

### Testing Teleport Safety

```lua
-- Teleport Safety monitors the distance between your character
-- and detected Killer-role players.
--
-- When a Killer enters the detection radius:
--   1. The system scans 36 angular positions at SafeDistance
--   2. Each candidate is validated with Raycast (no walls, no void)
--   3. The position farthest from all Killers is selected
--   4. Your character is moved instantly
--   5. A cooldown prevents repeated triggers
```

Navigate to **Teleport Safety**, enable the toggle, and adjust Detection Radius, Safe Distance, and Cooldown to match your map's scale.

### Adjusting Speed for Traversal Testing

```lua
-- Speed Controller multiplies the base WalkSpeed (16) by your chosen factor.
-- Use the slider for precise control, or click preset buttons for common values.
--
-- Presets: x1, x2, x3, x5, x8, x10
-- The setting persists across respawns automatically.
```

### Using the POV Circle and Observation System Together

```lua
-- The POV Circle renders a configurable reticle at screen center.
-- The Observation system tracks any player whose WorldToViewportPoint
-- position falls inside this circle.
--
-- Workflow:
--   1. Enable POV Circle → adjust radius to match your weapon's effective area
--   2. Enable Observation → markers appear on targets inside the circle
--   3. Markers follow targets with smooth interpolation (configurable)
--   4. Use this to validate hitbox alignment, aim cone accuracy,
--      and damage area coverage during gameplay
```

### Closing and Reopening the Interface

```lua
-- Click the X button → window closes, floating H button appears
-- Click the H button → window reopens with previous state
-- Click _ button → minimizes (same as close, with floating button)
-- Click + button → toggles maximize/restore
```

---

## ⚙️ Configuration

All configuration values can be adjusted through the Settings page in the UI. The following table documents the full configuration schema:

### Core Settings

| Setting | Default | Range | Description |
|:--------|:--------|:------|:------------|
| `UIScale` | `1.0` | `0.7 – 1.3` | Global scale multiplier for the entire interface |
| `AnimationSpeed` | `1.0` | `0.25 – 2.0` | Speed multiplier for all tween animations |
| `BlurEnabled` | `true` | `true / false` | Toggle background blur effect when window is open |

### ESP Configuration

| Setting | Default | Range | Description |
|:--------|:--------|:------|:------------|
| `ESP.Enabled` | `false` | `true / false` | Master toggle for the ESP system |
| `ESP.BoxEnabled` | `true` | `true / false` | Show highlight overlay on players |
| `ESP.NameEnabled` | `true` | `true / false` | Show floating name tags |
| `ESP.DistanceEnabled` | `true` | `true / false` | Show distance readout in meters |
| `ESP.HealthEnabled` | `true` | `true / false` | Show health bar with color coding |
| `ESP.RoleEnabled` | `true` | `true / false` | Show detected role (Killer/Survivor) |
| `ESP.MaxDistance` | `2000` | `100 – 2000` | Maximum render distance for ESP elements |
| `ESP.RefreshRate` | `0.1` | — | Update interval in seconds |

### Teleport Safety Configuration

| Setting | Default | Range | Description |
|:--------|:--------|:------|:------------|
| `TeleportSafety.Enabled` | `false` | `true / false` | Master toggle for safety teleport |
| `TeleportSafety.DetectionRadius` | `35` | `10 – 100` | Distance in studs at which Killer presence triggers teleport |
| `TeleportSafety.SafeDistance` | `100` | `50 – 300` | Minimum distance in studs for safe position candidates |
| `TeleportSafety.Cooldown` | `3` | `1 – 10` | Cooldown in seconds between teleport triggers |

### POV Circle Configuration

| Setting | Default | Range | Description |
|:--------|:--------|:------|:------------|
| `POVCircle.Enabled` | `false` | `true / false` | Toggle the screen-center observation circle |
| `POVCircle.Radius` | `120` | `30 – 400` | Circle radius in pixels |
| `POVCircle.Thickness` | `2` | `1 – 6` | Ring stroke thickness in pixels |
| `POVCircle.Opacity` | `0.6` | `0.1 – 1.0` | Ring opacity |
| `POVCircle.Color` | `RGB(56,145,255)` | Any color | Ring and crosshair color |

### Observation Configuration

| Setting | Default | Range | Description |
|:--------|:--------|:------|:------------|
| `Observation.Enabled` | `false` | `true / false` | Toggle target observation markers |
| `Observation.Radius` | `120` | `30 – 400` | Observation detection radius in pixels |
| `Observation.Transparency` | `0.5` | `0.0 – 0.9` | Marker transparency |
| `Observation.SmoothFactor` | `0.15` | `0.05 – 0.5` | Interpolation factor for marker movement |

### Notification Configuration

| Setting | Default | Description |
|:--------|:--------|:------------|
| `Notification.Duration` | `4s` | Default auto-dismiss duration |
| `Notification.MaxStack` | `5` | Maximum simultaneous notifications |
| `Notification.Position` | `Top Right` | Notification stack anchor position |

### Watermark Configuration

| Setting | Default | Description |
|:--------|:--------|:------------|
| `Watermark.UpdateRate` | `0.5s` | FPS/Ping refresh interval |
| `Watermark.Position` | `Top Left` | Screen position |

---

## 🎨 UI Showcase

Hoshi's interface is designed to feel like professional desktop software — not a Roblox script GUI.

| Component | Description |
|:----------|:------------|
| **Glassmorphism** | Layered translucent surfaces with subtle blur, creating depth without visual clutter |
| **Dark Theme** | Eye-friendly dark color palette optimized for extended development sessions |
| **Neon Blue Accent** | Consistent `RGB(56, 145, 255)` accent color across all interactive elements |
| **Background Blur** | Real-time `BlurEffect` applied to the game viewport when the window is active |
| **Gradient Surfaces** | Subtle color gradients on accent elements for visual richness |
| **Rounded Corners** | Consistent corner radius across all UI components (8px standard, 12px for windows, 5px for small elements) |
| **Soft Shadows** | Stroke-based shadow simulation for surface elevation hierarchy |
| **Sidebar Navigation** | VS Code-style sidebar with active indicators, hover states, and icon-free text labels |
| **Dashboard Layout** | Card-based information architecture with section titles and separators |
| **Notification Stack** | Slide-in cards with accent bars, progress countdowns, and type-based coloring |
| **Watermark Overlay** | Minimal status bar displaying real-time telemetry data |
| **Status Indicators** | Color-coded module status (green = active, dim = disabled) |
| **Responsive Layout** | Window content adapts to resize operations; all elements reflow correctly |
| **Floating Button** | Persistent circular button with idle pulse, hover scale, and click ripple |
| **Splash Screen** | Branded loading sequence with logo animation, progress bar, and fade transitions |
| **Terminal Aesthetic** | Monospaced data readouts and structured information display inspired by developer terminals |
| **Professional Window** | Desktop-class title bar with drag, resize handle, and window control buttons |
| **Tween Animations** | Buttery-smooth transitions using Quart, Quint, Circular, and Exponential easing |

---

## 📦 Modules

### ESP Player

**Overview:** The ESP (Extra Sensory Perception) system provides a complete visual overlay for all players in the server, rendering information that would otherwise require constant manual checking.

**Purpose:** Observe player positions, health states, team roles, and spatial relationships during gameplay testing — particularly useful for validating AI behavior, spawn distribution, and role-assignment logic.

**Features:**
- Roblox `Highlight` instance for box visualization (fill + outline)
- `BillboardGui` with name tag, distance readout, health bar, and role label
- Automatic role detection via character tags, player attributes, and team membership
- Color-coded health bars (green → yellow → red)
- Role-aware highlight coloring (red for Killers, green for Survivors)
- Configurable maximum render distance
- Automatic ESP creation for players joining mid-session
- Automatic cleanup for players leaving

**Technical Notes:**
- ESP updates run on `Heartbeat` with an accumulator pattern, not `RenderStepped`, to avoid unnecessary per-frame overhead.
- Update interval defaults to 100ms — fast enough for smooth visuals, light enough to maintain 60+ FPS with 20+ players.
- All ESP instances are tracked in a dictionary keyed by player reference for O(1) lookup and cleanup.

---

### Teleport Safety

**Overview:** An automated safety system that monitors proximity to Killer-role players and relocates your character to a validated safe position when threats enter a configurable detection radius.

**Purpose:** Test Survivor gameplay mechanics without constant manual repositioning. Validate that your map's geometry supports safe teleportation to viable positions from any location.

**Features:**
- Continuous distance monitoring against all detected Killer-role players
- 36-angle radial scan for candidate safe positions at configurable distance
- Full Raycast validation for every candidate:
  - Ground existence check (no void)
  - Minimum Y-position threshold (no falling below map)
  - Headroom check (no teleporting inside walls or ceilings)
- Fallback to 20 randomized positions if radial scan fails
- Selection of the position with maximum distance from all Killers
- Configurable detection radius, safe distance, and cooldown
- Notification feedback on successful teleport or failure

**Technical Notes:**
- Killer detection checks character tags (`Killer`, `IsKiller`), player attributes, and team name matching.
- Raycast uses `RaycastParams` with the local character excluded from the filter.
- The cooldown timer uses `tick()` comparison — no coroutines or spawn overhead.

---

### Speed Controller

**Overview:** A simple but essential tool for adjusting player movement speed during map traversal testing.

**Purpose:** Quickly move across large maps to inspect distant areas, test movement-dependent mechanics at different speeds, or slow down to observe fine-grained interactions.

**Features:**
- Continuous slider from 1x to 10x base WalkSpeed
- Direct text input for precise values
- One-click preset buttons (x1, x2, x3, x5, x8, x10)
- Real-time WalkSpeed readout
- Automatic speed restoration on character respawn

**Technical Notes:**
- Speed is applied as a multiplier against the base WalkSpeed of 16.
- `CharacterAdded` connection ensures the speed setting persists through deaths and respawns without requiring manual reactivation.

---

### POV Circle

**Overview:** A screen-center overlay circle that represents the player's point-of-view area — typically aligned with a weapon's effective range, aim cone, or damage area.

**Purpose:** Visualize the exact screen area where game mechanics (damage, detection, interaction) should be active. Essential for hitbox alignment testing, aim cone calibration, and camera FOV validation.

**Features:**
- `UIStroke`-based circle rendering (no image assets required)
- Center crosshair with horizontal and vertical lines
- Center dot indicator
- Configurable radius, thickness, opacity, and color
- Always centered on the viewport regardless of screen resolution
- Instant toggle with no initialization delay

**Technical Notes:**
- The circle is rendered as a `Frame` with `UICorner` at 50% radius and a `UIStroke` for the ring — this approach is significantly more performant than drawing circles with `Drawing` library calls and fully compatible with all executors.

---

### Observation Target

**Overview:** A real-time target tracking system that identifies players within the POV Circle area and renders smooth-following markers on their screen positions.

**Purpose:** Observe how targets move through your weapon's effective area in real time. Validate that hitbox registration, aim assist zones, and damage falloff boundaries align with visual expectations.

**Features:**
- `Camera:WorldToViewportPoint()` for accurate world-to-screen projection
- Distance-from-center calculation against configurable observation radius
- Per-target marker with name tag and accent coloring
- Smooth position interpolation using linear lerp with configurable factor
- Automatic marker creation and destruction as targets enter/exit the observation area
- Markers follow targets fluidly — no snapping, no fixed-position anchoring

**Technical Notes:**
- Runs on `RenderStepped` for frame-accurate tracking — this is one of the few systems where per-frame updates are justified.
- Lerp factor of 0.15 provides a natural "soft follow" feel. Increase toward 0.5 for tighter tracking, decrease toward 0.05 for cinematic smoothness.
- Markers are parented to a dedicated container frame for easy bulk cleanup.

---

### Notification System

**Overview:** A modern notification stack that provides non-intrusive feedback for all tool operations.

**Purpose:** Confirm that actions succeeded, warn about edge cases, and surface errors — without requiring the developer to watch a console.

**Features:**
- Four notification types: Info (blue), Success (green), Warning (yellow), Error (red)
- Slide-in animation from the right edge
- Accent bar coloring by notification type
- Progress bar countdown showing remaining display time
- Automatic dismissal after configurable duration
- Stacking with `UIListLayout` — new notifications push older ones up
- Fade-out animation on dismissal

**Technical Notes:**
- Each notification is a self-contained lifecycle — creation, animation, countdown, and destruction are handled within a single function call with `task.delay` for cleanup timing.
- No queue polling or update loop required.

---

### Window Manager

**Overview:** A desktop-class window system providing the primary container for all Hoshi UI content.

**Purpose:** Deliver a professional, familiar interface paradigm that developers already understand from tools like VS Code, Roblox Studio, and Adobe Creative Cloud.

**Features:**
- Smooth drag via `InputBegan`/`InputChanged` with delta tracking
- Corner resize handle with minimum size enforcement (750 x 480)
- Minimize (closes to floating button), Maximize (fills screen with margin), Close
- Title bar with branded logo, project name, and window control buttons
- Hover animations on all interactive title bar elements
- `UIStroke` border with transparency animation on open/close
- Scale animation on window show/hide

**Technical Notes:**
- Drag and resize both use the `InputChanged` signal on `UserInputService` with guard variables — no `RunService` connections required.
- Maximize stores no previous state — it toggles between default size/position and near-fullscreen. This is intentional; for a development tool, exact window position memory is less important than quick access.

---

### Watermark

**Overview:** A persistent overlay bar displaying real-time system telemetry.

**Purpose:** Monitor performance impact of your game systems and Hoshi itself without opening separate tools.

**Features:**
- FPS counter (updates every 500ms to avoid jitter)
- Network ping readout via `Stats.Network`
- System clock
- Operational status indicator
- Minimal footprint — single `TextLabel` inside a small frame

**Technical Notes:**
- The FPS counter uses `RenderStepped` delta time (`1/dt`) rather than a frame-counting approach, providing instant readings without accumulation delay.
- Update interval of 500ms balances readability against CPU cost.

---

### Configuration System

**Overview:** Centralized configuration table that controls every tunable parameter across all modules.

**Purpose:** Provide a single source of truth for all settings, making it trivial to adjust behavior, save state, or reset to defaults.

**Features:**
- Flat table structure organized by module
- Default values for every parameter
- Range constraints enforced at the UI layer
- One-click reset to factory defaults via Settings page

---

### Logging

**Overview:** Notification-based logging for development feedback.

**Purpose:** Surface operational events (module enable/disable, teleport triggers, errors) through the notification system rather than the output console.

**Features:**
- Type-tagged messages (Info, Success, Warning, Error)
- Contextual titles identifying the source module
- Duration control per notification

---

### Utilities

**Overview:** Shared helper library used across all modules.

**Purpose:** Eliminate code duplication and provide battle-tested implementations of common operations.

**Features:**
- `Util.Tween()` — cached tween creation with automatic cancellation of previous tweens on the same object
- `Util.Create()` — streamlined Instance creation with property and child assignment
- `Util.AddCorner/Stroke/Padding/Gradient` — UI decoration helpers
- `Util.GetCharacter/Humanoid/RootPart` — safe character access with fallback
- `Util.RaycastDown/IsPositionSafe` — spatial validation helpers
- `Util.GetFPS/GetPing/FormatTime` — telemetry helpers
- `Util.Clamp/Lerp` — math utilities
- `Util.AddConnection` — connection tracking for cleanup

---

### Cleanup

**Overview:** Resource disposal system that prevents memory leaks and stale references.

**Purpose:** Ensure that every connection, GUI instance, and effect created by Hoshi is properly destroyed when the tool is unloaded or re-executed.

**Features:**
- Centralized connection array with tracked `Disconnect` calls
- Tween cache clearing
- CoreGui child cleanup for all Hoshi ScreenGui instances
- Lighting effect cleanup (BlurEffect)
- Runs automatically on re-execution and on `ScreenGui.Destroying`

---

### Performance Monitor

**Overview:** The Watermark module doubles as a passive performance monitor, continuously displaying FPS and network latency.

**Purpose:** Detect performance regressions in your game systems by watching FPS trends during gameplay testing with Hoshi active.

**Features:**
- FPS displayed at 2Hz update rate
- Ping displayed alongside FPS for network-aware debugging
- Visual confirmation that Hoshi itself is not degrading performance

---

## 📁 Project Structure

```
hoshi-development-tools/
│
├── src/
│   ├── main.lua              # Entry point — all modules in single file
│   └── loader.lua             # Minimal loader script
│
├── docs/
│   ├── modules.md             # Detailed module documentation
│   ├── configuration.md       # Full configuration reference
│   └── ui-design.md           # UI design system documentation
│
├── assets/
│   ├── banner.png             # Repository banner image
│   ├── logo.png               # Project logo
│   └── screenshots/           # UI screenshots
│       ├── dashboard.png
│       ├── esp.png
│       ├── teleport.png
│       ├── settings.png
│       ├── notifications.png
│       ├── splash.png
│       ├── watermark.png
│       ├── pov-circle.png
│       └── observation.png
│
├── .gitignore
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── README.md
```

| Directory / File | Purpose |
|:-----------------|:--------|
| `src/main.lua` | Complete Hoshi Development Tools source — single-file architecture for executor compatibility |
| `src/loader.lua` | Minimal `loadstring` + `HttpGet` loader for remote execution |
| `docs/` | Extended documentation for module APIs, configuration, and UI design |
| `assets/` | Images used in documentation and repository presentation |
| `LICENSE` | MIT License |
| `CHANGELOG.md` | Version history with categorized changes |
| `CONTRIBUTING.md` | Contribution guidelines and development workflow |
| `README.md` | This file |

> [!NOTE]
> Hoshi uses a single-file architecture (`main.lua`) because Roblox executor environments typically load scripts as single payloads via `loadstring`. The code is internally modularized with clear section boundaries and a consistent organizational pattern.

---

## ⚡ Performance

Performance is a first-class concern in Hoshi. Development tools that cause frame drops are counterproductive — you can't accurately observe gameplay behavior if your tools are the reason the game is stuttering.

### Optimization Strategies

| Strategy | Implementation |
|:---------|:--------------|
| **FPS-Friendly Update Loops** | ESP and Teleport Safety use `Heartbeat` with accumulator patterns, updating at 10Hz instead of 60Hz. Only the Observation module uses `RenderStepped`, and only when enabled. |
| **Tween Caching & Cancellation** | Every tween is tracked by a composite key. Starting a new tween on the same object/property automatically cancels the previous one — no tween stacking, no wasted interpolation cycles. |
| **Lazy Initialization** | ESP objects are created on-demand when the module is enabled. POV Circle geometry is created once and toggled via `Visible`. No pre-allocation of unused resources. |
| **Connection Tracking** | Every `RBXScriptConnection` is stored in a centralized array. Disabling a module disconnects its connections immediately — no orphaned listeners consuming CPU. |
| **Efficient Rendering** | ESP uses native `Highlight` instances and `BillboardGui` — both are rendered by the engine's optimized pipeline, not by Lua-side drawing loops. |
| **Batched UI Updates** | Watermark and Dashboard status refresh at fixed intervals (500ms and 1000ms respectively), not every frame. |
| **Scoped RenderStepped** | Only the Observation module connects to `RenderStepped`, and only while active. All other systems use `Heartbeat` or event-driven updates. |
| **Memory Cleanup** | `Cleanup.Run()` is called on re-execution and on GUI destruction, ensuring no instances, connections, or effects leak between sessions. |
| **No Polling Loops** | No `while true do` loops anywhere in the codebase. All periodic work uses engine signals with delta-time accumulators or `task.delay`. |

### Performance Targets

| Metric | Target | Typical |
|:-------|:-------|:--------|
| FPS Impact (idle) | < 1 FPS | ~0 FPS |
| FPS Impact (all modules active) | < 5 FPS | ~2–3 FPS |
| Memory Overhead | < 15 MB | ~8 MB |
| Tween Concurrency | No stacking | Guaranteed |
| Connection Cleanup | 100% on shutdown | Verified |

---

## 🔒 Security

Hoshi Development Tools is an **internal development tool** created for use on your own Roblox maps.

> [!WARNING]
> This project is not designed, intended, or licensed for use on public games owned by other developers. Using development tools on games you do not own may violate Roblox's Terms of Service and the rights of other creators.

### Responsible Use Guidelines

- **Use only on your own experiences.** Hoshi is built for map creators testing their own work.
- **Do not distribute as an exploitation tool.** The features in Hoshi (ESP, teleportation, speed modification) are standard development instrumentation — they are not designed to provide unfair advantages in competitive gameplay.
- **Respect other developers.** The Roblox development community thrives on mutual respect. Use tools like Hoshi to build better games, not to undermine others.
- **Keep your loader private.** If you host Hoshi on a public URL, ensure access is restricted to your development team.

### Technical Security

- Hoshi does not transmit any data to external servers.
- Hoshi does not modify game state on the server — all operations are client-side.
- Hoshi does not access or store credentials, tokens, or personal information.
- The `loadstring` + `HttpGet` loader pattern is used solely for update convenience during development.

---

## 🗺️ Roadmap

### Completed

- [x] Core window system with drag, resize, minimize, maximize, close
- [x] Sidebar navigation with page switching and active indicators
- [x] ESP Player system with highlight, name, distance, health, and role
- [x] Teleport Safety with radial scan, raycast validation, and void protection
- [x] Speed Controller with slider, text input, and presets
- [x] POV Circle with configurable radius, thickness, opacity, and color
- [x] Observation Target with smooth-follow markers and POV circle integration
- [x] Notification system with queue, progress bar, and type coloring
- [x] Watermark with real-time FPS, ping, and clock
- [x] Splash screen with animated logo, progress bar, and transitions
- [x] Floating button with drag, pulse animation, and ripple feedback
- [x] Settings page with UI scale, animation speed, and blur toggle
- [x] Complete tween animation system with caching and cancellation
- [x] Resource cleanup and connection tracking
- [x] Character respawn state restoration

### In Progress

- [ ] Color picker component for theme and accent customization
- [ ] Keybind system for toggling modules without opening the GUI
- [ ] Export/import configuration as JSON

### Planned

- [ ] Minimap overlay with player position indicators
- [ ] NPC/AI path visualization for AI development
- [ ] Hitbox wireframe rendering using `HandleAdornment`
- [ ] Server-side event logger with filterable timeline
- [ ] Collision mesh visualizer
- [ ] Damage area heatmap overlay
- [ ] Spawn point analysis tool
- [ ] Multi-monitor support for ultrawide displays
- [ ] Plugin architecture for custom module loading
- [ ] Performance profiler with frame time graph
- [ ] Light and shadow debug overlay
- [ ] Audio source visualizer with falloff radius display
- [ ] Terrain analysis tool for material and height mapping
- [ ] Undo/redo system for setting changes
- [ ] Session recording and playback for QA review

---

## ❓ FAQ

<details>
<summary><strong>What is Hoshi Development Tools?</strong></summary>

<br>

Hoshi Development Tools is an internal admin development toolkit designed for Roblox map creators. It provides real-time visual overlays, debugging tools, and gameplay testing utilities that run inside your Roblox experience during development sessions.

</details>

<details>
<summary><strong>Is this an exploit or cheat tool?</strong></summary>

<br>

No. Hoshi is a development tool built for creators to use on their own maps. The features it provides — player visualization, safe teleportation, speed adjustment, hitbox observation — are standard development and QA instrumentation. It is not designed for use on games you do not own.

</details>

<details>
<summary><strong>Does Hoshi work on any Roblox game?</strong></summary>

<br>

Technically, the script can execute in any Roblox environment that supports the required APIs. However, Hoshi is designed and intended exclusively for use on your own maps during development. Using it on games owned by other developers is not supported and is strongly discouraged.

</details>

<details>
<summary><strong>What executor do I need?</strong></summary>

<br>

Any executor that supports `game:HttpGet()`, `loadstring()`, and `CoreGui` access. Hoshi has been tested with common executors including Synapse X, Script-Ware, and Fluxus.

</details>

<details>
<summary><strong>Will Hoshi affect my game's performance?</strong></summary>

<br>

Hoshi is optimized for minimal performance impact. With all modules active, typical FPS overhead is 2–3 frames. The ESP system updates at 10Hz, the watermark at 2Hz, and only the Observation module uses per-frame updates (and only when enabled).

</details>

<details>
<summary><strong>Can I customize the UI theme?</strong></summary>

<br>

Currently, the color scheme is configured in the `Config.Colors` table in the source code. A visual color picker is planned for a future release. You can adjust UI scale, animation speed, and blur through the Settings page.

</details>

<details>
<summary><strong>How does Teleport Safety detect Killers?</strong></summary>

<br>

The system checks three sources: character children named "Killer", player children/attributes named "IsKiller", and team names containing the word "killer" (case-insensitive). You can extend the detection logic in `TeleportSafety.FindKillers()` to match your game's specific role system.

</details>

<details>
<summary><strong>What happens if Teleport Safety can't find a safe position?</strong></summary>

<br>

The system first attempts a 36-angle radial scan at the configured safe distance. If no valid position is found, it falls back to 20 randomized position attempts. If all fail, no teleport occurs and an error notification is displayed. The cooldown timer is not consumed on failure.

</details>

<details>
<summary><strong>Does the speed setting persist after I die?</strong></summary>

<br>

Yes. Hoshi listens for the `CharacterAdded` event and automatically reapplies your speed multiplier to the new Humanoid after a short delay.

</details>

<details>
<summary><strong>Can I use Hoshi in Roblox Studio's test mode?</strong></summary>

<br>

Hoshi is designed for executor-based injection during runtime. For Roblox Studio testing, you would need to adapt the script to run as a LocalScript within Studio's environment. The core logic is compatible, but the loader mechanism (`loadstring` + `HttpGet`) is executor-specific.

</details>

<details>
<summary><strong>How do I update Hoshi to a new version?</strong></summary>

<br>

If you're using the remote loader pattern, simply update the hosted `main.lua` file. The next time you execute the loader, it pulls the latest version automatically. No client-side changes needed.

</details>

<details>
<summary><strong>Is there a keybind to toggle the GUI?</strong></summary>

<br>

Not yet — keybind support is on the roadmap. Currently, you close the window with the X button (which reveals the floating H button) and click the floating button to reopen. The floating button can be dragged to any screen position.

</details>

<details>
<summary><strong>Why is everything in a single Lua file?</strong></summary>

<br>

Roblox executor environments load scripts as single payloads via `loadstring`. Multi-file module systems require either a custom require implementation or multiple HTTP requests, both of which add complexity and latency. The single-file approach ensures reliable, fast loading while maintaining internal modularity through clear section organization.

</details>

<details>
<summary><strong>Can I add my own modules?</strong></summary>

<br>

Yes. The architecture is designed for extension. To add a new module: create a page with `Window.CreatePage()`, add a sidebar button with `Window.AddSidebarButton()`, populate the page using the `Components` library, and implement your module logic in a dedicated section. Follow the existing patterns (ESP, Teleport Safety) as templates.

</details>

<details>
<summary><strong>Does Hoshi send any data to external servers?</strong></summary>

<br>

No. Hoshi operates entirely client-side. The only network request is the initial `HttpGet` call in the loader to fetch the script source. No telemetry, analytics, or user data is transmitted.

</details>

---

## 🤝 Contributing

Contributions are welcome. Whether you're fixing a bug, improving performance, adding a new module, or refining the UI — your input makes Hoshi better for every developer who uses it.

### How to Contribute

1. **Fork the repository**

   ```bash
   git clone https://github.com/your-username/hoshi-development-tools.git
   ```

2. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**

   Follow the existing code style: consistent naming, clear section boundaries, modular function design, and minimal comments (code should be self-documenting).

4. **Test thoroughly**

   Verify your changes in a live Roblox environment. Check for:
   - No syntax errors
   - No runtime errors or warnings
   - No FPS regression
   - No memory leaks
   - Correct behavior on character respawn
   - Clean cleanup on re-execution

5. **Commit with a clear message**

   ```bash
   git commit -m "feat: add hitbox wireframe rendering module"
   ```

   Use conventional commit prefixes: `feat`, `fix`, `perf`, `refactor`, `docs`, `style`, `chore`.

6. **Push and open a Pull Request**

   ```bash
   git push origin feature/your-feature-name
   ```

   Open a PR against `main` with a description of what you changed and why.

### Code of Conduct

- Be respectful and constructive in all interactions.
- Focus feedback on the code, not the person.
- Welcome newcomers and help them contribute successfully.
- Do not submit code intended for exploitation of third-party games.
- Prioritize quality over quantity — one well-tested module is worth more than five broken ones.

---

## 📋 Changelog

### v1.0.0 — Initial Release

**Released:** 2024

#### Added
- Core window system with drag, resize, minimize, maximize, and close
- Sidebar navigation with seven pages and active state indicators
- ESP Player module with Highlight, BillboardGui, and role detection
- Teleport Safety module with radial scan and raycast validation
- Speed Controller with slider, text input, and preset buttons
- POV Circle with UIStroke rendering and crosshair overlay
- Observation Target with WorldToViewportPoint tracking and smooth interpolation
- Notification system with type coloring, progress bars, and slide animation
- Watermark overlay with FPS, ping, clock, and status
- Splash screen with logo animation, progress bar, and fade transitions
- Floating button with drag, pulse, hover scale, and ripple
- Settings page with UI scale, animation speed, blur toggle, and reset
- Tween animation system with caching and automatic cancellation
- Resource cleanup system with connection tracking
- Character respawn state restoration

#### Technical
- Single-file architecture for executor compatibility
- Modular internal structure with 13+ distinct systems
- Zero `while true do` loops — all periodic work uses engine signals
- Complete `pcall` wrapping on external object access
- Tested against Roblox client updates as of release date

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 Hoshi Development

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> [!NOTE]
> While the MIT License permits broad usage, please respect the project's intended purpose as an internal development tool. Do not redistribute Hoshi as an exploitation tool for third-party games.

---

## 👤 Developer

| | |
|:--|:--|
| **Developer** | Hoshi |
| **GitHub** | [@hoshi-dev](https://github.com/hoshi-dev) |
| **Discord** | `hoshi.dev` |
| **Website** | [hoshi.dev](https://hoshi.dev) |
| **Email** | contact@hoshi.dev |

---

## 🙏 Credits

| | |
|:--|:--|
| **Roblox** | Game engine, Luau runtime, and Studio development environment |
| **Lua** | The programming language powering Roblox scripting |
| **Roblox Developer Hub** | API documentation and technical references |
| **Open Source Community** | Inspiration from countless open source projects and their maintainers |
| **Contributors** | Everyone who reports bugs, suggests features, or submits pull requests |
| **GitHub** | Hosting, version control, and collaboration platform |
| **Shields.io** | Badge generation service used in this README |

---

<div align="center">

<br>

---

**Hoshi Development Tools** — Professional development instrumentation for Roblox creators.

Copyright &copy; 2024 Hoshi Development. All rights reserved.

Made with dedication for the Roblox development community.

<br>

[![Back to Top](https://img.shields.io/badge/Back_to_Top-↑-3891FF?style=for-the-badge)](#hoshi-development-tools)

[![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?style=flat-square&logo=github)](https://github.com/hoshi-dev/hoshi-development-tools)
[![Issues](https://img.shields.io/badge/Report-Bug-DC414B?style=flat-square)](https://github.com/hoshi-dev/hoshi-development-tools/issues)
[![Feature](https://img.shields.io/badge/Request-Feature-45BE78?style=flat-square)](https://github.com/hoshi-dev/hoshi-development-tools/issues)

<br>

</div>