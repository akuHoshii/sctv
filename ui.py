#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║                        HOSHI INSTALLER                         ║
║              Professional Shell Environment for Termux          ║
║                                                                  ║
║  A single-file Python installer that transforms your Termux     ║
║  shell into a modern, enterprise-grade terminal experience.      ║
║                                                                  ║
║  Author: Hoshi Project                                           ║
║  License: MIT                                                    ║
║  Version: 2.0.0                                                  ║
║  Python: 3.10+                                                   ║
╚══════════════════════════════════════════════════════════════════╝
"""

from __future__ import annotations

import datetime
import json
import logging
import os
import platform
import shutil
import signal
import subprocess
import sys
import textwrap
import time
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Any, Optional

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PRE-FLIGHT: Ensure 'rich' is available
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _ensure_rich() -> None:
    """Install rich library if not present."""
    try:
        import rich  # noqa: F401
    except ImportError:
        print("[*] Installing required dependency: rich ...")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "rich"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

_ensure_rich()

from rich import box
from rich.align import Align
from rich.columns import Columns
from rich.console import Console
from rich.layout import Layout
from rich.live import Live
from rich.markdown import Markdown
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TaskProgressColumn,
    TextColumn,
    TimeElapsedColumn,
)
from rich.prompt import Confirm, Prompt
from rich.rule import Rule
from rich.status import Status
from rich.style import Style
from rich.table import Table
from rich.text import Text
from rich.theme import Theme
from rich.tree import Tree

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CONSTANTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VERSION: str = "2.0.0"
APP_NAME: str = "HOSHI"
APP_DESC: str = "Professional Shell Environment"

HOME: Path = Path.home()
HOSHI_DIR: Path = HOME / ".hoshi"
CACHE_DIR: Path = HOSHI_DIR / "cache"
LOGS_DIR: Path = HOSHI_DIR / "logs"
BACKUP_DIR: Path = HOSHI_DIR / "backups"
THEMES_DIR: Path = HOSHI_DIR / "themes"

CONFIG_FILE: Path = HOSHI_DIR / "config.json"
THEME_FILE: Path = HOSHI_DIR / "theme.json"
COLORS_FILE: Path = HOSHI_DIR / "colors.json"

PROMPT_SH: Path = HOSHI_DIR / "prompt.sh"
ALIASES_SH: Path = HOSHI_DIR / "aliases.sh"
STARTUP_SH: Path = HOSHI_DIR / "startup.sh"
FUNCTIONS_SH: Path = HOSHI_DIR / "functions.sh"
ENVIRONMENT_SH: Path = HOSHI_DIR / "environment.sh"
DASHBOARD_PY: Path = HOSHI_DIR / "dashboard.py"
LOGO_TXT: Path = HOSHI_DIR / "logo.txt"

SHELL_FILES: list[str] = [
    ".bashrc",
    ".zshrc",
    ".profile",
    ".bash_profile",
    ".bash_login",
]

DEPENDENCIES: list[dict[str, str]] = [
    {"name": "git", "pkg": "git"},
    {"name": "curl", "pkg": "curl"},
    {"name": "wget", "pkg": "wget"},
    {"name": "zsh", "pkg": "zsh"},
    {"name": "fzf", "pkg": "fzf"},
    {"name": "bat", "pkg": "bat"},
    {"name": "eza", "pkg": "eza"},
    {"name": "rg", "pkg": "ripgrep"},
    {"name": "fd", "pkg": "fd"},
]

HOSHI_MARKER_START: str = "# ═══ HOSHI SHELL ENVIRONMENT ═══ START ═══"
HOSHI_MARKER_END: str = "# ═══ HOSHI SHELL ENVIRONMENT ═══ END ═══"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RICH THEME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOSHI_THEME = Theme(
    {
        "h.title": "bold bright_white",
        "h.subtitle": "dim white",
        "h.accent": "bold cyan",
        "h.success": "bold green",
        "h.warning": "bold yellow",
        "h.error": "bold red",
        "h.info": "bold blue",
        "h.debug": "dim magenta",
        "h.muted": "dim white",
        "h.border": "bright_black",
        "h.key": "bold bright_cyan",
        "h.value": "white",
        "h.header": "bold bright_white on grey23",
        "h.menu_num": "bold cyan",
        "h.menu_item": "white",
        "h.highlight": "bold bright_white",
        "h.panel_border": "bright_black",
    }
)

console = Console(theme=HOSHI_THEME)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ENUMS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class LogLevel(Enum):
    """Log level categories."""
    DEBUG = "debug"
    INFO = "info"
    SUCCESS = "success"
    WARNING = "warning"
    ERROR = "error"


class ShellType(Enum):
    """Supported shell types."""
    BASH = "bash"
    ZSH = "zsh"
    UNKNOWN = "unknown"


class PromptStyle(Enum):
    """Prompt display styles."""
    MINIMAL = "minimal"
    MODERN = "modern"
    POWERLINE = "powerline"
    CLASSIC = "classic"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DATA CLASSES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


@dataclass
class SystemInfo:
    """Container for system information."""
    os_name: str = ""
    os_version: str = ""
    kernel: str = ""
    architecture: str = ""
    hostname: str = ""
    username: str = ""
    shell: str = ""
    shell_type: ShellType = ShellType.UNKNOWN
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
    cpu_usage: str = ""


@dataclass
class ThemeConfig:
    """Theme configuration."""
    name: str = "enterprise"
    prompt_style: str = "modern"
    primary_color: str = "cyan"
    secondary_color: str = "blue"
    accent_color: str = "magenta"
    success_color: str = "green"
    warning_color: str = "yellow"
    error_color: str = "red"
    muted_color: str = "bright_black"
    text_color: str = "white"
    border_style: str = "rounded"
    show_dashboard: bool = True
    show_banner: bool = True
    show_time_in_prompt: bool = False
    animation_enabled: bool = True


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  UTILITY CLASS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class Utility:
    """General-purpose utility methods."""

    @staticmethod
    def run_cmd(
        cmd: str,
        capture: bool = True,
        timeout: int = 30,
    ) -> tuple[int, str, str]:
        """Execute a shell command and return (returncode, stdout, stderr)."""
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=capture,
                text=True,
                timeout=timeout,
            )
            return result.returncode, result.stdout.strip(), result.stderr.strip()
        except subprocess.TimeoutExpired:
            return -1, "", "Command timed out"
        except Exception as e:
            return -1, "", str(e)

    @staticmethod
    def cmd_exists(cmd: str) -> bool:
        """Check if a command exists in PATH."""
        return shutil.which(cmd) is not None

    @staticmethod
    def read_file(path: Path) -> str:
        """Safely read a file."""
        try:
            return path.read_text(encoding="utf-8")
        except Exception:
            return ""

    @staticmethod
    def write_file(path: Path, content: str) -> bool:
        """Safely write a file."""
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
            return True
        except Exception:
            return False

    @staticmethod
    def make_executable(path: Path) -> bool:
        """Make a file executable."""
        try:
            path.chmod(0o755)
            return True
        except Exception:
            return False

    @staticmethod
    def timestamp() -> str:
        """Current timestamp string."""
        return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

    @staticmethod
    def human_size(nbytes: float) -> str:
        """Convert bytes to human-readable size."""
        for unit in ("B", "KB", "MB", "GB", "TB"):
            if abs(nbytes) < 1024.0:
                return f"{nbytes:.1f} {unit}"
            nbytes /= 1024.0
        return f"{nbytes:.1f} PB"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ERROR HANDLER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class ErrorHandler:
    """Centralized error handling."""

    @staticmethod
    def handle(
        error: Exception,
        context: str = "",
        fatal: bool = False,
    ) -> None:
        """Handle an error with optional context."""
        msg = f"{context}: {error}" if context else str(error)
        console.print(f"  [h.error]✗ ERROR:[/] {msg}")

        log_path = LOGS_DIR / "error.log"
        try:
            LOGS_DIR.mkdir(parents=True, exist_ok=True)
            with open(log_path, "a", encoding="utf-8") as f:
                f.write(f"[{Utility.timestamp()}] {msg}\n")
        except Exception:
            pass

        if fatal:
            console.print("  [h.error]Fatal error. Exiting.[/]")
            sys.exit(1)

    @staticmethod
    def require_termux() -> bool:
        """Check if running inside Termux."""
        return (
            "com.termux" in os.environ.get("PREFIX", "")
            or Path("/data/data/com.termux").exists()
        )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  LOGGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class Logger:
    """Professional logger with colored output and file logging."""

    _STYLES: dict[LogLevel, tuple[str, str]] = {
        LogLevel.DEBUG: ("h.debug", "⚙"),
        LogLevel.INFO: ("h.info", "ℹ"),
        LogLevel.SUCCESS: ("h.success", "✓"),
        LogLevel.WARNING: ("h.warning", "⚠"),
        LogLevel.ERROR: ("h.error", "✗"),
    }

    def __init__(self, log_dir: Path = LOGS_DIR) -> None:
        self._log_dir = log_dir
        self._log_dir.mkdir(parents=True, exist_ok=True)
        self._log_file = self._log_dir / "installer.log"

    def _write(self, level: LogLevel, message: str) -> None:
        """Write to log file."""
        try:
            with open(self._log_file, "a", encoding="utf-8") as f:
                f.write(f"[{Utility.timestamp()}] [{level.value.upper()}] {message}\n")
        except Exception:
            pass

    def _print(self, level: LogLevel, message: str) -> None:
        """Print to console with style."""
        style, icon = self._STYLES[level]
        console.print(f"  [{style}]{icon}[/] {message}")
        self._write(level, message)

    def debug(self, msg: str) -> None:
        self._print(LogLevel.DEBUG, msg)

    def info(self, msg: str) -> None:
        self._print(LogLevel.INFO, msg)

    def success(self, msg: str) -> None:
        self._print(LogLevel.SUCCESS, msg)

    def warning(self, msg: str) -> None:
        self._print(LogLevel.WARNING, msg)

    def error(self, msg: str) -> None:
        self._print(LogLevel.ERROR, msg)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ANIMATION MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class AnimationManager:
    """Handles spinners, progress bars, and typing effects."""

    def __init__(self, enabled: bool = True) -> None:
        self.enabled = enabled

    def typing_effect(self, text: str, delay: float = 0.02) -> None:
        """Simulate typing effect."""
        if not self.enabled:
            console.print(text)
            return
        for char in text:
            console.print(char, end="", highlight=False)
            time.sleep(delay)
        console.print()

    def spinner(self, message: str) -> Status:
        """Return a rich Status spinner."""
        return console.status(f"  {message}", spinner="dots")

    def progress_bar(self) -> Progress:
        """Return a configured Progress bar."""
        return Progress(
            SpinnerColumn(spinner_name="dots", style="cyan"),
            TextColumn("[h.info]{task.description}"),
            BarColumn(bar_width=30, style="bright_black", complete_style="cyan"),
            TaskProgressColumn(),
            TimeElapsedColumn(),
            console=console,
        )

    def brief_pause(self, seconds: float = 0.3) -> None:
        """Brief pause for visual effect."""
        if self.enabled:
            time.sleep(seconds)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  CONFIG MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class ConfigManager:
    """Manages JSON configuration files."""

    def __init__(self) -> None:
        self._config: dict[str, Any] = {}
        self._theme: ThemeConfig = ThemeConfig()

    def load(self) -> dict[str, Any]:
        """Load main configuration."""
        if CONFIG_FILE.exists():
            try:
                self._config = json.loads(CONFIG_FILE.read_text("utf-8"))
            except Exception:
                self._config = self._defaults()
        else:
            self._config = self._defaults()
        return self._config

    def save(self, config: Optional[dict[str, Any]] = None) -> bool:
        """Save configuration to disk."""
        if config:
            self._config = config
        return Utility.write_file(CONFIG_FILE, json.dumps(self._config, indent=2))

    def get(self, key: str, default: Any = None) -> Any:
        """Get a config value."""
        return self._config.get(key, default)

    def set(self, key: str, value: Any) -> None:
        """Set a config value."""
        self._config[key] = value
        self.save()

    def load_theme(self) -> ThemeConfig:
        """Load theme configuration."""
        if THEME_FILE.exists():
            try:
                data = json.loads(THEME_FILE.read_text("utf-8"))
                self._theme = ThemeConfig(**data)
            except Exception:
                self._theme = ThemeConfig()
        return self._theme

    def save_theme(self, theme: Optional[ThemeConfig] = None) -> bool:
        """Save theme configuration."""
        if theme:
            self._theme = theme
        from dataclasses import asdict
        return Utility.write_file(THEME_FILE, json.dumps(asdict(self._theme), indent=2))

    def _defaults(self) -> dict[str, Any]:
        """Default configuration."""
        return {
            "version": VERSION,
            "installed_at": Utility.timestamp(),
            "shell": "auto",
            "prompt_style": "modern",
            "theme": "enterprise",
            "show_dashboard": True,
            "show_banner": True,
            "animation": True,
            "show_time_in_prompt": False,
        }

    def create_colors_file(self) -> bool:
        """Create the colors.json file."""
        colors = {
            "primary": "#06B6D4",
            "secondary": "#3B82F6",
            "accent": "#A855F7",
            "success": "#22C55E",
            "warning": "#EAB308",
            "error": "#EF4444",
            "surface": "#1E1E2E",
            "text": "#CDD6F4",
            "muted": "#6C7086",
            "border": "#45475A",
        }
        return Utility.write_file(COLORS_FILE, json.dumps(colors, indent=2))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SYSTEM DETECTOR
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class SystemDetector:
    """Detects system information for Termux / Android."""

    def __init__(self) -> None:
        self.info = SystemInfo()

    def detect_all(self) -> SystemInfo:
        """Run all detection routines."""
        self._detect_os()
        self._detect_termux()
        self._detect_kernel()
        self._detect_arch()
        self._detect_hostname()
        self._detect_username()
        self._detect_shell()
        self._detect_python()
        self._detect_git()
        self._detect_cpu()
        self._detect_ram()
        self._detect_storage()
        self._detect_battery()
        self._detect_internet()
        self._detect_cwd()
        self._detect_package_manager()
        self._detect_cpu_usage()
        return self.info

    def _detect_os(self) -> None:
        self.info.os_name = platform.system()
        rc, out, _ = Utility.run_cmd("getprop ro.build.version.release", timeout=5)
        if rc == 0 and out:
            self.info.os_version = f"Android {out}"
            self.info.is_android = True
        else:
            self.info.os_version = platform.version()

    def _detect_termux(self) -> None:
        prefix = os.environ.get("PREFIX", "")
        self.info.is_termux = "com.termux" in prefix or Path(
            "/data/data/com.termux"
        ).exists()

    def _detect_kernel(self) -> None:
        self.info.kernel = platform.release()

    def _detect_arch(self) -> None:
        self.info.architecture = platform.machine()

    def _detect_hostname(self) -> None:
        rc, out, _ = Utility.run_cmd("hostname", timeout=5)
        self.info.hostname = out if rc == 0 and out else platform.node() or "localhost"

    def _detect_username(self) -> None:
        self.info.username = os.environ.get(
            "USER", os.environ.get("LOGNAME", "user")
        )

    def _detect_shell(self) -> None:
        shell = os.environ.get("SHELL", "")
        self.info.shell = shell
        if "zsh" in shell:
            self.info.shell_type = ShellType.ZSH
        elif "bash" in shell:
            self.info.shell_type = ShellType.BASH
        else:
            self.info.shell_type = ShellType.BASH  # default

    def _detect_python(self) -> None:
        self.info.python_version = platform.python_version()

    def _detect_git(self) -> None:
        rc, out, _ = Utility.run_cmd("git --version", timeout=5)
        if rc == 0:
            self.info.git_version = out.replace("git version ", "")
        else:
            self.info.git_version = "N/A"

    def _detect_cpu(self) -> None:
        rc, out, _ = Utility.run_cmd(
            "cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2",
            timeout=5,
        )
        if rc == 0 and out:
            self.info.cpu_info = out.strip()
        else:
            rc2, out2, _ = Utility.run_cmd(
                "cat /proc/cpuinfo | grep 'Hardware' | head -1 | cut -d':' -f2",
                timeout=5,
            )
            self.info.cpu_info = out2.strip() if rc2 == 0 and out2 else platform.processor() or "N/A"

    def _detect_ram(self) -> None:
        rc, out, _ = Utility.run_cmd("cat /proc/meminfo", timeout=5)
        if rc == 0 and out:
            lines = out.splitlines()
            mem_total = mem_avail = 0
            for line in lines:
                if line.startswith("MemTotal:"):
                    mem_total = int(line.split()[1]) * 1024
                elif line.startswith("MemAvailable:"):
                    mem_avail = int(line.split()[1]) * 1024
            mem_used = mem_total - mem_avail
            self.info.ram_total = Utility.human_size(mem_total)
            self.info.ram_used = Utility.human_size(mem_used)
            if mem_total > 0:
                self.info.ram_percent = f"{(mem_used / mem_total) * 100:.0f}%"
            else:
                self.info.ram_percent = "N/A"
        else:
            self.info.ram_total = "N/A"
            self.info.ram_used = "N/A"
            self.info.ram_percent = "N/A"

    def _detect_storage(self) -> None:
        try:
            st = os.statvfs(str(HOME))
            total = st.f_blocks * st.f_frsize
            free = st.f_bavail * st.f_frsize
            used = total - free
            self.info.storage_total = Utility.human_size(total)
            self.info.storage_used = Utility.human_size(used)
            self.info.storage_percent = f"{(used / total) * 100:.0f}%" if total else "N/A"
        except Exception:
            self.info.storage_total = "N/A"
            self.info.storage_used = "N/A"
            self.info.storage_percent = "N/A"

    def _detect_battery(self) -> None:
        # Termux battery API
        rc, out, _ = Utility.run_cmd("termux-battery-status 2>/dev/null", timeout=10)
        if rc == 0 and out:
            try:
                data = json.loads(out)
                self.info.battery_level = f"{data.get('percentage', 'N/A')}%"
                self.info.battery_status = data.get("status", "N/A")
                return
            except Exception:
                pass
        # Fallback
        rc2, out2, _ = Utility.run_cmd(
            "cat /sys/class/power_supply/battery/capacity 2>/dev/null", timeout=5
        )
        if rc2 == 0 and out2:
            self.info.battery_level = f"{out2}%"
        else:
            self.info.battery_level = "N/A"
        rc3, out3, _ = Utility.run_cmd(
            "cat /sys/class/power_supply/battery/status 2>/dev/null", timeout=5
        )
        self.info.battery_status = out3 if rc3 == 0 and out3 else "N/A"

    def _detect_internet(self) -> None:
        rc, _, _ = Utility.run_cmd("ping -c 1 -W 3 8.8.8.8", timeout=8)
        self.info.internet = rc == 0

    def _detect_cwd(self) -> None:
        self.info.current_dir = os.getcwd()

    def _detect_package_manager(self) -> None:
        if Utility.cmd_exists("pkg"):
            self.info.package_manager = "pkg"
        elif Utility.cmd_exists("apt"):
            self.info.package_manager = "apt"
        else:
            self.info.package_manager = "unknown"

    def _detect_cpu_usage(self) -> None:
        rc, out, _ = Utility.run_cmd(
            r"top -bn1 2>/dev/null | grep '%Cpu' | head -1 | awk '{print $2}'",
            timeout=5,
        )
        if rc == 0 and out:
            self.info.cpu_usage = f"{out}%"
        else:
            self.info.cpu_usage = "N/A"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DEPENDENCY MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class DependencyManager:
    """Checks and installs required system packages."""

    def __init__(self, logger: Logger, animation: AnimationManager) -> None:
        self._log = logger
        self._anim = animation
        self._pkg_mgr = "pkg" if Utility.cmd_exists("pkg") else "apt"

    def check_all(self) -> list[dict[str, Any]]:
        """Check all dependencies, return list with status."""
        results: list[dict[str, Any]] = []
        for dep in DEPENDENCIES:
            found = Utility.cmd_exists(dep["name"])
            results.append({**dep, "installed": found})
        return results

    def install_missing(self, deps: list[dict[str, Any]]) -> bool:
        """Install missing dependencies."""
        missing = [d for d in deps if not d["installed"]]
        if not missing:
            self._log.success("All dependencies are already installed")
            return True

        self._log.info(f"Installing {len(missing)} missing package(s)...")

        # Update package lists first
        with self._anim.spinner("Updating package lists..."):
            Utility.run_cmd(f"{self._pkg_mgr} update -y", timeout=120)
            self._anim.brief_pause(0.5)

        with self._anim.progress_bar() as progress:
            task = progress.add_task("Installing packages", total=len(missing))
            for dep in missing:
                progress.update(task, description=f"Installing {dep['pkg']}...")
                rc, _, err = Utility.run_cmd(
                    f"{self._pkg_mgr} install -y {dep['pkg']}", timeout=120
                )
                if rc == 0:
                    self._log.success(f"Installed {dep['pkg']}")
                else:
                    self._log.warning(f"Could not install {dep['pkg']}: {err}")
                progress.advance(task)
                self._anim.brief_pause(0.2)

        return True

    def install_starship(self) -> bool:
        """Attempt to install Starship prompt."""
        if Utility.cmd_exists("starship"):
            self._log.success("Starship is already installed")
            return True
        self._log.info("Attempting to install Starship...")
        rc, _, err = Utility.run_cmd(
            "curl -sS https://starship.rs/install.sh | sh -s -- -y",
            timeout=120,
        )
        if rc == 0 and Utility.cmd_exists("starship"):
            self._log.success("Starship installed successfully")
            return True
        # Fallback: try pkg
        rc2, _, _ = Utility.run_cmd(f"{self._pkg_mgr} install -y starship", timeout=120)
        if rc2 == 0:
            self._log.success("Starship installed via pkg")
            return True
        self._log.warning("Starship not available — using built-in prompt")
        return False


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  BACKUP MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class BackupManager:
    """Creates and manages backups of shell configuration files."""

    def __init__(self, logger: Logger) -> None:
        self._log = logger
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    def create_backup(self) -> Optional[Path]:
        """Create a timestamped backup of all shell config files."""
        ts = Utility.timestamp()
        backup_path = BACKUP_DIR / ts
        backup_path.mkdir(parents=True, exist_ok=True)

        backed_up: list[str] = []
        for fname in SHELL_FILES:
            src = HOME / fname
            if src.exists():
                shutil.copy2(src, backup_path / fname)
                backed_up.append(fname)

        if backed_up:
            manifest = {
                "timestamp": ts,
                "files": backed_up,
                "created_at": datetime.datetime.now().isoformat(),
            }
            Utility.write_file(
                backup_path / "manifest.json", json.dumps(manifest, indent=2)
            )
            self._log.success(f"Backup created: {backup_path}")
            return backup_path
        else:
            self._log.info("No existing shell configs to back up")
            # Still create empty manifest
            manifest = {
                "timestamp": ts,
                "files": [],
                "created_at": datetime.datetime.now().isoformat(),
            }
            Utility.write_file(
                backup_path / "manifest.json", json.dumps(manifest, indent=2)
            )
            return backup_path

    def list_backups(self) -> list[Path]:
        """List all available backups sorted by date descending."""
        if not BACKUP_DIR.exists():
            return []
        backups = sorted(
            [d for d in BACKUP_DIR.iterdir() if d.is_dir()],
            key=lambda p: p.name,
            reverse=True,
        )
        return backups

    def latest_backup(self) -> Optional[Path]:
        """Return the most recent backup directory."""
        backups = self.list_backups()
        return backups[0] if backups else None


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  RESTORE MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class RestoreManager:
    """Restores shell configs from backup."""

    def __init__(self, logger: Logger, backup_mgr: BackupManager) -> None:
        self._log = logger
        self._backup = backup_mgr

    def restore_latest(self) -> bool:
        """Restore from the most recent backup."""
        latest = self._backup.latest_backup()
        if not latest:
            self._log.error("No backups found to restore")
            return False
        return self._restore_from(latest)

    def restore_from(self, backup_path: Path) -> bool:
        """Restore from a specific backup directory."""
        return self._restore_from(backup_path)

    def _restore_from(self, backup_path: Path) -> bool:
        """Internal restore logic."""
        manifest_file = backup_path / "manifest.json"
        if not manifest_file.exists():
            self._log.error(f"No manifest in {backup_path}")
            return False

        try:
            manifest = json.loads(manifest_file.read_text("utf-8"))
        except Exception as e:
            self._log.error(f"Failed to read manifest: {e}")
            return False

        files = manifest.get("files", [])
        restored = 0
        for fname in files:
            src = backup_path / fname
            dst = HOME / fname
            if src.exists():
                shutil.copy2(src, dst)
                restored += 1
                self._log.success(f"Restored {fname}")
            else:
                self._log.warning(f"Backup file missing: {fname}")

        # Also remove hoshi block from any remaining files
        for fname in SHELL_FILES:
            fpath = HOME / fname
            if fpath.exists():
                self._remove_hoshi_block(fpath)

        self._log.success(f"Restored {restored} file(s) from {backup_path.name}")
        return True

    @staticmethod
    def _remove_hoshi_block(filepath: Path) -> None:
        """Remove the HOSHI injection block from a file."""
        content = Utility.read_file(filepath)
        if HOSHI_MARKER_START not in content:
            return
        lines = content.splitlines()
        new_lines: list[str] = []
        inside_block = False
        for line in lines:
            if HOSHI_MARKER_START in line:
                inside_block = True
                continue
            if HOSHI_MARKER_END in line:
                inside_block = False
                continue
            if not inside_block:
                new_lines.append(line)
        Utility.write_file(filepath, "\n".join(new_lines) + "\n")


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  THEME MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class ThemeManager:
    """Manages shell color themes."""

    THEMES: dict[str, dict[str, str]] = {
        "enterprise": {
            "name": "Enterprise",
            "desc": "GitHub / Azure inspired — clean, professional",
            "primary": "cyan",
            "secondary": "blue",
            "accent": "magenta",
            "prompt_user": "38;5;75",
            "prompt_host": "38;5;244",
            "prompt_dir": "38;5;114",
            "prompt_git": "38;5;209",
            "prompt_symbol": "38;5;75",
            "prompt_error": "38;5;203",
        },
        "midnight": {
            "name": "Midnight",
            "desc": "Deep dark blue — inspired by JetBrains / Docker",
            "primary": "blue",
            "secondary": "cyan",
            "accent": "bright_blue",
            "prompt_user": "38;5;111",
            "prompt_host": "38;5;240",
            "prompt_dir": "38;5;150",
            "prompt_git": "38;5;216",
            "prompt_symbol": "38;5;111",
            "prompt_error": "38;5;203",
        },
        "aurora": {
            "name": "Aurora",
            "desc": "Cool purple & green — inspired by Vercel / Cloudflare",
            "primary": "magenta",
            "secondary": "green",
            "accent": "bright_magenta",
            "prompt_user": "38;5;141",
            "prompt_host": "38;5;245",
            "prompt_dir": "38;5;114",
            "prompt_git": "38;5;216",
            "prompt_symbol": "38;5;141",
            "prompt_error": "38;5;203",
        },
        "monochrome": {
            "name": "Monochrome",
            "desc": "Elegant grayscale — ultra-professional",
            "primary": "white",
            "secondary": "bright_black",
            "accent": "white",
            "prompt_user": "38;5;252",
            "prompt_host": "38;5;244",
            "prompt_dir": "38;5;250",
            "prompt_git": "38;5;248",
            "prompt_symbol": "38;5;252",
            "prompt_error": "38;5;203",
        },
        "cloud": {
            "name": "Cloud",
            "desc": "Google Cloud / AWS inspired — warm tones",
            "primary": "yellow",
            "secondary": "blue",
            "accent": "bright_yellow",
            "prompt_user": "38;5;222",
            "prompt_host": "38;5;245",
            "prompt_dir": "38;5;114",
            "prompt_git": "38;5;209",
            "prompt_symbol": "38;5;222",
            "prompt_error": "38;5;203",
        },
    }

    def __init__(self, config_mgr: ConfigManager, logger: Logger) -> None:
        self._config = config_mgr
        self._log = logger

    def get_theme(self, name: str) -> dict[str, str]:
        """Get a theme by name."""
        return self.THEMES.get(name, self.THEMES["enterprise"])

    def list_themes(self) -> dict[str, dict[str, str]]:
        """Return all available themes."""
        return self.THEMES

    def apply_theme(self, name: str) -> bool:
        """Apply a theme to configuration."""
        if name not in self.THEMES:
            self._log.error(f"Theme '{name}' not found")
            return False
        self._config.set("theme", name)
        theme_data = self.THEMES[name]
        self._config.save_theme(
            ThemeConfig(
                name=name,
                primary_color=theme_data["primary"],
                secondary_color=theme_data["secondary"],
                accent_color=theme_data["accent"],
            )
        )
        self._log.success(f"Theme changed to: {theme_data['name']}")
        return True


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  PROMPT MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class PromptManager:
    """Generates shell prompt configuration files."""

    def __init__(self, theme_mgr: ThemeManager, config_mgr: ConfigManager) -> None:
        self._theme_mgr = theme_mgr
        self._config = config_mgr

    def generate_prompt_sh(self, shell: ShellType, theme_name: str = "enterprise") -> str:
        """Generate the prompt.sh content."""
        theme = self._theme_mgr.get_theme(theme_name)
        show_time = self._config.get("show_time_in_prompt", False)

        c_user = theme["prompt_user"]
        c_host = theme["prompt_host"]
        c_dir = theme["prompt_dir"]
        c_git = theme["prompt_git"]
        c_sym = theme["prompt_symbol"]
        c_err = theme["prompt_error"]
        c_reset = "0"

        git_info_func = textwrap.dedent(r'''
        __hoshi_git_info() {
            if ! git rev-parse --is-inside-work-tree &>/dev/null; then
                return
            fi
            local branch
            branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
            local status_flags=""
            local git_status
            git_status=$(git status --porcelain=v1 2>/dev/null)
            if [ -n "$git_status" ]; then
                status_flags=" ●"
            fi
            local ahead behind
            ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
            behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
            if [ "$ahead" -gt 0 ] 2>/dev/null; then
                status_flags="${status_flags} ↑${ahead}"
            fi
            if [ "$behind" -gt 0 ] 2>/dev/null; then
                status_flags="${status_flags} ↓${behind}"
            fi
            if git stash list 2>/dev/null | grep -q .; then
                status_flags="${status_flags} ≡"
            fi
            if [ -d "$(git rev-parse --git-dir)/rebase-merge" ] 2>/dev/null || [ -d "$(git rev-parse --git-dir)/rebase-apply" ] 2>/dev/null; then
                status_flags="${status_flags} ⟳"
            fi
            if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ] 2>/dev/null; then
                status_flags="${status_flags} ⚡"
            fi
            printf " \001\033[%sm\002 %s%s\001\033[0m\002" "''' + c_git + r'''" "$branch" "$status_flags"
        }
        ''').strip()

        venv_func = textwrap.dedent(r'''
        __hoshi_venv() {
            if [ -n "$VIRTUAL_ENV" ]; then
                local venv_name
                venv_name=$(basename "$VIRTUAL_ENV")
                printf " \001\033[38;5;141m\002(%s)\001\033[0m\002" "$venv_name"
            fi
        }
        ''').strip()

        time_segment = ""
        if show_time:
            time_segment = r' \001\033[38;5;240m\002\t\001\033[0m\002'

        # Shorten directory
        dir_func = textwrap.dedent(r'''
        __hoshi_dir() {
            local dir="${PWD/#$HOME/~}"
            printf "%s" "$dir"
        }
        ''').strip()

        if shell == ShellType.ZSH:
            prompt_def = textwrap.dedent(rf'''
            setopt PROMPT_SUBST

            {git_info_func}

            {venv_func}

            {dir_func}

            __hoshi_prompt() {{
                local last_exit=$?
                local symbol_color="\033[{c_sym}m"
                if [ $last_exit -ne 0 ]; then
                    symbol_color="\033[{c_err}m"
                fi
                local root_ind=""
                if [ "$(id -u)" -eq 0 ]; then
                    root_ind=" \033[{c_err}m#\033[0m"
                fi

                local nl=$'\n'
                local line1="\033[{c_user}m%n\033[0m\033[{c_host}m@%m\033[0m \033[{c_dir}m$(__hoshi_dir)\033[0m$(__hoshi_git_info)$(__hoshi_venv)${{root_ind}}{time_segment}"
                local line2="${{symbol_color}}❯\033[0m "

                echo -e "${{line1}}"
                echo -ne "${{line2}}"
            }}

            PROMPT='$(__hoshi_prompt)'
            RPROMPT=''
            ''').strip()
        else:
            # Bash
            prompt_def = textwrap.dedent(rf'''
            {git_info_func}

            {venv_func}

            {dir_func}

            __hoshi_prompt_cmd() {{
                local last_exit=$?
                local symbol_color="\001\033[{c_sym}m\002"
                if [ $last_exit -ne 0 ]; then
                    symbol_color="\001\033[{c_err}m\002"
                fi
                local root_ind=""
                if [ "$(id -u)" -eq 0 ]; then
                    root_ind=" \001\033[{c_err}m\002#\001\033[0m\002"
                fi
                local reset="\001\033[{c_reset}m\002"

                PS1="\001\033[{c_user}m\002\u\001\033[0m\002\001\033[{c_host}m\002@\h\001\033[0m\002 \001\033[{c_dir}m\002$(__hoshi_dir)\001\033[0m\002$(__hoshi_git_info)$(__hoshi_venv)${{root_ind}}{time_segment}\n${{symbol_color}}❯\001\033[0m\002 "
            }}

            PROMPT_COMMAND="__hoshi_prompt_cmd"
            ''').strip()

        return prompt_def

    def write_prompt(self, shell: ShellType, theme_name: str = "enterprise") -> bool:
        """Write the prompt.sh file."""
        content = self.generate_prompt_sh(shell, theme_name)
        return Utility.write_file(PROMPT_SH, content)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ALIAS MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class AliasManager:
    """Generates shell alias configurations."""

    DEFAULT_ALIASES: dict[str, str] = {
        # Navigation & Listing
        "ll": 'eza -la --icons --group-directories-first 2>/dev/null || ls -la --color=auto',
        "la": 'eza -a --icons --group-directories-first 2>/dev/null || ls -a --color=auto',
        "lt": 'eza -la --tree --level=2 --icons 2>/dev/null || find . -maxdepth 2 -type f',
        "l": 'eza -l --icons --group-directories-first 2>/dev/null || ls -l --color=auto',
        # System
        "cls": "clear",
        "reload": 'exec "$SHELL"',
        "update": "pkg update -y && pkg upgrade -y",
        "upgrade": "pkg upgrade -y",
        "clean": "pkg clean && apt autoremove -y 2>/dev/null",
        "path": 'echo "$PATH" | tr ":" "\\n"',
        # Git
        "gs": "git status",
        "gc": "git commit",
        "gp": "git push",
        "gl": "git log --oneline --graph --decorate -15",
        "ga": "git add",
        "gd": "git diff",
        "gb": "git branch",
        "gco": "git checkout",
        "gpl": "git pull",
        "gcl": "git clone",
        # Python
        "py": "python3",
        "pip": "pip3",
        "pipup": "pip3 install --upgrade pip",
        "venv": "python3 -m venv",
        "activate": "source ./venv/bin/activate 2>/dev/null || source ./.venv/bin/activate 2>/dev/null || echo 'No venv found'",
        # Utilities
        "mkdirp": "mkdir -p",
        "h": "history",
        "grep": "grep --color=auto",
        "df": "df -h",
        "du": "du -h",
        "free": "free -h 2>/dev/null || cat /proc/meminfo",
        # Search
        "ff": 'fd --type f 2>/dev/null || find . -type f -name',
        "fdir": 'fd --type d 2>/dev/null || find . -type d -name',
        # Cat replacement
        "cat": "bat --style=auto 2>/dev/null || cat",
        # Hoshi
        "hoshi": f"python3 {Path(__file__).resolve()}",
    }

    def __init__(self, logger: Logger) -> None:
        self._log = logger

    def generate_aliases_sh(self) -> str:
        """Generate aliases.sh content."""
        lines: list[str] = [
            "# ═══ HOSHI Aliases ═══",
            "# Edit this file to customize your aliases",
            "",
        ]
        for alias_name, alias_cmd in self.DEFAULT_ALIASES.items():
            lines.append(f'alias {alias_name}=\'{alias_cmd}\'')
        lines.append("")

        # Extract function
        lines.append(textwrap.dedent(r'''
        # Extract archives
        extract() {
            if [ -f "$1" ]; then
                case "$1" in
                    *.tar.bz2)   tar xjf "$1"   ;;
                    *.tar.gz)    tar xzf "$1"   ;;
                    *.tar.xz)    tar xJf "$1"   ;;
                    *.bz2)       bunzip2 "$1"   ;;
                    *.rar)       unrar x "$1"   ;;
                    *.gz)        gunzip "$1"    ;;
                    *.tar)       tar xf "$1"    ;;
                    *.tbz2)      tar xjf "$1"   ;;
                    *.tgz)       tar xzf "$1"   ;;
                    *.zip)       unzip "$1"     ;;
                    *.Z)         uncompress "$1";;
                    *.7z)        7z x "$1"      ;;
                    *)           echo "'$1' cannot be extracted" ;;
                esac
            else
                echo "'$1' is not a valid file"
            fi
        }
        ''').strip())

        return "\n".join(lines) + "\n"

    def write_aliases(self) -> bool:
        """Write aliases.sh to disk."""
        content = self.generate_aliases_sh()
        return Utility.write_file(ALIASES_SH, content)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  DASHBOARD MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class DashboardManager:
    """Generates the startup dashboard script."""

    def __init__(self) -> None:
        pass

    def generate_dashboard_py(self) -> str:
        """Generate a standalone Python dashboard script for startup."""
        return textwrap.dedent(r'''
#!/usr/bin/env python3
"""HOSHI Startup Dashboard — displayed on every new Termux session."""

import datetime
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

def _run(cmd, timeout=5):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return r.returncode, r.stdout.strip()
    except Exception:
        return -1, ""

def _human(n):
    for u in ("B","KB","MB","GB","TB"):
        if abs(n) < 1024.0: return f"{n:.1f} {u}"
        n /= 1024.0
    return f"{n:.1f} PB"

def main():
    try:
        from rich.console import Console
        from rich.panel import Panel
        from rich.table import Table
        from rich.text import Text
        from rich.columns import Columns
        from rich import box
    except ImportError:
        # Fallback: simple text dashboard
        print(f"\n  ╔══════════════════════════════════╗")
        print(f"  ║        HOSHI Terminal v2.0       ║")
        print(f"  ╚══════════════════════════════════╝\n")
        return

    c = Console()

    now = datetime.datetime.now()

    # Gather info
    username = os.environ.get("USER", "user")
    _, hostname = _run("hostname")
    hostname = hostname or platform.node() or "localhost"
    cwd = os.getcwd()
    py_ver = platform.python_version()
    _, git_ver = _run("git --version")
    git_ver = git_ver.replace("git version ", "") if git_ver else "N/A"
    shell = os.path.basename(os.environ.get("SHELL", "bash"))
    arch = platform.machine()
    kernel = platform.release()
    os_name = "Android" if Path("/system/build.prop").exists() else platform.system()
    _, android_ver = _run("getprop ro.build.version.release")
    os_ver = f"Android {android_ver}" if android_ver else platform.version()

    # CPU
    _, cpu_raw = _run("cat /proc/cpuinfo | grep -m1 'Hardware' | cut -d: -f2")
    cpu = cpu_raw.strip() if cpu_raw else platform.processor() or "N/A"

    # RAM
    _, meminfo = _run("cat /proc/meminfo")
    ram_str = "N/A"
    if meminfo:
        mt = ma = 0
        for line in meminfo.splitlines():
            if line.startswith("MemTotal:"): mt = int(line.split()[1]) * 1024
            elif line.startswith("MemAvailable:"): ma = int(line.split()[1]) * 1024
        mu = mt - ma
        pct = (mu / mt * 100) if mt else 0
        ram_str = f"{_human(mu)} / {_human(mt)} ({pct:.0f}%)"

    # Storage
    try:
        st = os.statvfs(str(Path.home()))
        s_total = st.f_blocks * st.f_frsize
        s_free = st.f_bavail * st.f_frsize
        s_used = s_total - s_free
        s_pct = (s_used / s_total * 100) if s_total else 0
        storage_str = f"{_human(s_used)} / {_human(s_total)} ({s_pct:.0f}%)"
    except Exception:
        storage_str = "N/A"

    # Battery
    bat_str = "N/A"
    rc, bat_raw = _run("cat /sys/class/power_supply/battery/capacity 2>/dev/null")
    if rc == 0 and bat_raw:
        _, bat_status = _run("cat /sys/class/power_supply/battery/status 2>/dev/null")
        bat_str = f"{bat_raw}% ({bat_status})" if bat_status else f"{bat_raw}%"
    else:
        rc2, bat_json = _run("termux-battery-status 2>/dev/null", timeout=8)
        if rc2 == 0 and bat_json:
            try:
                bd = json.loads(bat_json)
                bat_str = f"{bd.get('percentage','?')}% ({bd.get('status','?')})"
            except Exception:
                pass

    # Internet
    rc_net, _ = _run("ping -c1 -W2 8.8.8.8", timeout=5)
    inet = "Connected" if rc_net == 0 else "Disconnected"

    # Banner
    banner_text = Text()
    banner_text.append("  ╻ ╻┏━┓┏━┓╻ ╻╻\n", style="bold cyan")
    banner_text.append("  ┣━┫┃ ┃┗━┓┣━┫┃\n", style="bold cyan")
    banner_text.append("  ╹ ╹┗━┛┗━┛╹ ╹╹\n", style="bold cyan")

    # Load theme config
    theme_name = "Enterprise"
    try:
        tf = Path.home() / ".hoshi" / "theme.json"
        if tf.exists():
            td = json.loads(tf.read_text("utf-8"))
            theme_name = td.get("name", "Enterprise").title()
    except Exception:
        pass

    # Header panel
    header = Text()
    header.append(f"HOSHI Terminal", style="bold bright_white")
    header.append(f"  v2.0.0", style="dim white")
    header.append(f"  ·  {theme_name} Theme", style="dim cyan")
    header.append(f"\n{now.strftime('%A, %B %d %Y  %H:%M:%S')}", style="dim white")

    # System info table
    tbl = Table(
        show_header=False,
        box=box.SIMPLE,
        padding=(0, 2),
        show_edge=False,
        expand=True,
    )
    tbl.add_column("key", style="bold cyan", width=16)
    tbl.add_column("val", style="white")
    tbl.add_column("key2", style="bold cyan", width=16)
    tbl.add_column("val2", style="white")

    rows = [
        ("User", f"{username}@{hostname}", "Shell", shell),
        ("OS", os_ver, "Kernel", kernel),
        ("Arch", arch, "Python", py_ver),
        ("CPU", cpu[:30], "Git", git_ver),
        ("RAM", ram_str, "Storage", storage_str),
        ("Battery", bat_str, "Internet", inet),
        ("Directory", cwd, "Theme", theme_name),
    ]
    for r in rows:
        tbl.add_row(r[0], r[1], r[2], r[3])

    # Build output
    c.print()
    c.print(banner_text, justify="center")
    c.print(
        Panel(
            header,
            border_style="bright_black",
            box=box.ROUNDED,
            padding=(0, 2),
        )
    )
    c.print(
        Panel(
            tbl,
            title="[bold bright_white]System Overview[/]",
            border_style="bright_black",
            box=box.ROUNDED,
            padding=(0, 1),
        )
    )
    c.print(
        "  [dim]Type [bold cyan]hoshi[/bold cyan] to open the installer  ·  "
        "[bold cyan]reload[/bold cyan] to refresh shell[/dim]\n"
    )

if __name__ == "__main__":
    main()
        ''').strip() + "\n"

    def write_dashboard(self) -> bool:
        """Write dashboard.py."""
        content = self.generate_dashboard_py()
        success = Utility.write_file(DASHBOARD_PY, content)
        if success:
            Utility.make_executable(DASHBOARD_PY)
        return success


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  SHELL MANAGER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class ShellManager:
    """Manages shell configuration injection and file generation."""

    def __init__(
        self,
        logger: Logger,
        config_mgr: ConfigManager,
        prompt_mgr: PromptManager,
        alias_mgr: AliasManager,
        dashboard_mgr: DashboardManager,
        theme_mgr: ThemeManager,
    ) -> None:
        self._log = logger
        self._config = config_mgr
        self._prompt = prompt_mgr
        self._alias = alias_mgr
        self._dashboard = dashboard_mgr
        self._theme_mgr = theme_mgr

    def generate_all(self, shell: ShellType, theme_name: str = "enterprise") -> bool:
        """Generate all configuration files."""
        self._log.info("Generating shell configuration files...")

        # Prompt
        self._prompt.write_prompt(shell, theme_name)
        self._log.success("Generated prompt.sh")

        # Aliases
        self._alias.write_aliases()
        self._log.success("Generated aliases.sh")

        # Functions
        self._generate_functions()
        self._log.success("Generated functions.sh")

        # Environment
        self._generate_environment(shell)
        self._log.success("Generated environment.sh")

        # Startup
        self._generate_startup(shell)
        self._log.success("Generated startup.sh")

        # Dashboard
        self._dashboard.write_dashboard()
        self._log.success("Generated dashboard.py")

        # Logo
        self._generate_logo()
        self._log.success("Generated logo.txt")

        return True

    def inject_shell_config(self, shell: ShellType) -> bool:
        """Inject HOSHI sourcing block into the appropriate shell rc file."""
        if shell == ShellType.ZSH:
            rc_files = [".zshrc"]
        else:
            rc_files = [".bashrc"]

        # Also inject into .profile for login shells
        rc_files.append(".profile")

        injection_block = self._build_injection_block(shell)

        for rc_name in rc_files:
            rc_path = HOME / rc_name
            existing = Utility.read_file(rc_path) if rc_path.exists() else ""

            # Remove old block if present
            if HOSHI_MARKER_START in existing:
                lines = existing.splitlines()
                new_lines: list[str] = []
                inside = False
                for line in lines:
                    if HOSHI_MARKER_START in line:
                        inside = True
                        continue
                    if HOSHI_MARKER_END in line:
                        inside = False
                        continue
                    if not inside:
                        new_lines.append(line)
                existing = "\n".join(new_lines)

            # Append injection block
            new_content = existing.rstrip() + "\n\n" + injection_block + "\n"
            Utility.write_file(rc_path, new_content)
            self._log.success(f"Injected HOSHI config into ~/{rc_name}")

        return True

    def _build_injection_block(self, shell: ShellType) -> str:
        """Build the shell injection block."""
        show_dashboard = self._config.get("show_dashboard", True)
        dashboard_cmd = ""
        if show_dashboard:
            dashboard_cmd = f'python3 "{DASHBOARD_PY}" 2>/dev/null'

        block = textwrap.dedent(f"""\
        {HOSHI_MARKER_START}
        # Do not edit this block manually — managed by HOSHI installer
        # https://github.com/hoshi-shell

        # Source HOSHI environment
        [ -f "{ENVIRONMENT_SH}" ] && source "{ENVIRONMENT_SH}"

        # Source HOSHI functions
        [ -f "{FUNCTIONS_SH}" ] && source "{FUNCTIONS_SH}"

        # Source HOSHI aliases
        [ -f "{ALIASES_SH}" ] && source "{ALIASES_SH}"

        # Source HOSHI prompt
        [ -f "{PROMPT_SH}" ] && source "{PROMPT_SH}"

        # Source HOSHI startup
        [ -f "{STARTUP_SH}" ] && source "{STARTUP_SH}"

        # Dashboard
        {dashboard_cmd}

        {HOSHI_MARKER_END}""")
        return block

    def _generate_functions(self) -> None:
        """Generate functions.sh."""
        content = textwrap.dedent(r'''
        # ═══ HOSHI Functions ═══

        # Create directory and cd into it
        mkcd() {
            mkdir -p "$1" && cd "$1"
        }

        # Quick backup a file
        bak() {
            cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
        }

        # Find process
        psg() {
            ps aux | grep -v grep | grep -i "$1"
        }

        # Quick notes
        note() {
            local note_file="$HOME/.hoshi/cache/notes.txt"
            if [ -z "$1" ]; then
                [ -f "$note_file" ] && cat "$note_file" || echo "No notes yet."
            else
                echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$note_file"
                echo "Note saved."
            fi
        }

        # Weather (requires internet)
        weather() {
            curl -s "wttr.in/${1:-}?format=3" 2>/dev/null || echo "No internet"
        }

        # Quick HTTP server
        serve() {
            local port="${1:-8000}"
            echo "Serving on http://localhost:$port"
            python3 -m http.server "$port"
        }

        # IP info
        myip() {
            echo "Local:  $(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)"
            echo "Public: $(curl -s ifconfig.me 2>/dev/null || echo 'N/A')"
        }

        # Color test
        colors() {
            for i in {0..255}; do
                printf "\033[38;5;%sm%3d\033[0m " "$i" "$i"
                [ $(( (i+1) % 16 )) -eq 0 ] && echo
            done
        }
        ''').strip() + "\n"
        Utility.write_file(FUNCTIONS_SH, content)

    def _generate_environment(self, shell: ShellType) -> None:
        """Generate environment.sh."""
        is_zsh = shell == ShellType.ZSH

        history_config: str
        if is_zsh:
            history_config = textwrap.dedent("""\
            # History configuration (Zsh)
            HISTFILE="$HOME/.zsh_history"
            HISTSIZE=50000
            SAVEHIST=50000
            setopt SHARE_HISTORY
            setopt HIST_IGNORE_ALL_DUPS
            setopt HIST_FIND_NO_DUPS
            setopt HIST_REDUCE_BLANKS
            setopt HIST_VERIFY
            setopt EXTENDED_HISTORY
            setopt INC_APPEND_HISTORY
            """)
        else:
            history_config = textwrap.dedent("""\
            # History configuration (Bash)
            HISTFILE="$HOME/.bash_history"
            HISTSIZE=50000
            HISTFILESIZE=50000
            HISTCONTROL=ignoreboth:erasedups
            shopt -s histappend
            PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -n"
            """)

        completion_config: str
        if is_zsh:
            completion_config = textwrap.dedent("""\
            # Completion (Zsh)
            autoload -Uz compinit && compinit -C
            zstyle ':completion:*' menu select
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
            zstyle ':completion:*' group-name ''
            zstyle ':completion:*:descriptions' format '%F{cyan}── %d ──%f'

            # Auto-suggestion & syntax highlighting (if available)
            [ -f "$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
                source "$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
            [ -f "$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
                source "$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
            [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
                source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
            [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
                source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

            # Key bindings
            bindkey '^[[A' history-search-backward
            bindkey '^[[B' history-search-forward
            bindkey '^R' history-incremental-search-backward
            """)
        else:
            completion_config = textwrap.dedent("""\
            # Completion (Bash)
            if [ -f /usr/share/bash-completion/bash_completion ]; then
                source /usr/share/bash-completion/bash_completion
            elif [ -f "$PREFIX/share/bash-completion/bash_completion" ]; then
                source "$PREFIX/share/bash-completion/bash_completion"
            fi

            # Case-insensitive completion
            bind 'set completion-ignore-case on'
            bind 'set show-all-if-ambiguous on'
            bind 'set colored-stats on'

            # History search
            bind '"\e[A": history-search-backward'
            bind '"\e[B": history-search-forward'
            """)

        content = textwrap.dedent(f"""\
        # ═══ HOSHI Environment ═══

        # Locale
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8

        # Editor
        export EDITOR="nano"
        export VISUAL="nano"

        # Colors
        export CLICOLOR=1
        export TERM=xterm-256color

        # ls colors
        export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43"

        # Less
        export LESS="-R"
        export LESSHISTFILE=-

        # FZF
        export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8 --color=info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,spinner:#f5e0dc,header:#f38ba8"
        if command -v fd &>/dev/null; then
            export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
        fi

        # PATH additions
        export PATH="$HOME/.local/bin:$PATH"

        {history_config}
        {completion_config}
        """)

        Utility.write_file(ENVIRONMENT_SH, content)

    def _generate_startup(self, shell: ShellType) -> None:
        """Generate startup.sh — lightweight startup tasks."""
        content = textwrap.dedent("""\
        # ═══ HOSHI Startup ═══
        # This runs on every new shell session

        # Ensure .local/bin exists
        mkdir -p "$HOME/.local/bin" 2>/dev/null

        # Disable default Termux greeting
        : > "$PREFIX/etc/motd" 2>/dev/null
        """)
        Utility.write_file(STARTUP_SH, content)

    def _generate_logo(self) -> None:
        """Generate logo.txt."""
        logo = textwrap.dedent("""\
          ╻ ╻┏━┓┏━┓╻ ╻╻
          ┣━┫┃ ┃┗━┓┣━┫┃
          ╹ ╹┗━┛┗━┛╹ ╹╹
        """)
        Utility.write_file(LOGO_TXT, logo)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  INSTALLER (Main Controller)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


class Installer:
    """Main installer controller — orchestrates all operations."""

    def __init__(self) -> None:
        self.logger = Logger()
        self.animation = AnimationManager()
        self.config = ConfigManager()
        self.system = SystemDetector()
        self.backup = BackupManager(self.logger)
        self.restore = RestoreManager(self.logger, self.backup)
        self.theme = ThemeManager(self.config, self.logger)
        self.prompt = PromptManager(self.theme, self.config)
        self.alias = AliasManager(self.logger)
        self.dashboard = DashboardManager()
        self.deps = DependencyManager(self.logger, self.animation)
        self.shell = ShellManager(
            self.logger, self.config, self.prompt, self.alias, self.dashboard, self.theme
        )
        self._sys_info: Optional[SystemInfo] = None

    # ── UI Helpers ──

    def _header(self) -> None:
        """Print the application header."""
        console.clear()
        logo = Text()
        logo.append("  ╻ ╻┏━┓┏━┓╻ ╻╻\n", style="bold cyan")
        logo.append("  ┣━┫┃ ┃┗━┓┣━┫┃\n", style="bold cyan")
        logo.append("  ╹ ╹┗━┛┗━┛╹ ╹╹\n", style="bold cyan")

        header_text = Text()
        header_text.append(f"  {APP_NAME} ", style="bold bright_white")
        header_text.append(f"v{VERSION}", style="dim white")
        header_text.append(f"  ·  {APP_DESC}", style="dim cyan")

        console.print()
        console.print(logo, justify="center")
        console.print(
            Panel(
                header_text,
                border_style="bright_black",
                box=box.ROUNDED,
                padding=(0, 2),
            )
        )
        console.print()

    def _section(self, title: str) -> None:
        """Print a section header."""
        console.print(Rule(f" {title} ", style="bright_black"))
        console.print()

    def _menu_item(self, num: str, label: str, desc: str = "") -> str:
        """Format a menu item."""
        s = f"  [h.menu_num]{num}[/]  [h.menu_item]{label}[/]"
        if desc:
            s += f"  [h.muted]{desc}[/]"
        return s

    # ── System Detection ──

    def detect_system(self) -> SystemInfo:
        """Detect system and cache result."""
        if self._sys_info is None:
            with self.animation.spinner("Detecting system..."):
                self._sys_info = self.system.detect_all()
                self.animation.brief_pause(0.5)
        return self._sys_info

    def show_system_info(self) -> None:
        """Display detected system information."""
        info = self.detect_system()

        tbl = Table(
            show_header=False,
            box=box.SIMPLE,
            padding=(0, 2),
            show_edge=False,
        )
        tbl.add_column("key", style="bold cyan", width=18)
        tbl.add_column("val", style="white")

        tbl.add_row("Platform", "Termux / Android" if info.is_termux else info.os_name)
        tbl.add_row("OS Version", info.os_version)
        tbl.add_row("Kernel", info.kernel)
        tbl.add_row("Architecture", info.architecture)
        tbl.add_row("Hostname", info.hostname)
        tbl.add_row("Username", info.username)
        tbl.add_row("Shell", info.shell)
        tbl.add_row("Python", info.python_version)
        tbl.add_row("Git", info.git_version)
        tbl.add_row("CPU", info.cpu_info[:50])
        tbl.add_row("RAM", f"{info.ram_used} / {info.ram_total} ({info.ram_percent})")
        tbl.add_row("Storage", f"{info.storage_used} / {info.storage_total} ({info.storage_percent})")
        tbl.add_row("Battery", f"{info.battery_level} ({info.battery_status})")
        tbl.add_row(
            "Internet",
            "[green]Connected[/]" if info.internet else "[red]Disconnected[/]",
        )
        tbl.add_row("Directory", info.current_dir)
        tbl.add_row("Package Mgr", info.package_manager)

        console.print(
            Panel(
                tbl,
                title="[bold bright_white]System Information[/]",
                border_style="bright_black",
                box=box.ROUNDED,
                padding=(0, 1),
            )
        )

    # ── Install ──

    def do_install(self) -> None:
        """Full installation process."""
        self._header()
        self._section("Installation")

        info = self.detect_system()
        self.show_system_info()
        console.print()

        # Confirm
        if not Confirm.ask("  [h.accent]Proceed with installation?[/]", default=True):
            self.logger.info("Installation cancelled")
            return

        console.print()

        # 1. Create directories
        self.logger.info("Creating configuration directories...")
        for d in [HOSHI_DIR, CACHE_DIR, LOGS_DIR, BACKUP_DIR, THEMES_DIR]:
            d.mkdir(parents=True, exist_ok=True)
        self.logger.success("Directories created")

        # 2. Backup existing configs
        self.logger.info("Backing up existing shell configuration...")
        self.backup.create_backup()

        # 3. Check & install dependencies
        console.print()
        self._section("Dependencies")
        dep_status = self.deps.check_all()

        dep_table = Table(
            show_header=True,
            box=box.SIMPLE,
            padding=(0, 2),
            show_edge=False,
        )
        dep_table.add_column("Package", style="white")
        dep_table.add_column("Status", justify="center")

        for d in dep_status:
            status = "[green]✓ Installed[/]" if d["installed"] else "[yellow]○ Missing[/]"
            dep_table.add_row(d["name"], status)

        console.print(
            Panel(
                dep_table,
                title="[bold bright_white]Dependencies[/]",
                border_style="bright_black",
                box=box.ROUNDED,
                padding=(0, 1),
            )
        )
        console.print()

        self.deps.install_missing(dep_status)

        # Try starship (optional)
        self.deps.install_starship()

        # 4. Determine shell
        shell_type = info.shell_type
        self.logger.info(f"Detected shell: {shell_type.value}")

        # 5. Select theme
        theme_name = self.config.get("theme", "enterprise")

        # 6. Generate configuration files
        console.print()
        self._section("Configuration")

        with self.animation.progress_bar() as progress:
            task = progress.add_task("Generating configs", total=8)

            self.config.save(self.config._defaults())
            progress.advance(task)
            self.animation.brief_pause(0.15)

            self.config.save_theme(ThemeConfig(name=theme_name))
            progress.advance(task)
            self.animation.brief_pause(0.15)

            self.config.create_colors_file()
            progress.advance(task)
            self.animation.brief_pause(0.15)

            self.shell.generate_all(shell_type, theme_name)
            progress.advance(task, 4)
            self.animation.brief_pause(0.15)

            self.shell.inject_shell_config(shell_type)
            progress.advance(task)
            self.animation.brief_pause(0.15)

        # Disable default Termux banner
        motd = Path(os.environ.get("PREFIX", "/data/data/com.termux/files/usr")) / "etc" / "motd"
        try:
            motd.write_text("", encoding="utf-8")
        except Exception:
            pass

        # 7. Install zsh plugins if zsh
        if shell_type == ShellType.ZSH:
            self._install_zsh_plugins()

        # 8. Done
        console.print()
        self._section("Complete")
        console.print(
            Panel(
                Text.from_markup(
                    "[h.success]✓ Installation complete![/]\n\n"
                    "[white]Close and reopen Termux to see your new shell.\n"
                    "Or run:[/] [bold cyan]exec $SHELL[/]\n\n"
                    "[dim]Run [bold]hoshi[/bold] anytime to manage your configuration.[/dim]"
                ),
                border_style="green",
                box=box.ROUNDED,
                padding=(1, 3),
            )
        )

    def _install_zsh_plugins(self) -> None:
        """Install zsh-autosuggestions and zsh-syntax-highlighting if available."""
        pkg = "pkg" if Utility.cmd_exists("pkg") else "apt"
        for plugin in ["zsh-autosuggestions", "zsh-syntax-highlighting"]:
            rc, _, _ = Utility.run_cmd(f"{pkg} install -y {plugin}", timeout=60)
            if rc == 0:
                self.logger.success(f"Installed {plugin}")
            else:
                self.logger.warning(f"Could not install {plugin} (optional)")

    # ── Update ──

    def do_update(self) -> None:
        """Update/regenerate all configuration files."""
        self._header()
        self._section("Update Configuration")

        if not HOSHI_DIR.exists():
            self.logger.error("HOSHI is not installed. Please install first.")
            self._wait()
            return

        self.config.load()
        info = self.detect_system()
        theme_name = self.config.get("theme", "enterprise")

        with self.animation.spinner("Regenerating configuration files..."):
            self.shell.generate_all(info.shell_type, theme_name)
            self.shell.inject_shell_config(info.shell_type)
            self.animation.brief_pause(1)

        self.logger.success("Configuration updated successfully")
        console.print("  [dim]Run [bold cyan]exec $SHELL[/bold cyan] to apply changes[/dim]")
        self._wait()

    # ── Backup ──

    def do_backup(self) -> None:
        """Create a new backup."""
        self._header()
        self._section("Backup Configuration")

        with self.animation.spinner("Creating backup..."):
            result = self.backup.create_backup()
            self.animation.brief_pause(0.5)

        if result:
            self.logger.success(f"Backup saved to: {result}")
        else:
            self.logger.error("Backup failed")

        # Show available backups
        console.print()
        backups = self.backup.list_backups()
        if backups:
            tbl = Table(
                show_header=True,
                box=box.SIMPLE,
                show_edge=False,
                padding=(0, 2),
            )
            tbl.add_column("#", style="bold cyan", width=4)
            tbl.add_column("Backup ID", style="white")
            tbl.add_column("Files", style="dim")

            for i, b in enumerate(backups[:10], 1):
                mf = b / "manifest.json"
                fc = "?"
                if mf.exists():
                    try:
                        m = json.loads(mf.read_text("utf-8"))
                        fc = str(len(m.get("files", [])))
                    except Exception:
                        pass
                tbl.add_row(str(i), b.name, f"{fc} files")

            console.print(
                Panel(
                    tbl,
                    title="[bold bright_white]Available Backups[/]",
                    border_style="bright_black",
                    box=box.ROUNDED,
                    padding=(0, 1),
                )
            )

        self._wait()

    # ── Restore ──

    def do_restore(self) -> None:
        """Restore from backup."""
        self._header()
        self._section("Restore Configuration")

        backups = self.backup.list_backups()
        if not backups:
            self.logger.error("No backups found")
            self._wait()
            return

        tbl = Table(
            show_header=True,
            box=box.SIMPLE,
            show_edge=False,
            padding=(0, 2),
        )
        tbl.add_column("#", style="bold cyan", width=4)
        tbl.add_column("Backup ID", style="white")

        for i, b in enumerate(backups[:10], 1):
            tbl.add_row(str(i), b.name)

        console.print(
            Panel(
                tbl,
                title="[bold bright_white]Select Backup[/]",
                border_style="bright_black",
                box=box.ROUNDED,
                padding=(0, 1),
            )
        )

        choice = Prompt.ask(
            "  [h.accent]Select backup number[/]",
            default="1",
        )

        try:
            idx = int(choice) - 1
            if 0 <= idx < len(backups):
                if Confirm.ask(
                    f"  [h.warning]Restore from {backups[idx].name}?[/]",
                    default=False,
                ):
                    self.restore.restore_from(backups[idx])
                    self.logger.success("Restore complete — run 'exec $SHELL' to apply")
            else:
                self.logger.error("Invalid selection")
        except ValueError:
            self.logger.error("Invalid input")

        self._wait()

    # ── Change Theme ──

    def do_change_theme(self) -> None:
        """Interactive theme selector."""
        self._header()
        self._section("Change Theme")

        themes = self.theme.list_themes()

        tbl = Table(
            show_header=True,
            box=box.SIMPLE,
            show_edge=False,
            padding=(0, 2),
        )
        tbl.add_column("#", style="bold cyan", width=4)
        tbl.add_column("Theme", style="white", width=16)
        tbl.add_column("Description", style="dim")

        theme_names = list(themes.keys())
        for i, name in enumerate(theme_names, 1):
            t = themes[name]
            current = " ◄" if name == self.config.get("theme", "enterprise") else ""
            tbl.add_row(str(i), t["name"] + current, t["desc"])

        console.print(
            Panel(
                tbl,
                title="[bold bright_white]Available Themes[/]",
                border_style="bright_black",
                box=box.ROUNDED,
                padding=(0, 1),
            )
        )
        console.print()

        choice = Prompt.ask("  [h.accent]Select theme number[/]", default="1")

        try:
            idx = int(choice) - 1
            if 0 <= idx < len(theme_names):
                selected = theme_names[idx]
                self.theme.apply_theme(selected)

                # Regenerate files with new theme
                info = self.detect_system()
                self.shell.generate_all(info.shell_type, selected)
                self.shell.inject_shell_config(info.shell_type)

                self.logger.success(f"Theme applied: {themes[selected]['name']}")
                console.print("  [dim]Run [bold cyan]exec $SHELL[/bold cyan] to see changes[/dim]")
            else:
                self.logger.error("Invalid selection")
        except ValueError:
            self.logger.error("Invalid input")

        self._wait()

    # ── Settings ──

    def do_settings(self) -> None:
        """Settings menu."""
        while True:
            self._header()
            self._section("Settings")

            self.config.load()

            settings = [
                ("show_dashboard", "Show Dashboard on Startup"),
                ("show_banner", "Show Banner"),
                ("animation", "Enable Animations"),
                ("show_time_in_prompt", "Show Time in Prompt"),
            ]

            tbl = Table(
                show_header=True,
                box=box.SIMPLE,
                show_edge=False,
                padding=(0, 2),
            )
            tbl.add_column("#", style="bold cyan", width=4)
            tbl.add_column("Setting", style="white", width=30)
            tbl.add_column("Value", style="cyan", justify="center")

            for i, (key, label) in enumerate(settings, 1):
                val = self.config.get(key, True)
                val_str = "[green]ON[/]" if val else "[red]OFF[/]"
                tbl.add_row(str(i), label, val_str)

            console.print(
                Panel(
                    tbl,
                    title="[bold bright_white]Current Settings[/]",
                    border_style="bright_black",
                    box=box.ROUNDED,
                    padding=(0, 1),
                )
            )
            console.print()
            console.print(self._menu_item("1-4", "Toggle a setting"))
            console.print(self._menu_item("0", "Back to main menu"))
            console.print()

            choice = Prompt.ask("  [h.accent]Select[/]", default="0")

            if choice == "0":
                break

            try:
                idx = int(choice) - 1
                if 0 <= idx < len(settings):
                    key, label = settings[idx]
                    current = self.config.get(key, True)
                    self.config.set(key, not current)
                    new_val = "ON" if not current else "OFF"
                    self.logger.success(f"{label} → {new_val}")

                    # Regenerate
                    info = self.detect_system()
                    theme_name = self.config.get("theme", "enterprise")
                    self.shell.generate_all(info.shell_type, theme_name)
                    self.shell.inject_shell_config(info.shell_type)

                    self.animation.brief_pause(0.5)
            except (ValueError, IndexError):
                self.logger.error("Invalid input")
                self.animation.brief_pause(0.5)

    # ── Uninstall ──

    def do_uninstall(self) -> None:
        """Uninstall HOSHI completely."""
        self._header()
        self._section("Uninstall")

        console.print(
            Panel(
                "[h.warning]This will remove all HOSHI configurations and restore\n"
                "your shell to its original state from the last backup.[/]",
                border_style="yellow",
                box=box.ROUNDED,
                padding=(1, 3),
            )
        )
        console.print()

        if not Confirm.ask("  [h.error]Are you sure you want to uninstall?[/]", default=False):
            self.logger.info("Uninstall cancelled")
            self._wait()
            return

        # 1. Restore from latest backup
        self.logger.info("Restoring original shell configuration...")
        self.restore.restore_latest()

        # 2. Remove HOSHI blocks from all shell files
        self.logger.info("Cleaning shell configuration files...")
        for fname in SHELL_FILES:
            fpath = HOME / fname
            if fpath.exists():
                RestoreManager._remove_hoshi_block(fpath)

        # 3. Remove HOSHI directory
        self.logger.info("Removing HOSHI directory...")
        try:
            shutil.rmtree(HOSHI_DIR)
            self.logger.success("HOSHI directory removed")
        except Exception as e:
            self.logger.error(f"Could not fully remove directory: {e}")

        # 4. Restore Termux MOTD
        motd = Path(os.environ.get("PREFIX", "/data/data/com.termux/files/usr")) / "etc" / "motd"
        try:
            motd.write_text("Welcome to Termux!\n", encoding="utf-8")
        except Exception:
            pass

        console.print()
        console.print(
            Panel(
                "[h.success]✓ HOSHI has been uninstalled.[/]\n\n"
                "[white]Run [bold cyan]exec $SHELL[/bold cyan] to apply changes.[/white]",
                border_style="green",
                box=box.ROUNDED,
                padding=(1, 3),
            )
        )
        self._wait()

    # ── Main Menu ──

    def _wait(self) -> None:
        """Wait for user to press Enter."""
        console.print()
        Prompt.ask("  [dim]Press Enter to continue[/dim]", default="")

    def main_menu(self) -> None:
        """Display the main interactive menu."""
        # Load config if exists
        if CONFIG_FILE.exists():
            self.config.load()

        while True:
            self._header()

            # Check installation status
            installed = HOSHI_DIR.exists() and CONFIG_FILE.exists()
            status = "[green]● Installed[/]" if installed else "[yellow]○ Not Installed[/]"

            console.print(f"  Status: {status}")
            console.print()

            menu_items = [
                ("1", "Install", "Full installation / reinstall"),
                ("2", "Update", "Regenerate all configuration files"),
                ("3", "Backup", "Create a backup of current config"),
                ("4", "Restore", "Restore from a previous backup"),
                ("5", "Theme", "Change color theme"),
                ("6", "Settings", "Adjust preferences"),
                ("7", "System Info", "View detected system info"),
                ("8", "Uninstall", "Remove HOSHI completely"),
                ("0", "Exit", ""),
            ]

            for num, label, desc in menu_items:
                console.print(self._menu_item(num, label, desc))

            console.print()
            choice = Prompt.ask("  [h.accent]Select an option[/]", default="0")

            try:
                match choice:
                    case "1":
                        self.do_install()
                    case "2":
                        self.do_update()
                    case "3":
                        self.do_backup()
                    case "4":
                        self.do_restore()
                    case "5":
                        self.do_change_theme()
                    case "6":
                        self.do_settings()
                    case "7":
                        self._header()
                        self._section("System Information")
                        self.show_system_info()
                        self._wait()
                    case "8":
                        self.do_uninstall()
                    case "0" | "q" | "exit":
                        console.print()
                        console.print("  [dim]Goodbye.[/dim]")
                        console.print()
                        sys.exit(0)
                    case _:
                        self.logger.warning("Invalid option")
                        self.animation.brief_pause(0.5)
            except KeyboardInterrupt:
                console.print()
                console.print("  [dim]Interrupted.[/dim]")
                console.print()
                sys.exit(0)
            except Exception as e:
                ErrorHandler.handle(e, context="Main menu")
                self._wait()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ENTRY POINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


def main() -> None:
    """Entry point for the HOSHI installer."""
    # Handle Ctrl+C gracefully
    signal.signal(signal.SIGINT, lambda s, f: (console.print("\n  [dim]Interrupted.[/dim]\n"), sys.exit(0)))

    # Python version check
    if sys.version_info < (3, 10):
        console.print(
            f"[h.error]Python 3.10+ is required. Current: {platform.python_version()}[/]"
        )
        sys.exit(1)

    installer = Installer()
    installer.main_menu()


if __name__ == "__main__":
    main()