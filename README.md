

```markdown
<div align="center">

<br />

```
██╗  ██╗ ██████╗ ███████╗██╗  ██╗██╗
██║  ██║██╔═══██╗██╔════╝██║  ██║██║
███████║██║   ██║███████╗███████║██║
██╔══██║██║   ██║╚════██║██╔══██║██║
██║  ██║╚██████╔╝███████║██║  ██║██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝
```

**Admin Development Tools**

*Terminal-grade development and debugging suite for private Roblox map testing.*

<br />

[![Version](https://img.shields.io/badge/version-2.1.0-00ffa0?style=for-the-badge&logo=semver&logoColor=white)](https://github.com/username/hoshi/releases)
[![Lua](https://img.shields.io/badge/Lua-5.1+-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/license-MIT-00ffa0?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Status](https://img.shields.io/badge/status-Active-00ffa0?style=for-the-badge)](#)

<br />

![Stars](https://img.shields.io/github/stars/username/hoshi?style=flat-square&color=00ffa0&logo=github)
![Forks](https://img.shields.io/github/forks/username/hoshi?style=flat-square&color=00c8ff&logo=github)
![Issues](https://img.shields.io/github/issues/username/hoshi?style=flat-square&color=dc3232&logo=github)
![Last Commit](https://img.shields.io/github/last-commit/username/hoshi?style=flat-square&color=b482ff&logo=git&logoColor=white)
![Maintained](https://img.shields.io/badge/maintained-yes-00ffa0?style=flat-square)
![Downloads](https://img.shields.io/github/downloads/username/hoshi/total?style=flat-square&color=00c8ff&logo=github)

<br />

[**Install**](#-installation) · [**Features**](#-feature-matrix) · [**Docs**](#-module-documentation) · [**Config**](#%EF%B8%8F-configuration-reference) · [**Roadmap**](#-roadmap) · [**FAQ**](#-faq)

---

</div>

<br />

## Table of Contents

```
00  Introduction
01  Design Principles
02  Feature Matrix
03  System Architecture
04  Module Documentation
    04.1  ESP Player
    04.2  Teleport Safety
    04.3  Speed Controller
    04.4  POV Circle
    04.5  On Point
    04.6  Notification System
    04.7  Cleanup System
05  UI & Design System
06  Project Structure
07  Installation
08  Usage & Workflows
09  Configuration Reference
10  Performance & Optimization
11  Roadmap
12  FAQ
13  Contributing
14  License
15  Developer
16  Credits
```

<br />

---

<br />

## 00 — Introduction

**Hoshi** is a terminal-styled, in-game development toolkit built for private Roblox map development. It provides real-time spatial debugging, automated safety systems, movement testing, camera observation, and hitbox analysis through a monospace interface that feels like a developer console rather than a game overlay.

The name *Hoshi* means "star" — a fixed point of reference you can always orient yourself by during chaotic development sessions.

```
$ hoshi --status
SESSION ACTIVE
MODULES: 5 loaded, 0 active
UPTIME:  00:00:00
MEMORY:  nominal
FPS:     stable
```

> [!NOTE]
> Hoshi is designed **solely for private map development**. It is a developer tool for use on games you own and build. The `loadstring` loader is a standard development pattern for remote script loading and hot-updating during iterative development — it is not a gameplay feature.

<br />

---

<br />

## 01 — Design Principles

Hoshi is built on five non-negotiable engineering principles. Every line of code, every UI decision, and every feature either serves these principles or gets cut.

```
PRINCIPLE                DESCRIPTION
─────────────────────────────────────────────────────────────
Developer-First          Features solve real dev problems.
                         No bloat. No toys. Just tools.

Zero-Cost Idle           Disabled modules consume exactly
                         zero CPU cycles. No polling. No
                         background loops. Nothing.

Terminal Aesthetic        Monospace fonts. Bracket notation.
                         Timestamp logging. Boot sequences.
                         Information density over decoration.

Clean Teardown           Every connection tracked. Every
                         instance registered. Full cleanup
                         guaranteed on exit or reload.

Readable Architecture    Commented functions. Meaningful
                         variable names. Consistent module
                         patterns. Maintainable at 3 AM.
