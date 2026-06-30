#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║  ██╗  ██╗ ██████╗ ███████╗██╗  ██╗██╗    ██╗   ██╗██████╗             ║
║  ██║  ██║██╔═══██╗██╔════╝██║  ██║██║    ██║   ██║╚════██╗            ║
║  ███████║██║   ██║███████╗███████║██║    ██║   ██║ █████╔╝            ║
║  ██╔══██║██║   ██║╚════██║██╔══██║██║    ╚██╗ ██╔╝██╔═══╝             ║
║  ██║  ██║╚██████╔╝███████║██║  ██║██║     ╚████╔╝ ███████╗            ║
║  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝      ╚═══╝  ╚══════╝            ║
║                                                                          ║
║  ⚡ CYBER SHELL INSTALLER v3.0 ⚡                                       ║
║  RGB Hacker Terminal Experience for Termux                               ║
║  Python 3.10+ │ Bash │ Zsh │ Android / Termux                           ║
╚══════════════════════════════════════════════════════════════════════════╝
"""

from __future__ import annotations

import datetime
import json
import math
import os
import platform
import random
import shutil
import signal
import subprocess
import sys
import textwrap
import time
from dataclasses import dataclass, asdict
from enum import Enum
from pathlib import Path
from typing import Any, Optional

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PRE-FLIGHT: Ensure 'rich' is available
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _ensure_rich() -> None:
    try:
        import rich  # noqa: F401
    except ImportError:
        print("\033[38;2;0;255;136m[*] Installing rich library...\033[0m")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "rich"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )

_ensure_rich()

from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    BarColumn, Progress, SpinnerColumn,
    TaskProgressColumn, TextColumn, TimeElapsedColumn,
)
from rich.prompt import Confirm, Prompt
from rich.rule import Rule
from rich.status import Status
from rich.table import Table
from rich.text import Text
from rich.theme import Theme
from rich.live import Live
from rich.columns import Columns


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RGB COLOR ENGINE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RGBEngine:
    """Generates RGB / gradient / rainbow color sequences."""

    # Core palette
    NEON_GREEN   = (0, 255, 136)
    NEON_CYAN    = (0, 255, 255)
    NEON_BLUE    = (0, 128, 255)
    NEON_PURPLE  = (163, 55, 253)
    NEON_MAGENTA = (255, 0, 255)
    NEON_PINK    = (255, 0, 128)
    NEON_RED     = (255, 55, 55)
    NEON_ORANGE  = (255, 165, 0)
    NEON_YELLOW  = (255, 255, 0)
    ELECTRIC     = (0, 255, 200)
    MATRIX       = (0, 255, 65)
    GHOST        = (180, 200, 255)
    CYBER_WHITE  = (220, 240, 255)
    DARK_BG      = (10, 10, 20)

    GRADIENT_PRESETS = {
        "cyber":    [(0,255,136), (0,255,255), (0,128,255), (163,55,253)],
        "fire":     [(255,55,55), (255,165,0), (255,255,0), (255,165,0)],
        "matrix":   [(0,80,0), (0,180,0), (0,255,65), (0,255,136)],
        "aurora":   [(0,255,136), (0,255,255), (163,55,253), (255,0,255)],
        "sunset":   [(255,0,128), (255,55,55), (255,165,0), (255,255,0)],
        "ice":      [(0,128,255), (0,200,255), (0,255,255), (180,200,255)],
        "toxic":    [(0,255,0), (128,255,0), (255,255,0), (0,255,128)],
        "plasma":   [(255,0,255), (163,55,253), (0,128,255), (0,255,255)],
        "blood":    [(120,0,0), (200,0,0), (255,55,55), (255,0,128)],
        "ocean":    [(0,50,100), (0,128,255), (0,200,255), (0,255,200)],
    }

    @staticmethod
    def rgb(r: int, g: int, b: int, text: str) -> str:
        return f"\033[38;2;{r};{g};{b}m{text}\033[0m"

    @staticmethod
    def rgb_bg(r: int, g: int, b: int, text: str) -> str:
        return f"\033[48;2;{r};{g};{b}m{text}\033[0m"

    @classmethod
    def gradient_text(cls, text: str, colors: list[tuple[int,int,int]]) -> str:
        if not text or not colors:
            return text
        result = []
        n = len(text)
        segments = len(colors) - 1
        for i, ch in enumerate(text):
            if ch in (' ', '\n', '\t'):
                result.append(ch)
                continue
            pos = (i / max(n - 1, 1)) * segments
            idx = min(int(pos), segments - 1)
            frac = pos - idx
            c1, c2 = colors[idx], colors[min(idx + 1, len(colors) - 1)]
            r = int(c1[0] + (c2[0] - c1[0]) * frac)
            g = int(c1[1] + (c2[1] - c1[1]) * frac)
            b = int(c1[2] + (c2[2] - c1[2]) * frac)
            result.append(f"\033[38;2;{r};{g};{b}m{ch}")
        result.append("\033[0m")
        return "".join(result)

    @classmethod
    def rainbow_text(cls, text: str, offset: int = 0) -> str:
        result = []
        for i, ch in enumerate(text):
            if ch in (' ', '\n', '\t'):
                result.append(ch)
                continue
            hue = ((i + offset) * 8) % 360
            r, g, b = cls._hsl_to_rgb(hue / 360.0, 1.0, 0.55)
            result.append(f"\033[38;2;{r};{g};{b}m{ch}")
        result.append("\033[0m")
        return "".join(result)

    @classmethod
    def gradient_line(cls, text: str, preset: str = "cyber") -> str:
        colors = cls.GRADIENT_PRESETS.get(preset, cls.GRADIENT_PRESETS["cyber"])
        return cls.gradient_text(text, colors)

    @classmethod
    def gradient_multiline(cls, text: str, preset: str = "cyber") -> str:
        lines = text.split('\n')
        colors = cls.GRADIENT_PRESETS.get(preset, cls.GRADIENT_PRESETS["cyber"])
        result = []
        total = max(sum(len(l) for l in lines), 1)
        offset = 0
        for line in lines:
            result.append(cls.gradient_text(line, colors))
            offset += len(line)
        return "\n".join(result)

    @classmethod
    def pulse_color(cls, base: tuple[int,int,int], t: float) -> tuple[int,int,int]:
        factor = 0.5 + 0.5 * math.sin(t * 3.0)
        return (
            int(base[0] * factor),
            int(base[1] * factor),
            int(base[2] * factor),
        )

    @staticmethod
    def _hsl_to_rgb(h: float, s: float, l: float) -> tuple[int,int,int]:
        if s == 0:
            v = int(l * 255)
            return (v, v, v)
        def hue2rgb(p, q, t):
            if t < 0: t += 1
            if t > 1: t -= 1
            if t < 1/6: return p + (q - p) * 6 * t
            if t < 1/2: return q
            if t < 2/3: return p + (q - p) * (2/3 - t) * 6
            return p
        q = l * (1 + s) if l < 0.5 else l + s - l * s
        p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
        return (int(r * 255), int(g * 255), int(b * 255))


RGB = RGBEngine


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CONSTANTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VERSION: str = "3.0.0"
APP_NAME: str = "HOSHI"

HOME: Path = Path.home()
HOSHI_DIR: Path = HOME / ".hoshi"
CACHE_DIR: Path = HOSHI_DIR / "cache"
LOGS_DIR: Path  = HOSHI_DIR / "logs"
BACKUP_DIR: Path = HOSHI_DIR / "backups"
THEMES_DIR: Path = HOSHI_DIR / "themes"

CONFIG_FILE: Path      = HOSHI_DIR / "config.json"
THEME_FILE: Path       = HOSHI_DIR / "theme.json"
COLORS_FILE: Path      = HOSHI_DIR / "colors.json"
PROMPT_SH: Path        = HOSHI_DIR / "prompt.sh"
ALIASES_SH: Path       = HOSHI_DIR / "aliases.sh"
STARTUP_SH: Path       = HOSHI_DIR / "startup.sh"
FUNCTIONS_SH: Path     = HOSHI_DIR / "functions.sh"
ENVIRONMENT_SH: Path   = HOSHI_DIR / "environment.sh"
DASHBOARD_PY: Path     = HOSHI_DIR / "dashboard.py"
LOGO_TXT: Path         = HOSHI_DIR / "logo.txt"

SHELL_FILES: list[str] = [".bashrc", ".zshrc", ".profile", ".bash_profile", ".bash_login"]

DEPENDENCIES: list[dict[str,str]] = [
    {"name": "git",  "pkg": "git"},
    {"name": "curl", "pkg": "curl"},
    {"name": "wget", "pkg": "wget"},
    {"name": "zsh",  "pkg": "zsh"},
    {"name": "fzf",  "pkg": "fzf"},
    {"name": "bat",  "pkg": "bat"},
    {"name": "eza",  "pkg": "eza"},
    {"name": "rg",   "pkg": "ripgrep"},
    {"name": "fd",   "pkg": "fd"},
]

MARKER_START: str = "# ═══ HOSHI v3 ═══ START ═══"
MARKER_END: str   = "# ═══ HOSHI v3 ═══ END ═══"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RICH THEME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOSHI_THEME = Theme({
    "h.title":    "bold rgb(0,255,136)",
    "h.accent":   "bold rgb(0,255,255)",
    "h.success":  "bold rgb(0,255,136)",
    "h.warning":  "bold rgb(255,165,0)",
    "h.error":    "bold rgb(255,55,55)",
    "h.info":     "bold rgb(0,128,255)",
    "h.debug":    "dim rgb(163,55,253)",
    "h.muted":    "dim rgb(100,120,140)",
    "h.cyber":    "bold rgb(0,255,200)",
    "h.matrix":   "bold rgb(0,255,65)",
    "h.neon":     "bold rgb(255,0,255)",
    "h.fire":     "bold rgb(255,165,0)",
    "h.ice":      "bold rgb(0,200,255)",
    "h.border":   "rgb(0,255,136)",
    "h.menu_num": "bold rgb(0,255,255)",
    "h.menu_item":"rgb(200,220,255)",
    "h.key":      "bold rgb(0,255,200)",
    "h.val":      "rgb(220,240,255)",
})

console = Console(theme=HOSHI_THEME)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ENUMS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class LogLevel(Enum):
    DEBUG   = "debug"
    INFO    = "info"
    SUCCESS = "success"
    WARNING = "warning"
    ERROR   = "error"

class ShellType(Enum):
    BASH = "bash"
    ZSH  = "zsh"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DATA CLASSES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@dataclass
class SystemInfo:
    os_name: str = ""
    os_version: str = ""
    kernel: str = ""
    architecture: str = ""
    hostname: str = ""
    username: str = ""
    shell: str = ""
    shell_type: ShellType = ShellType.BASH
    python_version: str = ""
    git_version: str = ""
    cpu_info: str = ""
    ram_total: str = ""
    ram_used: str = ""
    ram_percent: str = ""
    storage_total: str = ""
    storage_used: str = ""
    storage_percent: str = ""
    battery_level: str = ""
    battery_status: str = ""
    internet: bool = False
    is_termux: bool = False
    is_android: bool = False
    current_dir: str = ""
    package_manager: str = ""

@dataclass
class ThemeConfig:
    name: str = "cyber"
    gradient: str = "cyber"
    prompt_style: str = "rgb"
    primary: tuple = (0, 255, 136)
    secondary: tuple = (0, 255, 255)
    accent: tuple = (163, 55, 253)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  UTILITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Utility:
    @staticmethod
    def run_cmd(cmd: str, timeout: int = 30) -> tuple[int, str, str]:
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
            return r.returncode, r.stdout.strip(), r.stderr.strip()
        except subprocess.TimeoutExpired:
            return -1, "", "timeout"
        except Exception as e:
            return -1, "", str(e)

    @staticmethod
    def cmd_exists(cmd: str) -> bool:
        return shutil.which(cmd) is not None

    @staticmethod
    def read_file(p: Path) -> str:
        try: return p.read_text("utf-8")
        except: return ""

    @staticmethod
    def write_file(p: Path, content: str) -> bool:
        try:
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(content, "utf-8")
            return True
        except: return False

    @staticmethod
    def make_exec(p: Path) -> bool:
        try: p.chmod(0o755); return True
        except: return False

    @staticmethod
    def ts() -> str:
        return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

    @staticmethod
    def human(n: float) -> str:
        for u in ("B","KB","MB","GB","TB"):
            if abs(n) < 1024: return f"{n:.1f} {u}"
            n /= 1024
        return f"{n:.1f} PB"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ERROR HANDLER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ErrorHandler:
    @staticmethod
    def handle(e: Exception, ctx: str = "", fatal: bool = False) -> None:
        msg = f"{ctx}: {e}" if ctx else str(e)
        console.print(f"  [h.error]✗ {msg}[/]")
        try:
            LOGS_DIR.mkdir(parents=True, exist_ok=True)
            with open(LOGS_DIR / "error.log", "a") as f:
                f.write(f"[{Utility.ts()}] {msg}\n")
        except: pass
        if fatal: sys.exit(1)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LOGGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Logger:
    _MAP = {
        LogLevel.DEBUG:   ("h.debug",   "⚙"),
        LogLevel.INFO:    ("h.info",    "◆"),
        LogLevel.SUCCESS: ("h.success", "✓"),
        LogLevel.WARNING: ("h.warning", "⚠"),
        LogLevel.ERROR:   ("h.error",   "✗"),
    }

    def __init__(self) -> None:
        LOGS_DIR.mkdir(parents=True, exist_ok=True)
        self._f = LOGS_DIR / "installer.log"

    def _log(self, lv: LogLevel, msg: str) -> None:
        st, ic = self._MAP[lv]
        console.print(f"  [{st}]{ic}[/] [{st}]{msg}[/]")
        try:
            with open(self._f, "a") as f:
                f.write(f"[{Utility.ts()}][{lv.value}] {msg}\n")
        except: pass

    def debug(self, m: str)   -> None: self._log(LogLevel.DEBUG, m)
    def info(self, m: str)    -> None: self._log(LogLevel.INFO, m)
    def success(self, m: str) -> None: self._log(LogLevel.SUCCESS, m)
    def warning(self, m: str) -> None: self._log(LogLevel.WARNING, m)
    def error(self, m: str)   -> None: self._log(LogLevel.ERROR, m)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ANIMATION MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AnimationManager:
    def __init__(self) -> None:
        self.enabled = True

    def hacker_typing(self, text: str, speed: float = 0.015) -> None:
        if not self.enabled:
            print(text); return
        for ch in text:
            sys.stdout.write(ch)
            sys.stdout.flush()
            time.sleep(speed)
        print()

    def matrix_rain(self, duration: float = 1.5, width: int = 60) -> None:
        if not self.enabled: return
        chars = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ01"
        end_t = time.time() + duration
        while time.time() < end_t:
            line = ""
            for _ in range(width):
                if random.random() < 0.15:
                    c = random.choice(chars)
                    g = random.randint(80, 255)
                    line += f"\033[38;2;0;{g};0m{c}\033[0m"
                else:
                    line += " "
            print(f"  {line}")
            time.sleep(0.04)

    def cyber_loading(self, text: str, duration: float = 1.5) -> None:
        if not self.enabled: return
        frames = ["⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"]
        end_t = time.time() + duration
        i = 0
        while time.time() < end_t:
            hue = (i * 15) % 360
            r, g, b = RGB._hsl_to_rgb(hue/360, 1.0, 0.55)
            frame = frames[i % len(frames)]
            sys.stdout.write(f"\r  \033[38;2;{r};{g};{b}m{frame} {text}\033[0m  ")
            sys.stdout.flush()
            time.sleep(0.08)
            i += 1
        print()

    def rgb_progress_bar(self, label: str, steps: int = 30, duration: float = 1.5) -> None:
        if not self.enabled: return
        delay = duration / steps
        for i in range(steps + 1):
            pct = i / steps
            filled = int(pct * 30)
            bar = ""
            for j in range(30):
                if j < filled:
                    hue = (j * 12) % 360
                    r, g, b = RGB._hsl_to_rgb(hue/360, 1.0, 0.55)
                    bar += f"\033[38;2;{r};{g};{b}m█\033[0m"
                else:
                    bar += "\033[38;2;40;40;50m░\033[0m"
            sys.stdout.write(f"\r  {RGB.gradient_text(label, RGB.GRADIENT_PRESETS['cyber'])} {bar} \033[38;2;0;255;136m{pct*100:.0f}%\033[0m  ")
            sys.stdout.flush()
            time.sleep(delay)
        print()

    def glitch_text(self, text: str, iterations: int = 8) -> None:
        if not self.enabled:
            print(text); return
        glitch_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?/~`█▓▒░"
        for _ in range(iterations):
            out = ""
            for ch in text:
                if random.random() < 0.3:
                    gc = random.choice(glitch_chars)
                    r, g, b = random.randint(0,255), random.randint(0,255), random.randint(0,255)
                    out += f"\033[38;2;{r};{g};{b}m{gc}\033[0m"
                else:
                    out += ch
            sys.stdout.write(f"\r  {out}  ")
            sys.stdout.flush()
            time.sleep(0.05)
        final = RGB.gradient_text(text, RGB.GRADIENT_PRESETS["cyber"])
        sys.stdout.write(f"\r  {final}  ")
        print()

    def spinner(self, msg: str) -> Status:
        return console.status(f"  [h.cyber]{msg}[/]", spinner="dots")

    def progress(self) -> Progress:
        return Progress(
            SpinnerColumn(spinner_name="dots", style="rgb(0,255,136)"),
            TextColumn("[h.cyber]{task.description}"),
            BarColumn(bar_width=30, style="rgb(40,40,50)",
                      complete_style="rgb(0,255,136)",
                      finished_style="rgb(0,255,200)"),
            TaskProgressColumn(style="rgb(0,255,255)"),
            TimeElapsedColumn(),
            console=console,
        )

    def pause(self, s: float = 0.3) -> None:
        if self.enabled: time.sleep(s)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CONFIG MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ConfigManager:
    def __init__(self) -> None:
        self._c: dict[str, Any] = {}

    def load(self) -> dict[str, Any]:
        if CONFIG_FILE.exists():
            try: self._c = json.loads(CONFIG_FILE.read_text("utf-8"))
            except: self._c = self._defaults()
        else: self._c = self._defaults()
        return self._c

    def save(self, c: Optional[dict] = None) -> bool:
        if c: self._c = c
        return Utility.write_file(CONFIG_FILE, json.dumps(self._c, indent=2))

    def get(self, k: str, d: Any = None) -> Any: return self._c.get(k, d)
    def set(self, k: str, v: Any) -> None: self._c[k] = v; self.save()

    def save_theme(self, t: ThemeConfig) -> bool:
        d = {"name": t.name, "gradient": t.gradient, "prompt_style": t.prompt_style,
             "primary": list(t.primary), "secondary": list(t.secondary), "accent": list(t.accent)}
        return Utility.write_file(THEME_FILE, json.dumps(d, indent=2))

    def create_colors(self) -> bool:
        return Utility.write_file(COLORS_FILE, json.dumps({
            "neon_green":"#00FF88","neon_cyan":"#00FFFF","neon_blue":"#0080FF",
            "neon_purple":"#A337FD","neon_magenta":"#FF00FF","neon_pink":"#FF0080",
            "matrix":"#00FF41","electric":"#00FFC8","ghost":"#B4C8FF",
        }, indent=2))

    def _defaults(self) -> dict:
        return {"version": VERSION, "installed_at": Utility.ts(), "theme": "cyber",
                "gradient": "cyber", "show_dashboard": True, "show_banner": True,
                "animation": True, "show_time": False, "matrix_rain": True,
                "glitch_effect": True, "rgb_prompt": True}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SYSTEM DETECTOR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SystemDetector:
    def __init__(self) -> None:
        self.info = SystemInfo()

    def detect_all(self) -> SystemInfo:
        i = self.info
        i.os_name = platform.system()
        rc, o, _ = Utility.run_cmd("getprop ro.build.version.release", 5)
        if rc == 0 and o: i.os_version = f"Android {o}"; i.is_android = True
        else: i.os_version = platform.version()
        i.is_termux = "com.termux" in os.environ.get("PREFIX","")
        i.kernel = platform.release()
        i.architecture = platform.machine()
        rc, o, _ = Utility.run_cmd("hostname", 5)
        i.hostname = o if rc == 0 and o else "localhost"
        i.username = os.environ.get("USER", "user")
        shell = os.environ.get("SHELL", "")
        i.shell = shell
        i.shell_type = ShellType.ZSH if "zsh" in shell else ShellType.BASH
        i.python_version = platform.python_version()
        rc, o, _ = Utility.run_cmd("git --version", 5)
        i.git_version = o.replace("git version ", "") if rc == 0 else "N/A"
        rc, o, _ = Utility.run_cmd("cat /proc/cpuinfo | grep Hardware | head -1 | cut -d: -f2", 5)
        i.cpu_info = o.strip() if rc == 0 and o else platform.processor() or "N/A"
        # RAM
        rc, o, _ = Utility.run_cmd("cat /proc/meminfo", 5)
        if rc == 0 and o:
            mt = ma = 0
            for l in o.splitlines():
                if l.startswith("MemTotal:"): mt = int(l.split()[1]) * 1024
                elif l.startswith("MemAvailable:"): ma = int(l.split()[1]) * 1024
            mu = mt - ma
            i.ram_total = Utility.human(mt); i.ram_used = Utility.human(mu)
            i.ram_percent = f"{mu/mt*100:.0f}%" if mt else "N/A"
        else: i.ram_total = i.ram_used = i.ram_percent = "N/A"
        # Storage
        try:
            st = os.statvfs(str(HOME))
            t = st.f_blocks * st.f_frsize; f = st.f_bavail * st.f_frsize; u = t - f
            i.storage_total = Utility.human(t); i.storage_used = Utility.human(u)
            i.storage_percent = f"{u/t*100:.0f}%" if t else "N/A"
        except: i.storage_total = i.storage_used = i.storage_percent = "N/A"
        # Battery
        rc, o, _ = Utility.run_cmd("cat /sys/class/power_supply/battery/capacity 2>/dev/null", 5)
        if rc == 0 and o:
            i.battery_level = f"{o}%"
            _, s, _ = Utility.run_cmd("cat /sys/class/power_supply/battery/status 2>/dev/null", 5)
            i.battery_status = s or "N/A"
        else:
            rc2, o2, _ = Utility.run_cmd("termux-battery-status 2>/dev/null", 8)
            if rc2 == 0 and o2:
                try:
                    d = json.loads(o2)
                    i.battery_level = f"{d.get('percentage','?')}%"
                    i.battery_status = d.get("status","N/A")
                except: i.battery_level = i.battery_status = "N/A"
            else: i.battery_level = i.battery_status = "N/A"
        rc, _, _ = Utility.run_cmd("ping -c1 -W2 8.8.8.8", 6)
        i.internet = rc == 0
        i.current_dir = os.getcwd()
        i.package_manager = "pkg" if Utility.cmd_exists("pkg") else "apt" if Utility.cmd_exists("apt") else "?"
        return i


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DEPENDENCY MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DependencyManager:
    def __init__(self, log: Logger, anim: AnimationManager) -> None:
        self._log = log; self._anim = anim
        self._pkg = "pkg" if Utility.cmd_exists("pkg") else "apt"

    def check_all(self) -> list[dict]:
        return [{**d, "installed": Utility.cmd_exists(d["name"])} for d in DEPENDENCIES]

    def install_missing(self, deps: list[dict]) -> None:
        miss = [d for d in deps if not d["installed"]]
        if not miss:
            self._log.success("All dependencies ready"); return
        self._log.info(f"Installing {len(miss)} package(s)...")
        with self._anim.spinner("Updating repos..."):
            Utility.run_cmd(f"{self._pkg} update -y", 120)
        with self._anim.progress() as p:
            t = p.add_task("Installing", total=len(miss))
            for d in miss:
                p.update(t, description=f"Installing {d['pkg']}...")
                rc, _, _ = Utility.run_cmd(f"{self._pkg} install -y {d['pkg']}", 120)
                if rc == 0: self._log.success(d['pkg'])
                else: self._log.warning(f"{d['pkg']} failed")
                p.advance(t); self._anim.pause(0.15)

    def install_starship(self) -> bool:
        if Utility.cmd_exists("starship"):
            self._log.success("Starship ready"); return True
        rc, _, _ = Utility.run_cmd(f"{self._pkg} install -y starship", 120)
        if rc == 0: self._log.success("Starship installed"); return True
        self._log.warning("Starship unavailable — RGB prompt active"); return False


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  BACKUP MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class BackupManager:
    def __init__(self, log: Logger) -> None:
        self._log = log; BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    def create(self) -> Optional[Path]:
        ts = Utility.ts(); dest = BACKUP_DIR / ts
        dest.mkdir(parents=True, exist_ok=True)
        files = []
        for f in SHELL_FILES:
            s = HOME / f
            if s.exists(): shutil.copy2(s, dest / f); files.append(f)
        Utility.write_file(dest / "manifest.json",
                          json.dumps({"ts": ts, "files": files}, indent=2))
        self._log.success(f"Backup → {ts}")
        return dest

    def list_all(self) -> list[Path]:
        if not BACKUP_DIR.exists(): return []
        return sorted([d for d in BACKUP_DIR.iterdir() if d.is_dir()],
                      key=lambda p: p.name, reverse=True)

    def latest(self) -> Optional[Path]:
        b = self.list_all()
        return b[0] if b else None


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RESTORE MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class RestoreManager:
    def __init__(self, log: Logger, bak: BackupManager) -> None:
        self._log = log; self._bak = bak

    def restore_latest(self) -> bool:
        l = self._bak.latest()
        if not l: self._log.error("No backups"); return False
        return self._do(l)

    def restore_from(self, p: Path) -> bool: return self._do(p)

    def _do(self, bp: Path) -> bool:
        mf = bp / "manifest.json"
        if not mf.exists(): self._log.error("No manifest"); return False
        try: m = json.loads(mf.read_text("utf-8"))
        except: self._log.error("Bad manifest"); return False
        for f in m.get("files", []):
            s, d = bp / f, HOME / f
            if s.exists(): shutil.copy2(s, d); self._log.success(f"Restored {f}")
        for f in SHELL_FILES:
            fp = HOME / f
            if fp.exists(): self._rm_block(fp)
        return True

    @staticmethod
    def _rm_block(fp: Path) -> None:
        c = Utility.read_file(fp)
        if MARKER_START not in c: return
        new, inside = [], False
        for l in c.splitlines():
            if MARKER_START in l: inside = True; continue
            if MARKER_END in l:   inside = False; continue
            if not inside: new.append(l)
        Utility.write_file(fp, "\n".join(new) + "\n")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  THEME MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ThemeManager:
    THEMES = {
        "cyber":   {"name": "⚡ Cyber",   "desc": "Neon green/cyan — classic hacker",
                    "gradient": "cyber",   "p": (0,255,136), "s": (0,255,255), "a": (163,55,253)},
        "matrix":  {"name": "🟢 Matrix",  "desc": "Green phosphor terminal",
                    "gradient": "matrix",  "p": (0,255,65),  "s": (0,180,0),   "a": (0,255,136)},
        "plasma":  {"name": "🟣 Plasma",  "desc": "Purple/blue electric",
                    "gradient": "plasma",  "p": (163,55,253),"s": (0,128,255), "a": (255,0,255)},
        "fire":    {"name": "🔥 Fire",    "desc": "Red/orange/yellow blaze",
                    "gradient": "fire",    "p": (255,55,55), "s": (255,165,0), "a": (255,255,0)},
        "aurora":  {"name": "🌌 Aurora",  "desc": "Northern lights RGB",
                    "gradient": "aurora",  "p": (0,255,136), "s": (0,255,255), "a": (255,0,255)},
        "ice":     {"name": "❄️ Ice",     "desc": "Cool blue frost",
                    "gradient": "ice",     "p": (0,128,255), "s": (0,200,255), "a": (180,200,255)},
        "toxic":   {"name": "☢️ Toxic",   "desc": "Radioactive green/yellow",
                    "gradient": "toxic",   "p": (0,255,0),   "s": (255,255,0), "a": (0,255,128)},
        "blood":   {"name": "🩸 Blood",   "desc": "Deep red darkness",
                    "gradient": "blood",   "p": (255,55,55), "s": (200,0,0),   "a": (255,0,128)},
        "ocean":   {"name": "🌊 Ocean",   "desc": "Deep sea blue/teal",
                    "gradient": "ocean",   "p": (0,128,255), "s": (0,200,255), "a": (0,255,200)},
        "sunset":  {"name": "🌅 Sunset",  "desc": "Pink/orange warm glow",
                    "gradient": "sunset",  "p": (255,0,128), "s": (255,165,0), "a": (255,255,0)},
    }

    def __init__(self, cfg: ConfigManager, log: Logger) -> None:
        self._cfg = cfg; self._log = log

    def get(self, name: str) -> dict: return self.THEMES.get(name, self.THEMES["cyber"])
    def list_all(self) -> dict: return self.THEMES

    def apply(self, name: str) -> bool:
        if name not in self.THEMES: self._log.error(f"No theme: {name}"); return False
        t = self.THEMES[name]
        self._cfg.set("theme", name)
        self._cfg.set("gradient", t["gradient"])
        self._cfg.save_theme(ThemeConfig(name=name, gradient=t["gradient"],
                                         primary=t["p"], secondary=t["s"], accent=t["a"]))
        self._log.success(f"Theme → {t['name']}")
        return True


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PROMPT MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PromptManager:
    def __init__(self, tmgr: ThemeManager, cfg: ConfigManager) -> None:
        self._t = tmgr; self._cfg = cfg

    def write(self, shell: ShellType, theme: str = "cyber") -> bool:
        t = self._t.get(theme)
        p, s, a = t["p"], t["s"], t["a"]

        git_fn = r'''
__hoshi_git() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local br fl=""
    br=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [ -n "$(git status --porcelain=v1 2>/dev/null)" ] && fl=" ●"
    local ah bh
    ah=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
    bh=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
    [ "${ah:-0}" -gt 0 ] 2>/dev/null && fl="${fl}↑${ah}"
    [ "${bh:-0}" -gt 0 ] 2>/dev/null && fl="${fl}↓${bh}"
    git stash list 2>/dev/null | grep -q . && fl="${fl}≡"
    [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ] 2>/dev/null && fl="${fl}⚡"
    printf " \001\033[38;2;''' + f"{a[0]};{a[1]};{a[2]}" + r'''m\002 %s%s\001\033[0m\002" "$br" "$fl"
}'''

        venv_fn = r'''
__hoshi_venv() {
    [ -n "$VIRTUAL_ENV" ] && printf " \001\033[38;2;163;55;253m\002(%s)\001\033[0m\002" "$(basename "$VIRTUAL_ENV")"
}'''

        # RGB cycling prompt function
        rgb_prompt_fn = f'''
__hoshi_rgb_symbol() {{
    local t=$(date +%s)
    local phase=$(( t % 6 ))
    case $phase in
        0) printf "\\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002" ;;
        1) printf "\\001\\033[38;2;{s[0]};{s[1]};{s[2]}m\\002" ;;
        2) printf "\\001\\033[38;2;{a[0]};{a[1]};{a[2]}m\\002" ;;
        3) printf "\\001\\033[38;2;{s[0]};{s[1]};{s[2]}m\\002" ;;
        4) printf "\\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002" ;;
        5) printf "\\001\\033[38;2;{a[0]};{a[1]};{a[2]}m\\002" ;;
    esac
}}'''

        show_time = self._cfg.get("show_time", False)
        time_seg = r' \001\033[38;2;100;100;120m\002\t\001\033[0m\002' if show_time else ""

        if shell == ShellType.ZSH:
            body = f"""
