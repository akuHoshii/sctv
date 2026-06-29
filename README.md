```markdown
# Hoshi Development Tools

> Single-file Lua script for Roblox map development, testing, and quality assurance.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Features](#features)
- [Interface](#interface)
- [Architecture](#architecture)
- [Performance](#performance)
- [Error Handling](#error-handling)
- [Requirements](#requirements)
- [Compatibility](#compatibility)
- [Disclaimer](#disclaimer)

---

## Overview

Hoshi Development Tools is a production-ready, single-file Lua script built for use on privately developed Roblox maps. It provides a structured suite of developer tools covering player tracking, teleport safety, speed testing, hitbox observation, and collision analysis — all within a premium dark UI designed to the standard of a professional desktop application.

This script is intended exclusively for the map owner during active development. It is not designed for, and should not be used on, public games owned by other developers.

---

## Installation

Paste the following into your executor and run.

```lua
loadstring(game:HttpGet("LINK_SCRIPT_HERE"))()
```

No additional files, modules, or dependencies are required. The entire script is self-contained in a single `.lua` file.

---

## Features

### ESP Player

Renders persistent overlays on all players in the server.

- Billboard GUI displaying name, role, health bar, and distance
- Role-based color coding — Killer, Survivor, Unknown
- Highlight instance with fill and outline per player
- Auto-registers on player join, re-registers on respawn
- Throttled update loop to minimize frame rate impact
- Cleans up all instances on toggle off or player leave

### Teleport Safety

Finds and teleports the local player to a safe position when a threat is detected nearby.

- Ring-based and grid-based candidate search algorithm
- Raycast validation on every candidate — no wall clipping, no void, no blocked overhead
- Scores positions by minimum distance from all detected Killers
- Fallback search if primary candidates are all invalid
- Configurable detection radius, safe distance, and cooldown
- Auto mode triggers on proximity, manual mode available via button

### Speed Run

Controls the local player's walk speed for movement testing.

- Multiplier range from 1x to 10x
- Adjustable via slider or direct text input
- Applied in realtime and restored automatically on respawn

### POV Circle

Renders a screen-space crosshair overlay synchronized to the camera.

- Positioned at viewport center every RenderStepped frame
- Circle outline, center dot, and directional crosshair lines
- Adjustable radius, thickness, transparency, and color
- All property changes animated via TweenService

### Observation Target

Tracks Survivor positions within a defined screen-space radius and renders per-target indicators.

- Uses `Camera:WorldToViewportPoint()` for accurate screen projection
- Indicators follow targets in realtime, synchronized to camera movement
- Highlight overlay applied on observed targets
- Cleans up indicators and highlights when targets leave the observation area or the server
- Designed for hitbox analysis, collision testing, and damage area tracking

### Settings

- Animation speed multiplier
- Background blur toggle
- RGB-based accent color adjustment
- Reset all to defaults
- Script self-destruct with full cleanup

---

## Interface

| Component | Details |
|---|---|
| Window | Draggable, resizable via corner handle, minimize, maximize, close |
| Sidebar | Tab navigation with animated active line indicator |
| Tabs | ESP, Teleport, Speed, POV, Observe, Settings |
| Floating Button | Draggable `H` icon with idle pulse glow, appears when window is closed |
| Watermark | Realtime FPS, ping, clock, and active status display |
| Notifications | Slide-in queue from top-right, per-notification progress bar, auto-dismiss |
| Splash Screen | Animated logo scale, blur transition, dynamic loading text, smooth fade out |

### Animations

All animations use TweenService with appropriate easing curves.

| Interaction | Easing |
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

## Architecture

The script is organized into clearly separated sections within a single file.

```
Services
Variables & Config
Theme
Utility Functions
UI Builder Core
Splash Screen
Window System
Floating Button
Watermark
Notification System
Component Builders
Sidebar & Tab System
ESP Player System
Teleport Safety System
Speed Run System
POV Circle System
Observation Target System
Settings Tab
Initialization
Cleanup
```

### Component Builders

Reusable builder functions generate all interactive components.

| Builder | Output |
|---|---|
| `buildToggle` | Animated ON/OFF toggle with callback |
| `buildSlider` | Draggable value slider with fill and knob |
| `buildTextInput` | Labeled text box with focus stroke |
| `buildButton` | Ripple button with hover scale |
| `buildSectionLabel` | Accent-colored section heading |
| `buildStatusLabel` | Secondary text status line |

---

## Performance

- `RenderStepped` used only where camera-dependent updates are required (POV Circle, Observation Target)
- ESP runs on a throttled `task.spawn` loop at a configurable interval
- All tweens use cancellable references with no stacking
- All event connections stored in a tracked table and disconnected on cleanup
- No unbounded `while true do` loops without `task.wait` yields
- Instances are reused where possible and destroyed when no longer needed

---

## Error Handling

Every operation that accesses game state is guarded.

- Character, Humanoid, and HumanoidRootPart existence verified before use
- Camera validity checked on every RenderStepped callback
- Player and target existence verified before ESP and observation updates
- All potentially failing calls wrapped in `pcall`
- Graceful handling of player disconnect, character respawn, and nil object access
- No errors or warnings produced in the Developer Console during normal operation

---

## Cleanup

Calling destroy or using the Settings destroy button triggers a full cleanup.

- All tracked event connections disconnected
- All ESP BillboardGui and Highlight instances destroyed
- All observation indicators and highlights destroyed
- Walk speed restored to default
- BlurEffect removed from Lighting
- ScreenGui removed from CoreGui

---

## Requirements

- Roblox script executor with `loadstring` and `HttpGet` support
- `CoreGui` write access (falls back to `PlayerGui` if unavailable)

---

## Compatibility

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

## Disclaimer

Hoshi Development Tools is built for private use by the map owner during development.

- Not intended for use on public games owned by other developers
- Not intended for use as a cheating tool or exploit in any live game
- The developer assumes no responsibility for misuse

---

<sub>Hoshi Development Tools &nbsp;&middot;&nbsp; Single File &nbsp;&middot;&nbsp; Private Use Only</sub>
```