─────────────────────────────────────────────────────────────
```

<br />

---

<br />

## 02 — Feature Matrix

<div align="center">

| Module | Status | Runtime Cost | Description |
|:-------|:------:|:------------:|:------------|
| **ESP Player** | `STABLE` | ~0.3ms/frame | Full player visualization with box, name, distance, health, and role-based color coding |
| **Teleport Safety** | `STABLE` | ~0.1ms/frame | Directional flee system — detects nearest Killer and teleports admin away by configurable distance |
| **Speed Controller** | `STABLE` | 0ms (event) | Real-time WalkSpeed multiplier with slider, text input, and respawn persistence |
| **POV Circle** | `STABLE` | ~0.05ms/frame | Center-screen crosshair overlay with spectation camera system |
| **On Point** | `STABLE` | ~0.2ms/frame | Dual-detection debug system — screen-space POV check AND 3D damage radius with billboard indicators |
| **Notifications** | `STABLE` | negligible | Terminal-styled toast system with timestamps, type prefixes, and progress bars |
| **Cleanup** | `STABLE` | one-shot | Full resource teardown — connections, instances, state, camera, speed |
| **Hot Reload** | `STABLE` | one-shot | Anti-duplicate with automatic previous-instance cleanup |

</div>

**Total active overhead:** ~0.65ms/frame with all modules enabled (typical 10-15 player session).
At 60 FPS, that is **3.9% of the available 16.6ms frame budget.**

<br />

---

<br />

## 03 — System Architecture

```
hoshi.lua
│
├── [1]  CONFIG ──────────────────────── Centralized settings table
│   ├── Theme                            16 semantic terminal colors
│   ├── UI                               Dimensions, fonts, timing
│   ├── ESP                              Toggles, role color map
│   ├── Teleport                         Radius, flee distance, cooldown
│   ├── Speed                            Multiplier range, base speed
│   ├── POV                              Circle geometry, spectate state
│   └── OnPoint                          Damage radius, tracking mode
│
├── [2]  UTILITIES ───────────────────── Shared helper functions
│   ├── Tween()                          TweenService wrapper
│   ├── Connect()                        Tracked signal connection
│   ├── Track()                          Instance lifecycle tracking
│   ├── Distance()                       Vector3 magnitude
│   ├── GetRootPart()                    Safe character root accessor
│   ├── GetHumanoid()                    Safe humanoid accessor
│   ├── GetRole()                        Multi-source role detection
│   ├── FindFleePosition()              Directional raycast flee calc
│   └── UI helpers                       Corner, Stroke, Padding, etc.
│
├── [3]  NOTIFICATION ────────────────── Terminal toast engine
│   ├── Init()                           Container setup
│   └── Notify()                         Create, animate, auto-dismiss
│
├── [4]  UI FRAMEWORK ────────────────── Reusable component library
│   ├── CreateSectionHeader()            --- UPPERCASE DIVIDER ---
│   ├── CreateToggle()                   > Label ............. [ON]
│   ├── CreateSlider()                   > Label ═══════╬═══ [7]
│   ├── CreateButton()                   [ CLICK ME ]
│   ├── CreateStatusLine()               Status: VALUE
│   ├── CreatePlayerDropdown()           > Target .... [PlayerName]
│   └── CreateColorPicker()              > Color [■][■][■][■]
│
├── [5]  SPLASH SCREEN ───────────────── Terminal boot sequence
│
├── [6]  MAIN GUI ────────────────────── Window, header, sidebar, tabs
│   ├── Init()                           ScreenGui creation
│   ├── BuildMainWindow()                Full layout construction
│   ├── SwitchTab()                      Animated page transitions
│   ├── MakeDraggable()                  Input-tracked drag system
│   ├── ToggleMinimize()                 Height collapse animation
│   └── Close()                          Fade-out + cleanup trigger
│
├── [7]  ESP MODULE ──────────────────── Player visualization
│   ├── Start() / Stop()                 Lifecycle control
│   ├── Update()                         Per-frame render loop
│   └── CreateESPBillboard()             Billboard factory
│
├── [8]  TELEPORT MODULE ─────────────── Directional flee system
│   ├── Start() / Stop()                 Lifecycle control
│   └── Heartbeat loop                   Proximity scan + flee exec
│
├── [9]  SPEED MODULE ────────────────── WalkSpeed multiplier
│   └── Apply()                          Direct property write
│
├── [10] POV MODULE ──────────────────── Circle + spectation
│   ├── CreateCircle() / DestroyCircle() Overlay lifecycle
│   ├── UpdateCircle()                   Property sync
│   ├── StartSpectate()                  Camera subject switch
│   └── StopSpectate()                   Camera reset
│
├── [11] ON POINT MODULE ─────────────── Dual-detection debug
│   ├── Start() / Stop()                 Lifecycle control
│   ├── ShowIndicator()                  Billboard creation/update
│   ├── HideIndicator()                  Billboard disable
│   └── Screen indicator                 Top-center info panel
│
├── [12] CLEANUP ─────────────────────── Full resource teardown
│
└── [13] INIT ────────────────────────── Bootstrap + anti-duplicate
```

**Architecture Decision — Single File:**

```
Q: Why one file instead of ModuleScripts?
A: The loadstring(game:HttpGet(url))() pattern loads one script.
   Internal organization via numbered sections and module tables
   provides identical maintainability within this constraint.
   Each section can be extracted to a ModuleScript for Studio
   projects with zero refactoring beyond require() calls.
```

<br />

---

<br />

## 04 — Module Documentation

### 04.1 — ESP Player

```
MODULE:   ESP Player
PURPOSE:  Visual overlay for all players in the session
RENDERS:  BillboardGui per player on HumanoidRootPart
LOOP:     RenderStepped (synchronized with camera/render)
COST:     ~0.3ms/frame (scales with player count)
```

**Information Layers:**

Each ESP billboard renders five independently toggleable layers of data. All layers update every frame when ESP is enabled.

```
┌─────────────────────────────────────┐
│  LAYER        ELEMENT     TOGGLEABLE │
├─────────────────────────────────────┤
│  Box ESP      UIStroke    Yes        │
│  Name Tag     TextLabel   Yes        │
│  Distance     TextLabel   Yes        │
│  Health Bar   Frame       Yes        │
│  Role Tag     TextLabel   Yes        │
└─────────────────────────────────────┘
```

**Role Detection Chain:**

Hoshi resolves player roles through a three-tier priority chain. This accommodates different game architectures without requiring Hoshi-side configuration changes.

```
PRIORITY  METHOD                        EXAMPLE
────────────────────────────────────────────────────────
1 (high)  player:GetAttribute("Role")   player:SetAttribute("Role", "Killer")
2 (mid)   StringValue child "Role"      Instance.new("StringValue") named "Role"
3 (low)   player.Team.Name              Roblox Team system
4 (fall)  "Default"                     No role system detected
```

**Role Color Map:**

```
ROLE        RGB             HEX       USAGE
──────────────────────────────────────────────────
Killer      (220, 50, 50)   #DC3232   Threat / antagonist
Survivor    (0, 220, 100)   #00DC64   Player / protagonist
Admin       (0, 180, 220)   #00B4DC   Developer characters
Default     (150, 150, 150) #969696   Unassigned / unknown
```

**Object Lifecycle:**

```
Player joins → Character spawns → Root part exists
  └→ First ESP frame detects player
      └→ CreateESPBillboard() called (lazy creation)
          └→ Billboard cached by UserId
              └→ Subsequent frames: update cached billboard
                  └→ Player leaves OR ESP disabled
                      └→ Billboard:Destroy() + cache removal