setopt PROMPT_SUBST
{git_fn}
{venv_fn}
{rgb_prompt_fn}

__hoshi_p() {{
    local lx=$?
    local sc="\\033[38;2;{p[0]};{p[1]};{p[2]}m"
    [ $lx -ne 0 ] && sc="\\033[38;2;255;55;55m"
    local ri=""
    [ "$(id -u)" -eq 0 ] && ri=" \\033[38;2;255;55;55m⚡\\033[0m"
    echo -e "\\033[38;2;{p[0]};{p[1]};{p[2]}m╭─\\033[0m \\033[38;2;{s[0]};{s[1]};{s[2]}m%n\\033[0m\\033[38;2;100;100;120m@\\033[0m\\033[38;2;{a[0]};{a[1]};{a[2]}m%m\\033[0m \\033[38;2;{p[0]};{p[1]};{p[2]}m${{PWD/#$HOME/~}}\\033[0m$(__hoshi_git)$(__hoshi_venv)${{ri}}{time_seg}"
    echo -ne "\\033[38;2;{p[0]};{p[1]};{p[2]}m╰─\\033[0m${{sc}}❯\\033[0m "
}}
PROMPT='$(__hoshi_p)'
RPROMPT=''
"""
        else:
            body = f"""
{git_fn}
{venv_fn}
{rgb_prompt_fn}

