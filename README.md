<div align="center">

<!-- Banner -->
<img src="https://via.placeholder.com/1200x300/0a0a14/00aaff?text=⚡+Admin+Development+Tools" alt="ADT Banner" width="100%" />

<br />
<br />

<!-- Logo -->
<img src="https://via.placeholder.com/120x120/0a0a14/00aaff?text=⚡" alt="ADT Logo" width="120" height="120" />

<br />
<br />

# Admin Development Tools

### ⚡ Professional-Grade Development & Debugging Suite for Roblox

*A comprehensive, high-performance admin toolkit designed exclusively for private Roblox map development, testing, debugging, gameplay balancing, AI observation, and feature prototyping.*

<br />

<!-- Badges Row 1 -->
[![Version](https://img.shields.io/badge/version-2.0.0-00aaff?style=for-the-badge&logo=semver&logoColor=white)](https://github.com/username/admin-dev-tools/releases)
[![Lua](https://img.shields.io/badge/Lua-5.1+-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/license-MIT-00cc88?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)

<!-- Badges Row 2 -->
[![Status](https://img.shields.io/badge/status-Active-00dd80?style=flat-square&logo=statuspage&logoColor=white)](https://github.com/username/admin-dev-tools)
[![Stars](https://img.shields.io/github/stars/username/admin-dev-tools?style=flat-square&color=ffcc00&logo=github)](https://github.com/username/admin-dev-tools/stargazers)
[![Forks](https://img.shields.io/github/forks/username/admin-dev-tools?style=flat-square&color=00aaff&logo=github)](https://github.com/username/admin-dev-tools/network/members)
[![Issues](https://img.shields.io/github/issues/username/admin-dev-tools?style=flat-square&color=ff6060&logo=github)](https://github.com/username/admin-dev-tools/issues)
[![Last Commit](https://img.shields.io/github/last-commit/username/admin-dev-tools?style=flat-square&color=8050ff&logo=git&logoColor=white)](https://github.com/username/admin-dev-tools/commits)
[![Maintained](https://img.shields.io/badge/maintained-yes-00cc88?style=flat-square)](https://github.com/username/admin-dev-tools)
[![Release](https://img.shields.io/github/v/release/username/admin-dev-tools?style=flat-square&color=00aaff&logo=github)](https://github.com/username/admin-dev-tools/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/username/admin-dev-tools/total?style=flat-square&color=8050ff&logo=github)](https://github.com/username/admin-dev-tools/releases)

<br />

[**Getting Started**](#-installation) · [**Documentation**](#-modules--documentation) · [**Features**](#-features) · [**Roadmap**](#-roadmap) · [**FAQ**](#-faq) · [**Contributing**](#-contributing)

<br />

---

</div>

<br />

## 📑 Table of Contents

<details>
<summary><b>Click to expand navigation</b></summary>

<br />

- [Introduction](#-introduction)
- [Preview](#-preview)
- [Features](#-features)
- [UI Showcase](#-ui-showcase)
- [Modules & Documentation](#-modules--documentation)
  - [ESP Player](#-esp-player)
  - [Teleport Safety](#-teleport-safety)
  - [Speed Controller](#-speed-controller)
  - [POV Circle](#-pov-circle)
  - [On Point](#-on-point)
  - [Notification System](#-notification-system)
  - [Utilities & Config](#%EF%B8%8F-utilities--config)
  - [Cleanup & Memory](#-cleanup--memory-management)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Usage](#-usage)
- [Configuration](#%EF%B8%8F-configuration)
- [Performance](#-performance)
- [Roadmap](#-roadmap)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [License](#-license)
- [Developer](#-developer)
- [Credits](#-credits)

</details>

<br />

---

<br />

## 🌟 Introduction

<div align="center">
<img src="https://via.placeholder.com/800x80/0a0a14/00aaff?text=Built+for+Developers,+by+Developers" alt="Intro Banner" width="100%" />
</div>

<br />

**Admin Development Tools (ADT)** is a professional-grade development and debugging suite built exclusively for use on **privately-owned Roblox maps**. It provides a comprehensive set of tools that streamline the development workflow — from visual player debugging with ESP overlays, to automated safety teleportation, movement speed testing, camera spectation, and real-time hitbox observation.

> [!NOTE]
> This project is designed **solely for private map development**. It is intended to be used by map creators on their own games for testing, debugging, balancing, and feature development purposes. The loader mechanism (`loadstring`) is used purely as a convenient method to load and hot-update the script from a remote server during development iterations.

### Why ADT?

Traditional Roblox development often involves repeatedly entering Studio, running playtests, and manually checking game behavior. ADT eliminates friction by providing an **in-game developer overlay** that offers:

- 🔍 **Real-time visual debugging** — See player positions, roles, health, and distances at a glance
- ⚡ **Automated safety systems** — Protect your admin character during dangerous gameplay scenarios
- 🎮 **Movement testing** — Instantly adjust walk speed to test traversal and level design
- 📷 **Camera tools** — Spectate any player with POV circle overlay for observation
- 🎯 **Hitbox analysis** — On Point indicators help verify collision zones and damage areas
- 💎 **Premium UI/UX** — A glassmorphism dashboard that makes development feel professional

<br />

---

<br />

## 🖼 Preview

<div align="center">

> *Screenshots below are placeholders. Replace with actual screenshots of your ADT instance.*

<br />

### Main Dashboard
<img src="https://via.placeholder.com/900x500/0c0c14/00aaff?text=🖥️+Main+Dashboard+Preview" alt="Main Dashboard" width="90%" />

<br /><br />

<table>
<tr>
<td width="50%" align="center">

### ESP Menu
<img src="https://via.placeholder.com/420x280/0c0c14/00dd80?text=👁+ESP+Player+View" alt="ESP Preview" width="100%" />

</td>
<td width="50%" align="center">

### Teleport Safety
<img src="https://via.placeholder.com/420x280/0c0c14/ffb400?text=⚡+Teleport+Safety" alt="Teleport Preview" width="100%" />

</td>
</tr>
<tr>
<td width="50%" align="center">

### POV Circle & Spectate
<img src="https://via.placeholder.com/420x280/0c0c14/8050ff?text=◎+POV+Circle+Mode" alt="POV Preview" width="100%" />

</td>
<td width="50%" align="center">

### On Point Debug
<img src="https://via.placeholder.com/420x280/0c0c14/ff3c50?text=🎯+On+Point+Indicator" alt="On Point Preview" width="100%" />

</td>
</tr>
<tr>
<td width="50%" align="center">

### Settings Panel
<img src="https://via.placeholder.com/420x280/0c0c14/00aaff?text=⚙️+Settings+%26+Config" alt="Settings Preview" width="100%" />

</td>
<td width="50%" align="center">

### Notifications
<img src="https://via.placeholder.com/420x280/0c0c14/00e5c6?text=🔔+Notification+System" alt="Notifications Preview" width="100%" />

</td>
</tr>
</table>

</div>

<br />

---

<br />

## ✨ Features

<div align="center">

| | Feature | Status | Description |
|:---:|:---|:---:|:---|
| 👁 | **ESP Player System** | ✅ Stable | Full player visualization with box, name, distance, health, and role overlays |
| ⚡ | **Teleport Safety** | ✅ Stable | Auto-teleport admin when Killer approaches Survivor within configurable radius |
| 🏃 | **Speed Controller** | ✅ Stable | Real-time walk speed multiplier (1x–10x) with slider and text input |
| ◎ | **POV Circle** | ✅ Stable | Transparent center-screen circle with crosshair, spectate camera follow |
| 🎯 | **On Point Debug** | ✅ Stable | Hitbox/collision debug indicators when target enters POV circle area |
| 🔔 | **Notification System** | ✅ Stable | Animated toast notifications with progress bar and type indicators |
| ⚙️ | **Live Configuration** | ✅ Stable | All settings adjustable in real-time without restart |
| 🎨 | **Glassmorphism UI** | ✅ Stable | Premium dark theme with neon blue accents and smooth animations |
| 💾 | **Auto Cleanup** | ✅ Stable | Automatic resource cleanup prevents memory leaks |
| 🔄 | **Hot Reload** | ✅ Stable | Anti-duplicate execution with automatic previous instance cleanup |
| 📊 | **Performance Monitor** | 🔄 Planned | Real-time FPS and memory usage overlay |
| 🧪 | **Developer Console** | 🔄 Planned | In-game Lua command console for advanced debugging |
| 🔌 | **Plugin API** | 🔄 Planned | Extensible module system for custom tool development |
| 🌐 | **Multi-Language** | 🔄 Planned | Localization support for UI text |

</div>

<br />

---

<br />

## 🎨 UI Showcase

ADT features a meticulously crafted user interface inspired by modern web design principles. Every element is designed to provide a professional development experience.

<div align="center">

### Design System

| Category | Element | Implementation |
|:---|:---|:---|
| 🎨 **Theme** | Glassmorphism | Frosted glass panels with subtle transparency and stroke borders |
| 🌙 **Mode** | Dark Theme | Eye-friendly dark background (`#0C0C14`) optimized for extended use |
| 💎 **Accent** | Neon Blue | Primary accent `#00AAFF` with cyan `#00FFE6` and purple `#8250FF` variants |
| 🔄 **Animation** | TweenService | All transitions use `Quint` easing with configurable duration |
| 📐 **Layout** | Sidebar Navigation | Fixed sidebar with animated tab switching and page transitions |
| 🖼 **Window** | Draggable & Resizable | Full window management with minimize and close controls |
| 🔲 **Components** | Custom Library | Toggle switches, sliders, buttons with ripple, dropdowns, color pickers |
| 📊 **Dashboard** | Professional | Status indicators, section grouping, consistent spacing |

<br />

### Component Library

| Component | Description | Animation |
|:---|:---|:---|
| 🔘 **Toggle Switch** | Smooth knob sliding with color transition | `Back` easing, 200ms |
| 📏 **Slider** | Draggable track with gradient fill and value textbox | Real-time update |
| 🔵 **Ripple Button** | Click ripple effect expanding from center | `Quad` easing, 500ms |
| 📋 **Dropdown** | Expandable player list with hover states | `Quint` easing, 250ms |
| 🎨 **Color Picker** | Preset color grid with selection indicator | Instant feedback |
| 📊 **Status Label** | Colored dot indicator with dynamic value text | Live update |
| 📦 **Glass Panel** | Rounded container with stroke and transparency | Consistent style |
| 🔔 **Toast Notification** | Slide-in with progress bar auto-dismiss | Fade in/out, 300ms |
| 🚀 **Splash Screen** | Full-screen loader with progress steps | Sequential fade |
| 💧 **Watermark** | Persistent version indicator | Subtle transparency |

</div>

<br />

### Visual Design Principles