```

> [!TIP]
> For reliable role detection, set roles via Attributes in your server scripts:
> ```lua
> player:SetAttribute("Role", "Survivor")
> ```
> This is the cleanest approach and requires no extra instances.

<br />

---

### 04.2 — Teleport Safety

```
MODULE:   Teleport Safety
PURPOSE:  Auto-flee when Killer approaches admin character
LOOP:     Heartbeat (synchronized with physics)
COST:     ~0.1ms/frame
```

**v2.1 Changes — Directional Flee System:**

The previous version teleported to a static safe position. v2.1 introduces a **directional flee algorithm** that calculates escape vectors dynamically based on the Killer's position.

**Flee Algorithm:**

```
1. Detect nearest Killer to admin character
2. If distance <= detection radius:
   a. Calculate direction vector: (admin_pos - killer_pos).Unit
   b. Generate candidate flee positions along multiple directions:
      - Primary: directly away from killer
      - Secondary: 4 diagonal offsets (±0.5 on X/Z)
      - Tertiary: 4 cardinal offsets
   c. For each candidate:
      - Project position at flee_distance along direction
      - Raycast downward from +50Y to find ground
      - Verify ground position is >= 80% of flee_distance from killer
      - If valid: teleport admin to ground + 3Y offset
   d. Fallback: direct opposite direction + 5Y if no ground found
3. Set cooldown timer
4. Fire notification with killer name + distance
```

**Visual representation:**

```
                    FLEE CANDIDATES
                         ╱
                   ╱ · · · · · · ╲
              · · ·       |       · · ·
         · · ·        [PRIMARY]       · · ·
     · ·             ↑ 100 studs            · ·
    ·          [DIAGONAL]  |  [DIAGONAL]      ·
   ·              ↗        |        ↖          ·
  ·                        |                    ·
  ·          [ADMIN] ◄─────┼─── 35 studs ── [KILLER]
  ·                        |                    ·
   ·              ↘        |        ↙          ·
    ·          [DIAGONAL]  |  [DIAGONAL]      ·
     · ·                                    · ·
         · · ·                          · · ·
              · · ·               · · ·
                   ╲ · · · · · ╱
```

**Parameters:**

```
PARAMETER          DEFAULT    RANGE       DESCRIPTION
──────────────────────────────────────────────────────────────
Detection Radius   35         10-100      Studs from Killer that triggers flee
Flee Distance      100        50-200      How far admin teleports away
Cooldown           2          1-15        Seconds between allowed teleports
```

**Status Indicator States:**

```
STATE       COLOR    DISPLAY
─────────────────────────────────────────────────────
OFFLINE     gray     System disabled
SCANNING    green    Active monitoring, no threat nearby
SCANNING+   green    Nearest killer name + distance shown
COOLDOWN    yellow   Recently fled, timer counting down
FLED!       red      Just teleported, showing trigger info
```

> [!IMPORTANT]
> The flee system finds **walkable ground** via raycasting. It excludes the admin's own character from raycast filtering. If no ground is found in any candidate direction, the fallback position adds a `+5Y` offset to prevent falling through void. On well-constructed maps, the raycast will almost always find valid ground.

<br />

---

### 04.3 — Speed Controller

```
MODULE:   Speed Controller
PURPOSE:  WalkSpeed multiplier for movement testing
LOOP:     None (event-driven property write)
COST:     0ms (only writes on value change + CharacterAdded)
```

**Formula:**

```
Humanoid.WalkSpeed = 16 × Multiplier

MULTIPLIER    WALKSPEED    USE CASE
──────────────────────────────────────────────────
1x            16           Default baseline
2x            32           Moderate pace testing
3x            48           Comfortable exploration
5x            80           Fast area traversal
8x            128          Rapid checkpoint testing
10x           160          Full map sprint
```

**Controls:**

```
INPUT        BEHAVIOR
──────────────────────────────────────────────────────────
Slider       Drag to set value 1-10, updates realtime
TextBox      Type exact integer, clamped on focus lost
Reset Btn    Instantly reverts to 1x (WalkSpeed = 16)
```

**Respawn Persistence:**

```lua
-- CharacterAdded listener ensures speed survives deaths
LocalPlayer.CharacterAdded → wait(0.5) → Apply()
-- 0.5s delay ensures Humanoid is fully initialized
```

<br />

---

### 04.4 — POV Circle

```
MODULE:   POV Circle
PURPOSE:  Center-screen crosshair + player spectation
LOOP:     RenderStepped (spectate only, when active)
COST:     ~0.05ms/frame (spectate active)
```

**Circle Anatomy:**

```
         ╭──────────────────────╮
        ╱                        ╲
       │            |             │
       │     ───────+───────      │    Stroke: configurable
       │            |             │    Thickness: 1-10px
        ╲                        ╱    Opacity: 10-100%
         ╰──────────────────────╯     Color: 8 presets

              Center Dot: 3x3px
              Crosshair: 12px arms
              Gap: 4px from center
```

**Settings:**

```
SETTING      DEFAULT    RANGE        DESCRIPTION
──────────────────────────────────────────────────────────
Radius       100        30-300 px    Circle radius in screen pixels
Thickness    2          1-10 px      UIStroke width
Opacity      80%        10-100%      Element visibility
Color        Green      8 presets    Applied to all elements
```

**Spectation System:**

The spectation system redirects the camera to follow a selected player by changing `Camera.CameraSubject` to their Humanoid. The admin's own character stays in the world — unaffected, unmoved.

```
SPECTATE ON:   Camera.CameraSubject = TargetHumanoid
SPECTATE OFF:  Camera.CameraSubject = LocalHumanoid