__hoshi_prompt_cmd() {{
    local lx=$?
    local sc="\\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002"
    [ $lx -ne 0 ] && sc="\\001\\033[38;2;255;55;55m\\002"
    local ri=""
    [ "$(id -u)" -eq 0 ] && ri=" \\001\\033[38;2;255;55;55m\\002⚡\\001\\033[0m\\002"
    PS1="\\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002╭─\\001\\033[0m\\002 \\001\\033[38;2;{s[0]};{s[1]};{s[2]}m\\002\\u\\001\\033[0m\\002\\001\\033[38;2;100;100;120m\\002@\\001\\033[0m\\002\\001\\033[38;2;{a[0]};{a[1]};{a[2]}m\\002\\h\\001\\033[0m\\002 \\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002\\w\\001\\033[0m\\002$(__hoshi_git)$(__hoshi_venv)${{ri}}{time_seg}\\n\\001\\033[38;2;{p[0]};{p[1]};{p[2]}m\\002╰─\\001\\033[0m\\002${{sc}}❯\\001\\033[0m\\002 "
}}
PROMPT_COMMAND="__hoshi_prompt_cmd"
"""
        return Utility.write_file(PROMPT_SH, body.strip() + "\n")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ALIAS MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AliasManager:
    ALIASES = {
        "ll": "eza -la --icons --group-directories-first 2>/dev/null || ls -la --color=auto",
        "la": "eza -a --icons --group-directories-first 2>/dev/null || ls -a --color=auto",
        "lt": "eza -la --tree --level=2 --icons 2>/dev/null || find . -maxdepth 2",
        "l":  "eza -l --icons --group-directories-first 2>/dev/null || ls -l --color=auto",
        "cls": "clear",
        "reload": 'exec "$SHELL"',
        "update": "pkg update -y && pkg upgrade -y",
        "upgrade": "pkg upgrade -y",
        "clean": "pkg clean && apt autoremove -y 2>/dev/null",
        "path": 'echo "$PATH" | tr ":" "\\n"',
        "gs": "git status", "gc": "git commit", "gp": "git push",
        "gl": "git log --oneline --graph --decorate -15",
        "ga": "git add", "gd": "git diff", "gb": "git branch",
        "gco": "git checkout", "gpl": "git pull", "gcl": "git clone",
        "py": "python3", "pip": "pip3",
        "pipup": "pip3 install --upgrade pip",
        "venv": "python3 -m venv",
        "activate": "source ./venv/bin/activate 2>/dev/null || source ./.venv/bin/activate 2>/dev/null",
        "mkdirp": "mkdir -p", "h": "history",
        "grep": "grep --color=auto", "df": "df -h", "du": "du -h",
        "ff": "fd --type f 2>/dev/null || find . -type f -name",
        "cat": "bat --style=auto 2>/dev/null || cat",
        "hoshi": f"python3 {Path(__file__).resolve()}",
    }

    def __init__(self, log: Logger) -> None: self._log = log

    def write(self) -> bool:
        lines = ["# ═══ HOSHI RGB Aliases ═══", ""]
        for k, v in self.ALIASES.items(): lines.append(f"alias {k}='{v}'")
        lines += ["", textwrap.dedent(r'''
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;; *.tar.gz) tar xzf "$1" ;;
            *.tar.xz) tar xJf "$1" ;; *.bz2) bunzip2 "$1" ;;
            *.gz) gunzip "$1" ;; *.tar) tar xf "$1" ;;
            *.zip) unzip "$1" ;; *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else echo "'$1' is not valid"; fi
}''').strip(), ""]
        return Utility.write_file(ALIASES_SH, "\n".join(lines))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DASHBOARD MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DashboardManager:
    def write(self) -> bool:
        code = textwrap.dedent(r'''
#!/usr/bin/env python3
"""HOSHI RGB Dashboard"""
import datetime,json,math,os,platform,random,subprocess,sys,time
from pathlib import Path

def _r(c,t=5):
    try:
        r=subprocess.run(c,shell=True,capture_output=True,text=True,timeout=t)
        return r.returncode,r.stdout.strip()
    except: return -1,""

def _h(n):
    for u in ("B","KB","MB","GB","TB"):
        if abs(n)<1024: return f"{n:.1f} {u}"
        n/=1024
    return f"{n:.1f} PB"

def hsl(h,s,l):
    if s==0: v=int(l*255); return(v,v,v)
    def f(p,q,t):
        if t<0:t+=1
        if t>1:t-=1
        if t<1/6:return p+(q-p)*6*t
        if t<1/2:return q
        if t<2/3:return p+(q-p)*(2/3-t)*6
        return p
    q=l*(1+s) if l<0.5 else l+s-l*s; p=2*l-q
    return(int(f(p,q,h+1/3)*255),int(f(p,q,h)*255),int(f(p,q,h-1/3)*255))

def rgb(r,g,b,t): return f"\033[38;2;{r};{g};{b}m{t}\033[0m"

def grad(text,colors):
    if not text: return text
    res=[]; n=len(text); seg=len(colors)-1
    for i,ch in enumerate(text):
        if ch in ' \n\t': res.append(ch); continue
        pos=(i/max(n-1,1))*seg; idx=min(int(pos),seg-1); fr=pos-idx
        c1,c2=colors[idx],colors[min(idx+1,len(colors)-1)]
        r=int(c1[0]+(c2[0]-c1[0])*fr); g=int(c1[1]+(c2[1]-c1[1])*fr); b=int(c1[2]+(c2[2]-c1[2])*fr)
        res.append(f"\033[38;2;{r};{g};{b}m{ch}")
    res.append("\033[0m"); return "".join(res)

def main():
    # Load theme
    grads = {
        "cyber":[(0,255,136),(0,255,255),(0,128,255),(163,55,253)],
        "matrix":[(0,80,0),(0,180,0),(0,255,65),(0,255,136)],
        "plasma":[(255,0,255),(163,55,253),(0,128,255),(0,255,255)],
        "fire":[(255,55,55),(255,165,0),(255,255,0),(255,165,0)],
        "aurora":[(0,255,136),(0,255,255),(163,55,253),(255,0,255)],
        "ice":[(0,128,255),(0,200,255),(0,255,255),(180,200,255)],
        "toxic":[(0,255,0),(128,255,0),(255,255,0),(0,255,128)],
        "blood":[(120,0,0),(200,0,0),(255,55,55),(255,0,128)],
        "ocean":[(0,50,100),(0,128,255),(0,200,255),(0,255,200)],
        "sunset":[(255,0,128),(255,55,55),(255,165,0),(255,255,0)],
    }
    gname = "cyber"
    try:
        tf = Path.home()/".hoshi"/"config.json"
        if tf.exists(): gname = json.loads(tf.read_text()).get("gradient","cyber")
    except: pass
    gc = grads.get(gname, grads["cyber"])

    # Matrix rain (brief)
    show_matrix = True
    try:
        cf = Path.home()/".hoshi"/"config.json"
        if cf.exists():
            cd = json.loads(cf.read_text())
            show_matrix = cd.get("matrix_rain", True)
    except: pass

    if show_matrix:
        chars = "ｱｲｳｴｵｶｷｸｹｺ01"
        for _ in range(4):
            ln = ""
            for _ in range(50):
                if random.random() < 0.12:
                    c = random.choice(chars)
                    g = random.randint(60, 255)
                    ln += f"\033[38;2;0;{g};0m{c}\033[0m"
                else: ln += " "
            print(f"  {ln}")
            time.sleep(0.03)

    print()

    # Banner
    banner = [
        "  ██╗  ██╗ ██████╗ ███████╗██╗  ██╗██╗",
        "  ██║  ██║██╔═══██╗██╔════╝██║  ██║██║",
        "  ███████║██║   ██║███████╗███████║██║",
        "  ██╔══██║██║   ██║╚════██║██╔══██║██║",
        "  ██║  ██║╚██████╔╝███████║██║  ██║██║",
        "  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝",
    ]
    for line in banner:
        print(grad(line, gc))
    print()

    # Info
    now = datetime.datetime.now()
    user = os.environ.get("USER","user")
    _,host = _r("hostname"); host = host or "localhost"
    _,gv = _r("git --version"); gv = gv.replace("git version ","") or "N/A"
    shell = os.path.basename(os.environ.get("SHELL","bash"))
    _,av = _r("getprop ro.build.version.release")
    osv = f"Android {av}" if av else platform.system()
    _,mi = _r("cat /proc/meminfo")
    ram = "N/A"
    if mi:
        mt=ma=0
        for l in mi.splitlines():
            if l.startswith("MemTotal:"): mt=int(l.split()[1])*1024
            elif l.startswith("MemAvailable:"): ma=int(l.split()[1])*1024
        mu=mt-ma; ram=f"{_h(mu)}/{_h(mt)} ({mu/mt*100:.0f}%)" if mt else "N/A"
    try:
        st=os.statvfs(str(Path.home()))
        t=st.f_blocks*st.f_frsize;f=st.f_bavail*st.f_frsize;u=t-f
        stg=f"{_h(u)}/{_h(t)} ({u/t*100:.0f}%)"
    except: stg="N/A"
    bat="N/A"
    rc,bc=_r("cat /sys/class/power_supply/battery/capacity 2>/dev/null")
    if rc==0 and bc:
        _,bs=_r("cat /sys/class/power_supply/battery/status 2>/dev/null")
        bat=f"{bc}%"+(f" ({bs})" if bs else "")
    rc3,_=_r("ping -c1 -W2 8.8.8.8",5)
    inet="\033[38;2;0;255;136m● Connected\033[0m" if rc3==0 else "\033[38;2;255;55;55m● Disconnected\033[0m"

    # Load theme name
    tname = gname.title()

    # System table with RGB
    def row(k, v):
        kc = grad(f"  {k:<14}", gc)
        print(f"{kc} \033[38;2;220;240;255m{v}\033[0m")

    sep = grad("  ─" * 25, gc)
    print(sep)
    ts = now.strftime("%A %d %b %Y  %H:%M:%S")
    print(f"  {grad('⚡ HOSHI v3.0', gc)}  \033[38;2;100;100;120m{ts}\033[0m")
    print(sep)
    row("User", f"{user}@{host}")
    row("OS", osv)
    row("Shell", shell)
    row("Python", platform.python_version())
    row("Git", gv)
    row("Arch", platform.machine())
    row("RAM", ram)
    row("Storage", stg)
    row("Battery", bat)
    row("Internet", inet)
    row("Theme", f"🎨 {tname}")
    row("Directory", os.getcwd())
    print(sep)
    hint = grad("  hoshi", gc)
    print(f"{hint} \033[38;2;100;100;120m→ open installer  \033[0m{grad('reload', gc)} \033[38;2;100;100;120m→ refresh shell\033[0m")
    print()

if __name__=="__main__": main()
        ''').strip() + "\n"
        ok = Utility.write_file(DASHBOARD_PY, code)
        if ok: Utility.make_exec(DASHBOARD_PY)
        return ok


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SHELL MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShellManager:
    def __init__(self, log: Logger, cfg: ConfigManager, pmgr: PromptManager,
                 amgr: AliasManager, dmgr: DashboardManager, tmgr: ThemeManager) -> None:
        self._log=log; self._cfg=cfg; self._p=pmgr
        self._a=amgr; self._d=dmgr; self._t=tmgr

    def generate_all(self, sh: ShellType, theme: str = "cyber") -> bool:
        self._log.info("Generating RGB shell configs...")
        self._p.write(sh, theme);  self._log.success("prompt.sh ⚡")
        self._a.write();           self._log.success("aliases.sh ⚡")
        self._gen_funcs();         self._log.success("functions.sh ⚡")
        self._gen_env(sh);         self._log.success("environment.sh ⚡")
        self._gen_startup();       self._log.success("startup.sh ⚡")
        self._d.write();           self._log.success("dashboard.py ⚡")
        self._gen_logo();          self._log.success("logo.txt ⚡")
        return True

    def inject(self, sh: ShellType) -> bool:
        rcs = [".zshrc" if sh == ShellType.ZSH else ".bashrc", ".profile"]
        blk = self._block()
        for f in rcs:
            p = HOME / f
            c = Utility.read_file(p) if p.exists() else ""
            if MARKER_START in c:
                new, ins = [], False
                for l in c.splitlines():
                    if MARKER_START in l: ins=True; continue
                    if MARKER_END in l:   ins=False; continue
                    if not ins: new.append(l)
                c = "\n".join(new)
            Utility.write_file(p, c.rstrip() + "\n\n" + blk + "\n")
            self._log.success(f"Injected ~/{f} ⚡")
        return True

    def _block(self) -> str:
        dash = f'python3 "{DASHBOARD_PY}" 2>/dev/null' if self._cfg.get("show_dashboard",True) else ""
        return f"""{MARKER_START}
