<div align="center">

<br />

# ⚡ Admin Development Tools

**Professional-Grade Development & Debugging Suite for Roblox**

*A comprehensive, high-performance admin toolkit designed exclusively for private Roblox map development — covering testing, debugging, gameplay balancing, AI observation, and feature prototyping in a single, elegant interface.*

<br />

[![Version](https://img.shields.io/badge/version-2.0.0-00aaff?style=for-the-badge&logo=semver&logoColor=white)](https://github.com/username/admin-dev-tools/releases)
[![Lua](https://img.shields.io/badge/Lua-5.1+-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/license-MIT-00cc88?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)

<br />

[![Stars](https://img.shields.io/github/stars/username/admin-dev-tools?style=flat-square&color=ffcc00&logo=github)](https://github.com/username/admin-dev-tools/stargazers)
[![Forks](https://img.shields.io/github/forks/username/admin-dev-tools?style=flat-square&color=00aaff&logo=github)](https://github.com/username/admin-dev-tools/network/members)
[![Issues](https://img.shields.io/github/issues/username/admin-dev-tools?style=flat-square&color=ff6060&logo=github)](https://github.com/username/admin-dev-tools/issues)
[![Last Commit](https://img.shields.io/github/last-commit/username/admin-dev-tools?style=flat-square&color=8050ff&logo=git&logoColor=white)](https://github.com/username/admin-dev-tools/commits)
[![Maintained](https://img.shields.io/badge/maintained-yes-00cc88?style=flat-square)](https://github.com/username/admin-dev-tools)
[![Downloads](https://img.shields.io/github/downloads/username/admin-dev-tools/total?style=flat-square&color=8050ff&logo=github)](https://github.com/username/admin-dev-tools/releases)

<br />

[**Getting Started**](#-installation) · [**Features**](#-feature-overview) · [**Documentation**](#-module-documentation) · [**Configuration**](#%EF%B8%8F-configuration-reference) · [**Roadmap**](#-roadmap)

<br />

<img src="https://via.placeholder.com/880x460/0c0c14/00aaff?text=⚡+ADT+Dashboard+Preview+—+Replace+With+Actual+Screenshot" alt="ADT Dashboard Preview" width="88%" />

<sub>ADT v2.0.0 — Glassmorphism dark theme with neon blue accents, sidebar navigation, and modular development panels.</sub>

<br />

---

</div>

<br />

## 📑 Table of Contents

- [Introduction](#-introduction)
  - [Why ADT Exists](#why-adt-exists)
  - [Design Philosophy](#design-philosophy)
  - [Who This Is For](#who-this-is-for)
- [Feature Overview](#-feature-overview)
- [UI & Design System](#-ui--design-system)
  - [Visual Design Language](#visual-design-language)
  - [Component Library](#component-library)
  - [Layout Architecture](#layout-architecture)
- [Module Documentation](#-module-documentation)
  - [ESP Player](#-esp-player)
  - [Teleport Safety](#-teleport-safety)
  - [Speed Controller](#-speed-controller)
  - [POV Circle](#-pov-circle)
  - [On Point](#-on-point)
  - [Notification System](#-notification-system)
  - [Utilities & Helpers](#%EF%B8%8F-utilities--helpers)
  - [Cleanup & Memory Management](#-cleanup--memory-management)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
  - [Prerequisites](#prerequisites)
  - [Setup Guide](#setup-guide)
  - [Role System Configuration](#role-system-configuration)
- [Usage & Workflows](#-usage--workflows)
- [Configuration Reference](#%EF%B8%8F-configuration-reference)
  - [Theme Configuration](#theme-configuration)
  - [UI Configuration](#ui-configuration)
  - [Module Defaults](#module-defaults)
- [Performance & Optimization](#-performance--optimization)
  - [Optimization Techniques](#optimization-techniques)
  - [Resource Lifecycle](#resource-lifecycle)
  - [Performance Guidelines](#performance-guidelines)
- [Roadmap](#-roadmap)
- [FAQ](#-frequently-asked-questions)
- [Contributing](#-contributing)
- [License](#-license)
- [Developer](#-developer)
- [Credits & Acknowledgments](#-credits--acknowledgments)

<br />

---

<br />

## 🌟 Introduction

### Why ADT Exists

Traditional Roblox development workflows often require constant context-switching between Studio editing and in-game playtesting. Developers find themselves repeatedly spawning test characters, manually checking player positions, hand-verifying collision zones, and struggling to observe AI behavior without disrupting the game state. Each debug cycle eats away at productive development time.

**Admin Development Tools** was created to solve this problem. It is an in-game development overlay that provides real-time visual debugging, automated safety mechanisms, movement testing, camera observation tools, and spatial analysis — all accessible through a single, professionally-designed interface that lives inside your running game session.

> [!NOTE]
> This project is designed **solely for private map development**. It is intended to be used by map creators on their own games for testing, debugging, balancing, and feature development purposes. The `loadstring` loader mechanism is used purely as a convenient method to load and hot-update the development script from a remote source during iterative development — it is not part of any gameplay feature.

### Design Philosophy

ADT is built on four core principles:

| Principle | Description |
|:---|:---|
| **Developer-First** | Every feature exists to solve a real development problem. No bloat, no gimmicks — just tools that save time and reduce friction during the build-test-iterate cycle. |
| **Performance-Obsessed** | A development tool that degrades game performance defeats its own purpose. ADT is engineered to maintain negligible overhead through selective rendering, connection tracking, object pooling, and lazy evaluation. |
| **Visual Clarity** | Information must be immediately legible. The glassmorphism UI, color-coded systems, and spatial indicators are designed so developers can understand game state at a glance without reading logs. |
| **Clean Architecture** | The codebase follows modular separation, consistent naming, comprehensive commenting, and centralized configuration. Every function is documented. Every connection is tracked. Every resource is cleaned up. |

### Who This Is For

ADT is built for Roblox developers who:

- Build and maintain their own game maps (horror, survival, PvP, etc.)
- Need real-time visual feedback during gameplay testing
- Want to observe player/AI behavior without disrupting the game
- Require movement and traversal testing tools for level design
- Need spatial debugging for hitbox, collision, and damage area verification
- Value professional tooling with clean, maintainable code

<br />

---

<br />

## ✨ Feature Overview

<div align="center">

| | Feature | Status | Description |
|:---:|:---|:---:|:---|
| 👁 | **ESP Player System** | `Stable` | Full player visualization — box outlines, name tags, distance readout, health bars, and role-based color coding across all players in real-time |
| ⚡ | **Teleport Safety** | `Stable` | Automated safety teleportation — monitors all Killer-Survivor proximity and instantly relocates the admin character when danger radius is breached |
| 🏃 | **Speed Controller** | `Stable` | Real-time walk speed multiplier with slider and direct text input, persistent across character respawns, instant application |
| ◎ | **POV Circle** | `Stable` | Customizable center-screen circle overlay with crosshair, plus full camera spectation system for observing any player's perspective |
| 🎯 | **On Point Debug** | `Stable` | Context-aware debug indicators — renders hitbox visualization billboards on Survivors detected within the POV circle reference area |
| 🔔 | **Notification System** | `Stable` | Type-aware animated toast notifications with accent bars, progress timers, and automatic dismiss with stacking support |
| 🎨 | **Glassmorphism UI** | `Stable` | Premium dark theme interface with neon accents, sidebar navigation, smooth TweenService animations, and professional component library |
| 💾 | **Auto Cleanup** | `Stable` | Comprehensive resource management — tracked connections, tracked instances, module shutdown sequencing, and memory leak prevention |
| 🔄 | **Hot Reload** | `Stable` | Anti-duplicate execution with automatic previous-instance cleanup enabling seamless script re-execution during development |
| 🚀 | **Splash Screen** | `Stable` | Animated loading sequence with progress bar and module initialization status for professional startup experience |
| 📊 | **Performance Monitor** | `Planned` | Real-time FPS counter, memory usage graph, and per-module overhead display |
| 🧪 | **Developer Console** | `Planned` | In-game Lua command execution interface for advanced debugging and state inspection |
| 🔌 | **Plugin API** | `Planned` | Extensible module registration system for developing and loading custom tools |

</div>

<br />

---

<br />

## 🎨 UI & Design System

### Visual Design Language

ADT's interface draws inspiration from modern web application design systems — specifically the glassmorphism aesthetic popularized by contemporary dashboard frameworks. Every visual decision serves readability, hierarchy, and developer efficiency.

| Aspect | Implementation | Technical Detail |
|:---|:---|:---|
| **Glassmorphism** | Frosted glass panels with subtle transparency and stroke borders | `BackgroundTransparency: 0.2`, `UIStroke` with `0.5–0.6` transparency |
| **Dark Theme** | Deep dark background optimized for extended development sessions | Base `#0C0C14`, Surface `#12121E`, elevated `#19192A` |
| **Neon Accents** | Vibrant blue-cyan-purple color system for interactive elements | Primary `#00AAFF`, secondary `#00FFE6`, tertiary `#8250FF` |
| **Rounded Corners** | Consistent border radius across all elements | `12px` containers, `8px` components, `6px` small elements |
| **Gradient System** | Directional gradients on accent elements and progress indicators | `UIGradient` with `ColorSequence` from Neon Blue → Cyan |
| **Drop Shadow** | Simulated elevation shadow on the main window | `ImageLabel` slice with `0.5` transparency offset |
| **Typography** | Three-tier font hierarchy for clear information architecture | `GothamBold` headings, `GothamMedium` labels, `Gotham` body |
| **Color Semantics** | Consistent meaning across all color usage | 🟢 `#00DC82` success, 🟡 `#FFB400` warning, 🔴 `#FF3C50` danger |

### Component Library

ADT includes a purpose-built UI component library (`UIFramework`) that provides consistent, reusable elements across all module pages.

| Component | Behavior | Animation |
|:---|:---|:---|
| **Toggle Switch** | Binary on/off with animated knob sliding between positions, track color transitions between muted gray and neon blue | `Back` easing, `200ms` |
| **Slider** | Draggable track with gradient fill bar, floating knob with glow effect, and synchronized `TextBox` for direct value entry | Real-time update on drag |
| **Ripple Button** | Click triggers expanding circular ripple from center that fades to transparent, with hover background transition | `Quad` easing, `500ms` |
| **Player Dropdown** | Expandable list populated from `Players:GetPlayers()`, container smoothly resizes, hover highlights on options | `Quint` easing, `250ms` |
| **Color Picker** | Preset color grid with `UIStroke` selection indicator that transfers between swatches on click | Instant feedback |
| **Status Label** | Colored dot indicator paired with dynamic value text, supports programmatic color and text updates | Live update via setter |
| **Glass Panel** | Rounded container with `UIStroke` border and glass transparency, used as section wrapper | Consistent styling |
| **Section Title** | Uppercase muted text label used as visual divider between control groups | Static element |
| **Toast Notification** | Slide-in card with type-colored left accent bar, title/message hierarchy, progress bar countdown, auto-fade-dismiss | `300ms` fade in/out |
| **Splash Screen** | Full-screen overlay with centered logo animation, sequential text reveals, and stepped progress bar | `350ms` per step |

### Layout Architecture