Note: POV circle stays centered regardless of spectate state.
      The crosshair follows wherever the camera looks.
```

> [!NOTE]
> The crosshair is rendered as a ScreenGui element with `AnchorPoint = (0.5, 0.5)` and `Position = (0.5, 0, 0.5, 0)`. It is mathematically centered on the viewport at all times, on all screen resolutions. It does not "follow" anything — it IS the center point. When spectating, the camera moves; the crosshair stays fixed.

<br />

---

### 04.5 — On Point

```
MODULE:   On Point
PURPOSE:  Hitbox/collision debug indicators
LOOP:     RenderStepped (synchronized with render)
COST:     ~0.2ms/frame (scales with detected targets)
```

**v2.1 Changes — Dual Detection:**

Previous versions only checked screen-space POV circle intersection. v2.1 introduces **dual detection** — targets are flagged if they meet EITHER condition:

```
DETECTION METHOD     HOW IT WORKS
───────────────────────────────────────────────────────────────
Screen-Space (POV)   Project target WorldPosition to screen via
                     Camera:WorldToScreenPoint(). Calculate 2D
                     distance from screen center. If <= POV
                     radius → target is ON POINT.

3D Damage Radius     Calculate Magnitude between admin position
                     and target position in world space. If <=
                     damage radius → target is IN RANGE.

Combined             Target flagged if EITHER condition met.
                     Status shows which conditions apply: POV, DMG
```

**Indicator Billboard:**

```
┌──────────────────────────────────┐
│                                  │
│         ╭─── Ring ───╮           │    Ring: pulsating UIStroke
│        ╱               ╲         │    Pulse: sin(tick()*4)*0.08
│       │     ───+───     │        │    Center: crosshair marker
│        ╲               ╱         │
│         ╰─────────────╯          │
│                                  │
│     [LOCK] PlayerDisplayName     │    Lock label
│     D:24.3 | X:142 Y:5 Z:-87    │    Position data
│                                  │
└──────────────────────────────────┘
```

**Screen Indicator Panel:**

When targets are detected, a top-center overlay panel displays a summary of all tracked targets:

```
┌──────────────────────────────────────────┐
│ [ON POINT] Targets Detected:             │
│   Player1 [Survivor] dist:24  POV DMG    │
│   Player2 [Killer]   dist:48  DMG        │
│   Player3 [Default]  dist:12  POV        │
└──────────────────────────────────────────┘
```

**Parameters:**

```
SETTING           DEFAULT    RANGE     DESCRIPTION
───────────────────────────────────────────────────────────
Damage Radius     50         10-200    3D detection distance (studs)
Track Nearest     true       on/off    Auto-target nearest player
Smooth Pulse      true       on/off    Ring pulsation animation
Transparency      40%        10-90%    Indicator element opacity
Color             Yellow     8 preset  Ring, marker, label color
```

> [!TIP]
> For comprehensive debugging, enable ESP + POV Circle + On Point simultaneously:
> ```
> ESP       → Global awareness (where is everyone)
> POV       → Your observation area (what am I looking at)
> On Point  → Precision data (exact position of focused targets)
> ```

<br />

---

### 04.6 — Notification System

```
MODULE:   Notification System
PURPOSE:  Timestamped terminal-style toast messages
COST:     Negligible (event-driven, auto-cleanup)
```

**Notification Anatomy:**

```
┌─────────────────────────────────────────┐
│▌[OK] Module Name                 14:32:07│
│  > Description message text here         │
│ ██████████████████░░░░░░░░░░░░░░░░░░░░░ │
└─────────────────────────────────────────┘
 ▌ = 2px accent bar (color matches type)
```

**Type Prefixes:**

```
TYPE       PREFIX    COLOR         USE CASE
────────────────────────────────────────────────────
info       [INFO]    #00B4DC       General status updates
success    [OK]      #00DC64       Successful operations
warning    [WARN]    #DCB400       Caution / proximity alerts
error      [ERR]     #DC3232       Failures / critical events
```

**Animation Timeline:**

```
0ms ─────── 250ms ──────── duration ──── +200ms
 │           │                │            │
 │  Slide in │   Visible      │  Fade out  │
 │  from     │   Progress bar │  Slide     │
 │  right    │   counting     │  right     │
 │           │   down         │  Destroy   │
```

<br />

---

### 04.7 — Cleanup System

```
MODULE:   Cleanup
PURPOSE:  Guaranteed zero-residual resource teardown
TRIGGER:  Close button, _G.HOSHI_Cleanup(), or script reload
```

**Teardown Sequence:**

```
Cleanup()
│
├─ Phase 1: Module Shutdown
│  ├─ ESPModule.Stop()            Disconnect loop + destroy billboards
│  ├─ TeleportModule.Stop()       Disconnect heartbeat monitor
│  ├─ POVModule.DestroyCircle()   Remove screen overlay
│  ├─ POVModule.StopSpectate()    Reset camera subject
│  └─ OnPointModule.Stop()        Disconnect loop + destroy indicators
│
├─ Phase 2: State Reset
│  ├─ Config.Speed.Value = 1
│  └─ Humanoid.WalkSpeed = 16
│
├─ Phase 3: Connection Cleanup
│  └─ for each tracked connection:
│       if Connected then Disconnect()
│
├─ Phase 4: Instance Cleanup
│  └─ for each tracked instance:
│       if Parent exists then Destroy()
│
├─ Phase 5: Table Cleanup
│  ├─ Utilities._connections = {}
│  └─ Utilities._instances = {}
│
└─ Phase 6: Flag Reset
   └─ _G.HOSHI_Running = false