[ -f "{ENVIRONMENT_SH}" ] && source "{ENVIRONMENT_SH}"
[ -f "{FUNCTIONS_SH}" ] && source "{FUNCTIONS_SH}"
[ -f "{ALIASES_SH}" ] && source "{ALIASES_SH}"
[ -f "{PROMPT_SH}" ] && source "{PROMPT_SH}"
[ -f "{STARTUP_SH}" ] && source "{STARTUP_SH}"
{dash}
{MARKER_END}"""

    def _gen_funcs(self) -> None:
        Utility.write_file(FUNCTIONS_SH, textwrap.dedent(r'''
# ═══ HOSHI Functions ═══
mkcd()  { mkdir -p "$1" && cd "$1"; }
bak()   { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }
psg()   { ps aux | grep -v grep | grep -i "$1"; }
serve() { local p="${1:-8000}"; echo "http://localhost:$p"; python3 -m http.server "$p"; }
myip()  { echo "Local: $(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)"; echo "Public: $(curl -s ifconfig.me 2>/dev/null)"; }
note()  { local nf="$HOME/.hoshi/cache/notes.txt"; if [ -z "$1" ]; then [ -f "$nf" ] && cat "$nf" || echo "No notes."; else echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$nf" && echo "Saved."; fi; }
colors(){ for i in {0..255}; do printf "\033[38;5;%sm%3d\033[0m " "$i" "$i"; [ $(((i+1)%16)) -eq 0 ] && echo; done; }
rgbtest(){ for i in $(seq 0 5 255); do printf "\033[38;2;%s;%s;0m█\033[0m" "$i" "$((255-i))"; done; echo; for i in $(seq 0 5 255); do printf "\033[38;2;0;%s;%sm█\033[0m" "$i" "$((255-i))"; done; echo; for i in $(seq 0 5 255); do printf "\033[38;2;%s;0;%sm█\033[0m" "$((255-i))" "$i"; done; echo; }
''').strip() + "\n")

    def _gen_env(self, sh: ShellType) -> None:
        zsh = sh == ShellType.ZSH
        hist = (
            'HISTFILE="$HOME/.zsh_history"\nHISTSIZE=50000; SAVEHIST=50000\n'
            'setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS EXTENDED_HISTORY INC_APPEND_HISTORY'
        ) if zsh else (
            'HISTFILE="$HOME/.bash_history"\nHISTSIZE=50000; HISTFILESIZE=50000\n'
            'HISTCONTROL=ignoreboth:erasedups\nshopt -s histappend\n'
            'PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -n"'
        )
        comp = (
            'autoload -Uz compinit && compinit -C\n'
            "zstyle ':completion:*' menu select\n"
            "zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'\n"
            '[ -f "$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"\n'
            '[ -f "$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"\n'
            "bindkey '^[[A' history-search-backward\nbindkey '^[[B' history-search-forward"
        ) if zsh else (
            '[ -f "$PREFIX/share/bash-completion/bash_completion" ] && source "$PREFIX/share/bash-completion/bash_completion"\n'
            "bind 'set completion-ignore-case on'\nbind 'set show-all-if-ambiguous on'\n"
            "bind 'set colored-stats on'\n"
            """bind '"\\e[A": history-search-backward'\nbind '"\\e[B": history-search-forward'"""
        )
        Utility.write_file(ENVIRONMENT_SH, f"""# ═══ HOSHI RGB Environment ═══
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export EDITOR=nano VISUAL=nano
export CLICOLOR=1 TERM=xterm-256color
export LS_COLORS="di=1;36:ln=1;35:so=1;33:pi=33:ex=1;32:bd=34;46:cd=34;43"
export LESS="-R" LESSHISTFILE=-
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=fg:#00ff88,bg:#0a0a14,hl:#ff0080 --color=fg+:#00ffff,bg+:#1a1a2e,hl+:#ff0080 --color=info:#a337fd,prompt:#00ff88,pointer:#ff0080 --color=marker:#00ffc8,spinner:#a337fd,header:#0080ff"
export PATH="$HOME/.local/bin:$PATH"