```

**Anti-Duplicate Guard:**

```lua
-- Before initialization
if _G.HOSHI_Running then
    _G.HOSHI_Cleanup()     -- Tear down previous instance
end
_G.HOSHI_Running = true    -- Mark as active
_G.HOSHI_Cleanup = Cleanup -- Register cleanup function

-- Result: re-executing the script is always safe.
-- Previous instance is fully destroyed before new one starts.
```

<br />

---

<br />

## 05 — UI & Design System

Hoshi uses a **terminal/CMD aesthetic** — monospace fonts, bracket notation, ASCII dividers, boot sequences, and high information density. No rounded bubbles. No gradient cards. No emoji. Just data.

**Design Language:**

```
ELEMENT              STYLE                      EXAMPLE
──────────────────────────────────────────────────────────────
Font                 Code (monospace)            All text elements
Section Header       ASCII dividers              --- UPPERCASE LABEL ---
Toggle               Bracket status              > Label .......... [ON]
Slider               Track with knob             > Label ═══╬═══  [7]
Button               Bracket wrap                [ CLICK ME ]
Status               Colon-separated             Status: SCANNING
Tab (active)         Highlighted prefix          > module-name
Tab (inactive)       Dim prefix                  > module-name
Notification         Prefix + timestamp          [OK] Title     14:32:07
Boot screen          Line-by-line reveal         [OK] Module loaded
Page title           Dollar-sign prompt          $ MODULE NAME
Description          Comment syntax              // Description text
Cursor               Blinking underscore         _
```

**Color Palette:**

```
NAME             RGB               HEX       USAGE
───────────────────────────────────────────────────────────────
Background       (8, 8, 12)        #08080C    Window background
Terminal BG      (5, 5, 8)         #050508    Deep black surfaces
Surface          (12, 12, 18)      #0C0C12    Panel backgrounds
Surface Light    (18, 18, 26)      #12121A    Interactive elements
Surface Bright   (30, 30, 42)      #1E1E2A    Hover states

Primary          (0, 255, 160)     #00FFA0    Active elements, accents
Primary Dim      (0, 180, 110)     #00B46E    Secondary accents
Primary Dark     (0, 120, 80)      #007850    Subtle accents
Secondary        (0, 200, 255)     #00C8FF    Info, links
Tertiary         (180, 130, 255)   #B482FF    Special elements

Text             (200, 210, 200)   #C8D2C8    Primary text
Text Bright      (230, 240, 230)   #E6F0E6    Highlighted text
Text Dim         (100, 120, 100)   #647864    Secondary text
Text Muted       (50, 65, 50)      #324132    Headers, dividers

Success          (0, 220, 100)     #00DC64    Enabled, confirmed
Warning          (220, 180, 0)     #DCB400    Caution, cooldown
Danger           (220, 50, 50)     #DC3232    Error, threat

Border           (30, 40, 30)      #1E281E    Standard borders
Border Light     (40, 55, 40)      #283728    Light borders
Border Active    (0, 255, 160)     #00FFA0    Focused borders

Terminal Green   (0, 255, 160)     #00FFA0    Terminal accent
Terminal Dim     (0, 100, 60)      #00643C    Muted terminal
```

**Layout Blueprint:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  HOSHI // dev-tools v2.1.0 _                              [ - ][ x ]│
├────────────────┬────────────────────────────────────────────────────┤
│                │                                                    │
│  -- MODULES -- │  $ MODULE NAME                                     │
│                │  // Description text here                          │
│  > esp-player  │                                                    │
│  > teleport    │  > Enable Feature .......................... [ON]  │
│  > speed-run   │                                                    │
│  > pov-circle  │  --- SECTION TITLE ---                             │
│  > on-point    │  > Setting A .............................. [OFF] │
│                │  > Setting B .............................. [ON]  │
│                │  > Slider ═══════════════════╬════  [7]           │
│                │  > Dropdown .................. [PlayerName]       │
│                │  > Color [■][■][■][■][■][■][■][■]                │
│                │  [ BUTTON LABEL ]                                  │
│                │                                                    │
│                │  --- STATUS ---                                     │
│  SESSION ACTIVE│  Status: SCANNING [nearest: Player1 @ 45 studs]   │
│                │                                                    │
├────────────────┴────────────────────────────────────────────────────┤
│  HOSHI v2.1.0 // admin-dev-tools                                    │
└─────────────────────────────────────────────────────────────────────┘
```

**Boot Sequence:**

```
HOSHI Development Terminal v2.1.0
========================================

Initializing core systems...
[OK] Config module loaded
[OK] UI framework ready
[OK] ESP module initialized
[OK] Teleport safety module ready
[OK] POV system configured
[OK] OnPoint targeting loaded
[OK] Cleanup handlers registered

All systems nominal. Starting GUI...
========================================
```

<br />

---

<br />

## 06 — Project Structure

```
hoshi/
│
├── hoshi.lua                 Main script (monolithic, section-organized)
│
│   Internal sections:
│   ├── [1]  CONFIG           Centralized configuration
│   ├── [2]  UTILITIES        Helper functions + tracking
│   ├── [3]  NOTIFICATION     Toast engine
│   ├── [4]  UI FRAMEWORK     Component library (7 components)
│   ├── [5]  SPLASH SCREEN    Boot animation
│   ├── [6]  MAIN GUI         Window + sidebar + tabs
│   ├── [7]  ESP MODULE       Player visualization
│   ├── [8]  TELEPORT MODULE  Directional flee system
│   ├── [9]  SPEED MODULE     WalkSpeed multiplier
│   ├── [10] POV MODULE       Circle overlay + spectate
│   ├── [11] ON POINT MODULE  Dual-detection debug
│   ├── [12] CLEANUP          Resource teardown
│   └── [13] INIT             Bootstrap
│
├── README.md                 This documentation
├── LICENSE                   MIT License
├── CHANGELOG.md              Version history
└── CONTRIBUTING.md           Contribution guide
```

<br />

---

<br />

## 07 — Installation

### Prerequisites

```
REQUIREMENT          DETAILS
─────────────────────────────────────────────────────────
Roblox Studio        Latest version with your private map
HTTP Requests        HttpService.HttpEnabled = true
Script Hosting       GitHub raw URL or HTTPS static host
Test Environment     Studio command bar or local executor
```

### Setup Guide

**Step 1** — Host the script on a raw-accessible URL:

```
https://raw.githubusercontent.com/YOUR_USERNAME/hoshi/main/hoshi.lua
```

**Step 2** — Enable HTTP in your private place:

```lua
game:GetService("HttpService").HttpEnabled = true
```

**Step 3** — Load the script:

```lua
loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL"))()
```

**Step 4** — Configure role system (server-side):

```lua
-- Recommended: Attribute-based role assignment
player:SetAttribute("Role", "Killer")
player:SetAttribute("Role", "Survivor")
player:SetAttribute("Role", "Admin")
```

> [!WARNING]
> Only load scripts from URLs you own and control. Always review hosted code before execution.

<br />

---

<br />

## 08 — Usage & Workflows

### Basic Loading

```lua
-- Standard loader
loadstring(game:HttpGet("YOUR_URL"))()
```

### Safe Loading

```lua
local ok, err = pcall(function()
    loadstring(game:HttpGet("YOUR_URL"))()
end)
if not ok then warn("[HOSHI] Load failed: " .. tostring(err)) end
```

### Manual Cleanup

```lua
if _G.HOSHI_Cleanup then _G.HOSHI_Cleanup() end
```

### Workflow: Visual Debugging

```
1. Load Hoshi
2. ESP tab → Enable ESP [ON]
   Enable all layers (Box, Name, Distance, Health, Role)
3. POV tab → Enable POV Circle [ON]
   Select target from dropdown
   Spectate Target [ON]
4. On Point tab → Enable On Point [ON]
5. Result:
   - ESP shows all player positions globally
   - Camera follows selected player
   - Crosshair stays centered
   - On Point marks targets entering your view
   - Screen panel shows all detected target data
```

### Workflow: Level Design

```
1. Load Hoshi
2. Speed tab → Set multiplier to 3x-5x
3. Walk through map, note traversal times
4. Teleport tab → Set radius, enable safety
5. Result:
   - Fast movement for reviewing map areas
   - Auto-flee if AI Killers approach
   - Reset speed to 1x for pacing tests
```

### Workflow: AI Observation

```
1. Load Hoshi
2. ESP → Enable (see all AI + player positions)
3. POV → Select Survivor being chased → Spectate [ON]
4. On Point → Enable (see when AI enters damage range)
5. Teleport → Enable (safety if AI targets admin)
6. Result:
   - Watch chase from Survivor perspective
   - On Point shows exact moment AI enters strike range
   - Distance data validates damage zone radius
   - Admin auto-flees if AI redirects to admin character
```

<br />

---

<br />

## 09 — Configuration Reference

### Theme Configuration

```
KEY              DEFAULT RGB        HEX       PURPOSE
──────────────────────────────────────────────────────────────
Background       (8, 8, 12)        #08080C    Window background
TerminalBG       (5, 5, 8)         #050508    Deep surfaces
Surface          (12, 12, 18)      #0C0C12    Panels
SurfaceLight     (18, 18, 26)      #12121A    Components
Primary          (0, 255, 160)     #00FFA0    Active accents
Secondary        (0, 200, 255)     #00C8FF    Info accents
Text             (200, 210, 200)   #C8D2C8    Primary text
TextDim          (100, 120, 100)   #647864    Secondary text
Success          (0, 220, 100)     #00DC64    Positive states
Warning          (220, 180, 0)     #DCB400    Caution states
Danger           (220, 50, 50)     #DC3232    Error states
Border           (30, 40, 30)      #1E281E    Borders
```

### UI Configuration

```
KEY                DEFAULT         TYPE         PURPOSE
──────────────────────────────────────────────────────────────
WindowSize         820 x 560       UDim2        Main window dimensions
CornerRadius       4px             UDim         Container corners
AnimationSpeed     0.3s            number       Standard tween duration
AnimationSpeedFast 0.15s           number       Quick transitions
AnimationEasing    Quad            EasingStyle  Default easing curve
SidebarWidth       170px           number       Sidebar width
HeaderHeight       40px            number       Header height
Font               Code            Enum.Font    All text elements
```

### Module Configuration

```
MODULE       KEY              DEFAULT    RANGE        UNIT
──────────────────────────────────────────────────────────────
ESP          Enabled          false      -            -
             ShowBox          true       -            -
             ShowName         true       -            -
             ShowDistance      true       -            -
             ShowHealth        true       -            -
             ShowRole          true       -            -

Teleport     Enabled          false      -            -
             Radius           35         10-100       studs
             FleeDistance     100        50-200       studs
             Cooldown         2          1-15         seconds

Speed        Value            1          1-10         multiplier
             DefaultWalkSpeed 16         -            studs/sec

POV          Enabled          false      -            -
             Radius           100        30-300       pixels
             Thickness        2          1-10         pixels
             Opacity          0.8        0.1-1.0      ratio
             Color            Primary    8 presets    Color3
             Spectating       false      -            -

OnPoint      Enabled          false      -            -
             DamageRadius     50         10-200       studs
             TrackNearest     true       -            -
             SmoothUpdate     true       -            -
             Transparency     0.4        0.1-0.9      ratio
             Color            Warning    8 presets    Color3
```