{hist}

{comp}
""")

    def _gen_startup(self) -> None:
        Utility.write_file(STARTUP_SH, '# ═══ HOSHI Startup ═══\nmkdir -p "$HOME/.local/bin" 2>/dev/null\n: > "$PREFIX/etc/motd" 2>/dev/null\n')

    def _gen_logo(self) -> None:
        Utility.write_file(LOGO_TXT, textwrap.dedent("""\
  ██╗  ██╗ ██████╗ ███████╗██╗  ██╗██╗
  ██║  ██║██╔═══██╗██╔════╝██║  ██║██║
  ███████║██║   ██║███████╗███████║██║
  ██╔══██║██║   ██║╚════██║██╔══██║██║
  ██║  ██║╚██████╔╝███████║██║  ██║██║
  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝
"""))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  INSTALLER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Installer:
    def __init__(self) -> None:
        self.log   = Logger()
        self.anim  = AnimationManager()
        self.cfg   = ConfigManager()
        self.sys   = SystemDetector()
        self.bak   = BackupManager(self.log)
        self.rst   = RestoreManager(self.log, self.bak)
        self.tmgr  = ThemeManager(self.cfg, self.log)
        self.pmgr  = PromptManager(self.tmgr, self.cfg)
        self.amgr  = AliasManager(self.log)
        self.dmgr  = DashboardManager()
        self.deps  = DependencyManager(self.log, self.anim)
        self.shell = ShellManager(self.log, self.cfg, self.pmgr, self.amgr, self.dmgr, self.tmgr)
        self._info: Optional[SystemInfo] = None

    def _detect(self) -> SystemInfo:
        if not self._info:
            with self.anim.spinner("Scanning system..."):
                self._info = self.sys.detect_all()
                self.anim.pause(0.5)
        return self._info

    # ── Header ──

    def _header(self) -> None:
        console.clear()
        gradient = self.cfg.get("gradient", "cyber") if self.cfg._c else "cyber"
        banner_lines = [
            "  ██╗  ██╗ ██████╗ ███████╗██╗  ██╗██╗",
            "  ██║  ██║██╔═══██╗██╔════╝██║  ██║██║",
            "  ███████║██║   ██║███████╗███████║██║",
            "  ██╔══██║██║   ██║╚════██║██╔══██║██║",
            "  ██║  ██║╚██████╔╝███████║██║  ██║██║",
            "  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝",
        ]
        print()
        colors = RGB.GRADIENT_PRESETS.get(gradient, RGB.GRADIENT_PRESETS["cyber"])
        for line in banner_lines:
            print(RGB.gradient_text(line, colors))
        print()
        sub = RGB.gradient_text(f"  ⚡ HOSHI v{VERSION} — Cyber Shell Installer ⚡", colors)
        print(sub)
        sep = RGB.gradient_text("  " + "━" * 50, colors)
        print(sep)
        print()

    def _section(self, t: str) -> None:
        g = self.cfg.get("gradient", "cyber") if self.cfg._c else "cyber"
        c = RGB.GRADIENT_PRESETS.get(g, RGB.GRADIENT_PRESETS["cyber"])
        line = RGB.gradient_text(f"  ──── {t} ────", c)
        print(line)
        print()

    def _menu_item(self, n: str, label: str, desc: str = "") -> str:
        g = self.cfg.get("gradient", "cyber") if self.cfg._c else "cyber"
        c = RGB.GRADIENT_PRESETS.get(g, RGB.GRADIENT_PRESETS["cyber"])
        num_colored = RGB.gradient_text(f"  [{n}]", c)
        return f"{num_colored}  \033[38;2;200;220;255m{label}\033[0m  \033[38;2;100;100;120m{desc}\033[0m"

    def _wait(self) -> None:
        console.print()
        Prompt.ask("  [h.muted]Press Enter[/]", default="")

    # ── System Info ──

    def _show_sys(self) -> None:
        info = self._detect()
        g = self.cfg.get("gradient", "cyber") if self.cfg._c else "cyber"
        c = RGB.GRADIENT_PRESETS.get(g, RGB.GRADIENT_PRESETS["cyber"])

        tbl = Table(show_header=False, box=box.SIMPLE_HEAD, padding=(0,2),
                    show_edge=False, border_style="rgb(0,255,136)")
        tbl.add_column("k", style="bold rgb(0,255,200)", width=16)
        tbl.add_column("v", style="rgb(220,240,255)")

        inet_s = "[bold rgb(0,255,136)]● Connected[/]" if info.internet else "[bold rgb(255,55,55)]● Disconnected[/]"
        rows = [
            ("Platform", "Termux / Android" if info.is_termux else info.os_name),
            ("OS", info.os_version), ("Kernel", info.kernel),
            ("Arch", info.architecture), ("Hostname", info.hostname),
            ("User", info.username), ("Shell", info.shell),
            ("Python", info.python_version), ("Git", info.git_version),
            ("CPU", info.cpu_info[:40]),
            ("RAM", f"{info.ram_used} / {info.ram_total} ({info.ram_percent})"),
            ("Storage", f"{info.storage_used} / {info.storage_total} ({info.storage_percent})"),
            ("Battery", f"{info.battery_level} ({info.battery_status})"),
            ("Internet", inet_s),
            ("Directory", info.current_dir),
        ]
        for k, v in rows: tbl.add_row(k, v)

        console.print(Panel(tbl, title="[bold rgb(0,255,136)]⚡ System Scan ⚡[/]",
                            border_style="rgb(0,255,136)", box=box.HEAVY, padding=(0,1)))

    # ── Install ──

    def do_install(self) -> None:
        self._header()
        self._section("⚡ INSTALLATION")
        info = self._detect()
        self._show_sys()
        console.print()
        if not Confirm.ask("  [h.cyber]⚡ Proceed with installation?[/]", default=True):
            return

        console.print()
        self.anim.glitch_text("INITIALIZING HOSHI CYBER SHELL...", 12)
        self.anim.pause(0.3)

        # Dirs
        self.log.info("Creating directories...")
        for d in [HOSHI_DIR, CACHE_DIR, LOGS_DIR, BACKUP_DIR, THEMES_DIR]:
            d.mkdir(parents=True, exist_ok=True)
        self.log.success("Directory structure ready")

        # Backup
        self.log.info("Backing up existing config...")
        self.bak.create()

        # Deps
        console.print()
        self._section("⚡ DEPENDENCIES")
        ds = self.deps.check_all()

        tbl = Table(show_header=True, box=box.SIMPLE, show_edge=False, padding=(0,2),
                    border_style="rgb(0,255,136)")
        tbl.add_column("Package", style="rgb(0,255,200)")
        tbl.add_column("Status", justify="center")
        for d in ds:
            s = "[bold rgb(0,255,136)]✓ Ready[/]" if d["installed"] else "[bold rgb(255,165,0)]○ Missing[/]"
            tbl.add_row(d["name"], s)
        console.print(Panel(tbl, title="[bold rgb(0,255,255)]Dependencies[/]",
                            border_style="rgb(0,128,255)", box=box.HEAVY, padding=(0,1)))
        console.print()
        self.deps.install_missing(ds)
        self.deps.install_starship()

        # Generate
        console.print()
        self._section("⚡ GENERATING CONFIG")
        theme = self.cfg.get("theme", "cyber")
        self.anim.rgb_progress_bar("Generating", 30, 1.2)
        self.cfg.save(self.cfg._defaults())
        self.cfg.save_theme(ThemeConfig(name=theme, gradient=theme))
        self.cfg.create_colors()
        self.shell.generate_all(info.shell_type, theme)
        self.shell.inject(info.shell_type)

        # MOTD
        try:
            motd = Path(os.environ.get("PREFIX","/data/data/com.termux/files/usr")) / "etc" / "motd"
            motd.write_text("", "utf-8")
        except: pass

        # Zsh plugins
        if info.shell_type == ShellType.ZSH:
            pkg = "pkg" if Utility.cmd_exists("pkg") else "apt"
            for pl in ["zsh-autosuggestions", "zsh-syntax-highlighting"]:
                rc, _, _ = Utility.run_cmd(f"{pkg} install -y {pl}", 60)
                if rc == 0: self.log.success(pl)

        console.print()
        self._section("⚡ COMPLETE")
        self.anim.glitch_text("HOSHI CYBER SHELL ACTIVATED!", 10)
        console.print()
        console.print(Panel(
            Text.from_markup(
                "[bold rgb(0,255,136)]⚡ Installation Complete! ⚡[/]\n\n"
                "[rgb(220,240,255)]Close & reopen Termux, or run:[/] "
                "[bold rgb(0,255,255)]exec $SHELL[/]\n\n"
                "[rgb(100,100,120)]Type [bold rgb(0,255,136)]hoshi[/bold rgb(0,255,136)] "
                "anytime to manage your cyber shell.[/rgb(100,100,120)]"
            ),
            border_style="rgb(0,255,136)", box=box.HEAVY, padding=(1,3),
        ))
        self._wait()

    # ── Update ──

    def do_update(self) -> None:
        self._header(); self._section("⚡ UPDATE")
        if not HOSHI_DIR.exists():
            self.log.error("Not installed"); self._wait(); return
        self.cfg.load(); info = self._detect()
        theme = self.cfg.get("theme", "cyber")
        self.anim.rgb_progress_bar("Regenerating", 25, 1.0)
        self.shell.generate_all(info.shell_type, theme)
        self.shell.inject(info.shell_type)
        self.log.success("Updated — exec $SHELL to apply")
        self._wait()

    # ── Backup ──

    def do_backup(self) -> None:
        self._header(); self._section("⚡ BACKUP")
        self.anim.cyber_loading("Creating backup...", 1.0)
        self.bak.create()
        bks = self.bak.list_all()
        if bks:
            tbl = Table(show_header=True, box=box.SIMPLE, show_edge=False,
                        padding=(0,2), border_style="rgb(0,255,136)")
            tbl.add_column("#", style="bold rgb(0,255,255)", width=4)
            tbl.add_column("Backup ID", style="rgb(0,255,200)")
            for i, b in enumerate(bks[:8], 1): tbl.add_row(str(i), b.name)
            console.print(Panel(tbl, title="[bold rgb(0,255,136)]Backups[/]",
                                border_style="rgb(0,128,255)", box=box.HEAVY, padding=(0,1)))
        self._wait()

    # ── Restore ──

    def do_restore(self) -> None:
        self._header(); self._section("⚡ RESTORE")
        bks = self.bak.list_all()
        if not bks: self.log.error("No backups"); self._wait(); return
        tbl = Table(show_header=True, box=box.SIMPLE, show_edge=False,
                    padding=(0,2), border_style="rgb(0,255,136)")
        tbl.add_column("#", style="bold rgb(0,255,255)", width=4)
        tbl.add_column("ID", style="rgb(0,255,200)")
        for i, b in enumerate(bks[:8], 1): tbl.add_row(str(i), b.name)
        console.print(Panel(tbl, title="[bold rgb(0,255,255)]Select[/]",
                            border_style="rgb(0,128,255)", box=box.HEAVY, padding=(0,1)))
        ch = Prompt.ask("  [h.cyber]Number[/]", default="1")
        try:
            idx = int(ch) - 1
            if 0 <= idx < len(bks):
                if Confirm.ask(f"  [h.warning]Restore {bks[idx].name}?[/]", default=False):
                    self.rst.restore_from(bks[idx])
                    self.log.success("Restored — exec $SHELL")
        except: self.log.error("Invalid")
        self._wait()

    # ── Theme ──

    def do_theme(self) -> None:
        self._header(); self._section("⚡ THEMES")
        themes = self.tmgr.list_all()
        names = list(themes.keys())
        current = self.cfg.get("theme", "cyber")

        tbl = Table(show_header=True, box=box.SIMPLE, show_edge=False,
                    padding=(0,2), border_style="rgb(0,255,136)")
        tbl.add_column("#", style="bold rgb(0,255,255)", width=4)
        tbl.add_column("Theme", style="rgb(0,255,200)", width=16)
        tbl.add_column("Preview", width=30)
        tbl.add_column("Description", style="rgb(100,100,120)")

        for i, name in enumerate(names, 1):
            t = themes[name]
            mark = " ◄" if name == current else ""
            # Preview gradient bar
            gc = RGB.GRADIENT_PRESETS.get(t["gradient"], RGB.GRADIENT_PRESETS["cyber"])
            preview = ""
            for j in range(25):
                pos = j / 24
                seg = len(gc) - 1
                ci = min(int(pos * seg), seg - 1)
                fr = pos * seg - ci
                c1, c2 = gc[ci], gc[min(ci+1, len(gc)-1)]
                r = int(c1[0]+(c2[0]-c1[0])*fr)
                g = int(c1[1]+(c2[1]-c1[1])*fr)
                b = int(c1[2]+(c2[2]-c1[2])*fr)
                preview += f"\033[38;2;{r};{g};{b}m█\033[0m"
            tbl.add_row(str(i), t["name"] + mark, preview, t["desc"])

        console.print(Panel(tbl, title="[bold rgb(0,255,136)]⚡ RGB Themes ⚡[/]",
                            border_style="rgb(0,255,136)", box=box.HEAVY, padding=(0,1)))
        console.print()
        ch = Prompt.ask("  [h.cyber]Select theme[/]", default="1")
        try:
            idx = int(ch) - 1
            if 0 <= idx < len(names):
                sel = names[idx]
                self.tmgr.apply(sel)
                info = self._detect()
                self.anim.glitch_text(f"APPLYING {themes[sel]['name'].upper()} THEME...", 8)
                self.shell.generate_all(info.shell_type, sel)
                self.shell.inject(info.shell_type)
                self.log.success(f"Theme → {themes[sel]['name']} — exec $SHELL")
        except: self.log.error("Invalid")
        self._wait()

    # ── Settings ──

    def do_settings(self) -> None:
        opts = [
            ("show_dashboard", "Dashboard on Startup"),
            ("show_banner",    "Show Banner"),
            ("animation",      "Animations"),
            ("show_time",      "Time in Prompt"),
            ("matrix_rain",    "Matrix Rain Effect"),
            ("glitch_effect",  "Glitch Effects"),
            ("rgb_prompt",     "RGB Cycling Prompt"),
        ]
        while True:
            self._header(); self._section("⚡ SETTINGS")
            self.cfg.load()
            tbl = Table(show_header=True, box=box.SIMPLE, show_edge=False,
                        padding=(0,2), border_style="rgb(0,255,136)")
            tbl.add_column("#", style="bold rgb(0,255,255)", width=4)
            tbl.add_column("Setting", style="rgb(220,240,255)", width=26)
            tbl.add_column("Value", justify="center")
            for i, (k, label) in enumerate(opts, 1):
                v = self.cfg.get(k, True)
                vs = "[bold rgb(0,255,136)]⚡ ON[/]" if v else "[bold rgb(255,55,55)]○ OFF[/]"
                tbl.add_row(str(i), label, vs)
            console.print(Panel(tbl, title="[bold rgb(0,255,200)]Settings[/]",
                                border_style="rgb(0,128,255)", box=box.HEAVY, padding=(0,1)))
            console.print()
            print(self._menu_item("1-7", "Toggle setting"))
            print(self._menu_item("0", "Back"))
            console.print()
            ch = Prompt.ask("  [h.cyber]Select[/]", default="0")
            if ch == "0": break
            try:
                idx = int(ch) - 1
                if 0 <= idx < len(opts):
                    k, _ = opts[idx]
                    self.cfg.set(k, not self.cfg.get(k, True))
                    info = self._detect()
                    self.shell.generate_all(info.shell_type, self.cfg.get("theme","cyber"))
                    self.shell.inject(info.shell_type)
                    self.log.success("Updated")
                    self.anim.pause(0.4)
            except: self.log.error("Invalid"); self.anim.pause(0.4)

    # ── Uninstall ──

    def do_uninstall(self) -> None:
        self._header(); self._section("⚡ UNINSTALL")
        console.print(Panel(
            "[h.warning]⚠ This removes all HOSHI configs and restores original shell.[/]",
            border_style="rgb(255,165,0)", box=box.HEAVY, padding=(1,3)))
        console.print()
        if not Confirm.ask("  [h.error]Confirm uninstall?[/]", default=False):
            self._wait(); return
        self.anim.glitch_text("REMOVING HOSHI CYBER SHELL...", 10)
        self.rst.restore_latest()
        for f in SHELL_FILES:
            fp = HOME / f
            if fp.exists(): RestoreManager._rm_block(fp)
        try: shutil.rmtree(HOSHI_DIR); self.log.success("Directory removed")
        except Exception as e: self.log.error(str(e))
        try:
            motd = Path(os.environ.get("PREFIX","/data/data/com.termux/files/usr")) / "etc" / "motd"
            motd.write_text("Welcome to Termux!\n", "utf-8")
        except: pass
        console.print(Panel(
            "[h.success]⚡ Uninstalled. Run exec $SHELL.[/]",
            border_style="rgb(0,255,136)", box=box.HEAVY, padding=(1,3)))
        self._wait()

    # ── Main Menu ──

    def main_menu(self) -> None:
        if CONFIG_FILE.exists(): self.cfg.load()
        while True:
            self._header()
            installed = HOSHI_DIR.exists() and CONFIG_FILE.exists()
            st = "\033[38;2;0;255;136m⚡ ACTIVE\033[0m" if installed else "\033[38;2;255;165;0m○ NOT INSTALLED\033[0m"
            print(f"  Status: {st}")
            print()

            items = [
                ("1", "⚡ Install",     "Full RGB installation"),
                ("2", "🔄 Update",      "Regenerate configs"),
                ("3", "💾 Backup",      "Save current config"),
                ("4", "♻️  Restore",     "Restore from backup"),
                ("5", "🎨 Themes",      "Change RGB theme"),
                ("6", "⚙️  Settings",    "Toggle features"),
                ("7", "🖥️  System",      "View system scan"),
                ("8", "🗑️  Uninstall",   "Remove HOSHI"),
                ("0", "🚪 Exit",        ""),
            ]
            for n, l, d in items:
                print(self._menu_item(n, l, d))
            console.print()

            ch = Prompt.ask("  [h.cyber]⚡ Select[/]", default="0")
            try:
                match ch:
                    case "1": self.do_install()
                    case "2": self.do_update()
                    case "3": self.do_backup()
                    case "4": self.do_restore()
                    case "5": self.do_theme()
                    case "6": self.do_settings()
                    case "7":
                        self._header(); self._section("⚡ SYSTEM SCAN")
                        self._show_sys(); self._wait()
                    case "8": self.do_uninstall()
                    case "0"|"q"|"exit":
                        console.print()
                        self.anim.glitch_text("DISCONNECTING...", 6)
                        console.print()
                        sys.exit(0)
                    case _:
                        self.log.warning("Invalid"); self.anim.pause(0.5)
            except KeyboardInterrupt:
                console.print("\n"); sys.exit(0)
            except Exception as e:
                ErrorHandler.handle(e, "Menu"); self._wait()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ENTRY POINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main() -> None:
    signal.signal(signal.SIGINT, lambda s, f: (print("\n"), sys.exit(0)))
    if sys.version_info < (3, 10):
        print(f"\033[38;2;255;55;55mPython 3.10+ required. Got {platform.python_version()}\033[0m")
        sys.exit(1)
    Installer().main_menu()

if __name__ == "__main__":
    main()