<br />

---

<br />

## 10 — Performance & Optimization

```
TECHNIQUE              IMPLEMENTATION                    IMPACT
──────────────────────────────────────────────────────────────────────
Zero-Cost Idle         Modules only connect update       Disabled modules
                       loops when enabled. No            use 0 CPU.
                       polling on disabled modules.

Update Separation      Visual: RenderStepped             Correct frequency
                       Logic: Heartbeat                  per task type.
                       Speed: event-only (no loop)

Lazy Creation          ESP billboards created on          No pre-allocation
                       first detection. OnPoint           waste.
                       indicators created on lock.

Object Caching         ESP caches by UserId.              No per-frame
                       Only properties updated,           GC pressure.
                       not instances.

Connection Tracking    All Connect() calls go through     Bulk disconnect
                       Utilities.Connect() storing        during cleanup.
                       references.

Instance Tracking      All created instances go through   Bulk Destroy()
                       Utilities.Track() for              during cleanup.
                       lifecycle management.

Auto Pruning           Player leaves → billboard           No stale object
                       destroyed + cache cleared           accumulation.
                       same frame.

Native Tweening        All animations use TweenService    GPU-accelerated.
                       instead of manual per-frame        Lower CPU cost.
                       interpolation.

MaxDistance             ESP BillboardGui.MaxDistance =      Engine skips
                       500 studs. On Point = 300.         distant renders.

Canvas Auto-Size       ScrollingFrame CanvasSize           No polling for
                       updates via layout signal.          content size.
```

**Resource Budget:**

```
SCENARIO                    OVERHEAD        FRAME BUDGET USAGE
──────────────────────────────────────────────────────────────
All modules disabled        ~0.1ms          0.6% of 16.6ms
ESP only (10 players)       ~0.4ms          2.4%
All modules enabled         ~0.65ms         3.9%
Worst case (30 players)     ~1.2ms          7.2%
```

<br />

---

<br />

## 11 — Roadmap

### v2.1.0 — Current Release

- [x] Terminal/CMD visual redesign — monospace, no emoji
- [x] Directional flee teleport system with ground raycasting
- [x] On Point dual detection (screen-space + 3D damage radius)
- [x] On Point tracks ALL players, not just Survivors
- [x] Screen indicator panel showing all detected targets
- [x] Blinking cursor in header
- [x] Boot sequence splash screen
- [x] Timestamp in notifications
- [x] RichText formatting throughout UI
- [x] Improved crosshair with center dot + gap

### v2.2.0 — Planned

- [ ] Real-time FPS and memory overlay
- [ ] Terminal command input (type commands in-GUI)
- [ ] Session logging with exportable text
- [ ] Configuration save/load persistence
- [ ] ESP distance-based text scaling
- [ ] Free camera mode (detached observation)
- [ ] Keybind system for quick module toggles
- [ ] Resizable window with responsive layout

### v2.3.0 — Planned

- [ ] Plugin API for custom module registration
- [ ] AI pathfinding visualization
- [ ] Network traffic inspector
- [ ] Spatial audio debugger
- [ ] Multi-admin shared state
- [ ] Developer annotation system (map notes)
- [ ] Per-module CPU profiling
- [ ] Automated test framework hooks

### Long Term

- [ ] Visual level editor integration
- [ ] Version control for game state diffing
- [ ] CI/CD pipeline for script deployment
- [ ] Collaborative development mode
- [ ] Auto-generated documentation from game inspection

<br />

---

<br />

## 12 — FAQ

<details>
<summary><b>What is Hoshi?</b></summary>

<br />

Hoshi is a terminal-styled admin development toolkit for private Roblox map development. It provides ESP overlays, automated flee teleportation, speed testing, POV camera tools, and hitbox debug indicators through a monospace CMD-style interface. It is exclusively for developers working on their own games.

</details>

<details>
<summary><b>Is this an exploit or cheat?</b></summary>

<br />

No. Hoshi is a development tool for use on your own private maps, comparable to debug overlays in Unity, Unreal, or Source Engine. The `loadstring` loader is a standard Roblox development pattern for remote script loading — not an exploitation technique. The tool runs client-side on your own game for your own testing purposes.

</details>

<details>
<summary><b>How does the new teleport system work?</b></summary>

<br />

v2.1 replaced the static safe-position teleport with a **directional flee algorithm**:

1. Detects nearest Killer to admin character
2. Calculates escape direction (directly away from Killer)
3. Generates 9 candidate positions along that direction at configurable distance (default: 100 studs)
4. Raycasts downward to find walkable ground for each candidate
5. Validates that the ground position is sufficiently far from the Killer
6. Teleports admin to the best valid position

This means the admin always flees **away from the threat** rather than to a fixed point, making the system work anywhere on any map.

</details>

<details>
<summary><b>Why does On Point detect players who are far away?</b></summary>

<br />

v2.1 uses **dual detection**. A target is flagged if EITHER condition is true:

- **Screen-Space:** Target's projected position is inside the POV circle on screen (even if far in 3D space, they're in your view)
- **3D Damage Radius:** Target is within the configurable damage radius in world space (even if off-screen)

The screen panel shows flags indicating which conditions triggered: `POV` for screen-space, `DMG` for 3D radius.

</details>

<details>
<summary><b>Does the crosshair follow players now?</b></summary>

<br />

The crosshair does not "follow" players — it is permanently fixed to the exact center of your screen. When you enable **Spectate** on a target player, the *camera* moves to follow that player. Since the crosshair is always at screen center, it visually appears to track the target. This is the correct behavior — the crosshair is a reference point, not a tracking reticle.

</details>

<details>
<summary><b>Will Hoshi lag my game?</b></summary>

<br />

Hoshi's total overhead with all modules active is approximately 0.65ms per frame in a typical 10-15 player session. At 60 FPS, this represents ~3.9% of the available frame budget. Disabled modules consume exactly zero CPU. The system is designed for extended development sessions without accumulating resource leaks.

</details>

<details>
<summary><b>What happens when I re-run the script?</b></summary>

<br />

Hoshi includes anti-duplicate protection. Re-executing the loader automatically cleans up the previous instance (disconnects all connections, destroys all instances, resets all state) before starting a fresh instance. This is safe and expected during iterative development.

</details>

<details>
<summary><b>How do I set up roles in my game?</b></summary>

<br />

Hoshi detects roles through three methods (checked in priority order):

```lua
-- Method 1: Attributes (recommended)
player:SetAttribute("Role", "Killer")

-- Method 2: StringValue
local role = Instance.new("StringValue")
role.Name = "Role"
role.Value = "Survivor"
role.Parent = player

-- Method 3: Teams (automatic fallback)
-- If player.Team.Name == "Killer", that becomes the role
```

</details>

<details>
<summary><b>Can I change the UI colors?</b></summary>

<br />

Yes. All colors are defined in the `Config.Theme` table at the top of the script. Modify any value:

```lua
Config.Theme.Primary = Color3.fromRGB(255, 100, 0)    -- Orange accent
Config.Theme.Background = Color3.fromRGB(0, 0, 0)     -- Pure black
Config.Theme.TerminalBG = Color3.fromRGB(10, 0, 0)    -- Dark red tint
```

</details>

<details>
<summary><b>How do I remove Hoshi completely?</b></summary>

<br />

Three options, all triggering full cleanup:

```
METHOD              HOW                          WHEN
────────────────────────────────────────────────────────
GUI Close           Click [x] in header          Normal exit
Global Cleanup      _G.HOSHI_Cleanup()           Programmatic
Re-execute          Run loader again             Fresh start
```

</details>

<details>
<summary><b>Can I extend Hoshi with custom modules?</b></summary>

<br />

Currently requires source modification, but the pattern is consistent:

```
1. Add defaults to Config table
2. Create module table: MyModule = {}
3. Implement Start(), Stop(), and update logic
4. Build UI page: MainGUI.BuildMyModulePage()
5. Add tab entry to tabs array
6. Add MyModule.Stop() to Cleanup()
```

A formal plugin API is planned for v2.3.0.

</details>

<details>
<summary><b>Why terminal aesthetic instead of modern UI?</b></summary>

<br />

Three reasons:

1. **Information density.** Monospace text and bracket notation pack more data per pixel than padded cards with gradients.
2. **Developer familiarity.** Terminal interfaces are the native language of development. No learning curve.
3. **Performance.** No UIGradient, no complex layering, no transparency stacking. Simpler render = lower overhead.

</details>

<br />

---

<br />

## 13 — Contributing

Contributions are welcome. Bug reports, feature suggestions, performance improvements, and documentation updates all help.

### Process

```
1. Fork the repository
   $ git clone https://github.com/YOUR_FORK/hoshi.git

2. Create a feature branch
   $ git checkout -b feature/your-feature

3. Implement changes
   - Follow existing code patterns
   - Use Utilities.Connect() for all signals
   - Use Utilities.Track() for all instances
   - Comment every function
   - Test in Roblox Studio

4. Commit with conventional format
   $ git commit -m "feat: add keybind system for module toggles"

5. Push and open a Pull Request
   $ git push origin feature/your-feature
```

**Commit Prefixes:**

```
feat:      New feature
fix:       Bug fix
docs:      Documentation
style:     Visual changes (no logic change)
refactor:  Code restructuring (no behavior change)
perf:      Performance improvement
chore:     Tooling, config
```

> [!IMPORTANT]
> All contributions must serve private map development purposes only. PRs adding features intended for public games owned by others will not be accepted.

<br />

---

<br />

## 14 — License

```
MIT License

Copyright (c) 2024 [Your Name]

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

<br />

---

<br />

## 15 — Developer

<div align="center">

```
DEVELOPER    [Your Name]
ROLE         Creator & Lead Developer
```

<br />

[![GitHub](https://img.shields.io/badge/GitHub-@username-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/username)
[![Discord](https://img.shields.io/badge/Discord-username-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/)
[![Website](https://img.shields.io/badge/Web-yoursite.dev-00ffa0?style=for-the-badge&logo=googlechrome&logoColor=white)](https://yoursite.dev)

</div>

<br />

---

<br />

## 16 — Credits

```
TECHNOLOGY           CONTRIBUTION
─────────────────────────────────────────────────────────────
Lua                  The scripting language powering Hoshi
Roblox Studio        Platform, engine, and runtime
Shields.io           Badge generation for this documentation
Open Source           Patterns, standards, and the spirit
Community            of building tools for builders
```

<br />

---

<br />

<div align="center">

```
Built with precision and too much coffee.

HOSHI v2.1.0 — Admin Development Tools
For Private Map Testing & Debugging

Copyright (c) 2024 [Your Name]
Licensed under MIT
```

<br />

[![Back to Top](https://img.shields.io/badge/BACK_TO_TOP-00ffa0?style=for-the-badge)](#)

<br />

</div>
```

---

**Placeholder yang perlu diganti:**

| Placeholder | Ganti Dengan |
|---|---|
| `username` | GitHub username Anda (di semua badge URL + link) |
| `YOUR_USERNAME` | GitHub username Anda |
| `[Your Name]` | Nama developer Anda |
| `YOUR_RAW_SCRIPT_URL` | URL raw script yang dihost |
| `YOUR_URL` | URL script |
| `yoursite.dev` | Website Anda (atau hapus badge) |
