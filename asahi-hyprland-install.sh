#!/bin/bash

# Hyprland Installation Script for Asahi Linux (Fedora Remix) - MacBook M1 Air
# Optimized for Apple Silicon with Czech keyboard support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Check if running on Fedora (Asahi Linux)
if ! command -v dnf &> /dev/null; then
    error "This script is designed for Fedora-based systems (Asahi Linux)"
fi

# Check if running on Apple Silicon
if ! uname -m | grep -q "aarch64"; then
    warn "This script is optimized for Apple Silicon (aarch64) but will continue"
fi

log "Starting Asahi Linux Hyprland installation for MacBook M1 Air..."

# Complete cleanup of existing Hyprland installation
log "Performing complete cleanup of existing Hyprland installation..."

# Stop any running Hyprland session (safer approach)
if pgrep -f hyprland >/dev/null 2>&1; then
    log "Found running Hyprland processes, attempting to stop them..."
    pkill -f hyprland 2>/dev/null || true
    sleep 2
fi
if pgrep -f Hyprland >/dev/null 2>&1; then
    log "Found running Hyprland processes, attempting to stop them..."
    pkill -f Hyprland 2>/dev/null || true
    sleep 2
fi

# Remove existing configurations
if [ -d ~/.config/hypr ]; then
    log "Backing up existing Hyprland config..."
    mv ~/.config/hypr ~/.config/hypr.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi

if [ -d ~/.config/waybar ]; then
    log "Backing up existing Waybar config..."
    mv ~/.config/waybar ~/.config/waybar.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi

if [ -d ~/.config/rofi ]; then
    log "Backing up existing Rofi config..."
    mv ~/.config/rofi ~/.config/rofi.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi

if [ -d ~/.config/alacritty ]; then
    log "Backing up existing Alacritty config..."
    mv ~/.config/alacritty ~/.config/alacritty.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi

# Remove old packages (if installed)
log "Removing old Hyprland packages..."
sudo dnf remove -y hyprland waybar wofi kitty 2>/dev/null || true

# Update system
log "Updating system packages..."
sudo dnf update -y

# Enable RPM Fusion repositories (needed for some packages)
log "Enabling RPM Fusion repositories..."
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || true
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 2>/dev/null || true

# Install COPR repository for Hyprland
log "Adding Hyprland COPR repository..."
sudo dnf copr enable -y solopasha/hyprland

# Install Hyprland and core dependencies
log "Installing Hyprland and core dependencies..."
sudo dnf install -y \
    hyprland \
    xdg-desktop-portal-hyprland \
    qt5-qtwayland \
    qt6-qtwayland \
    waybar \
    rofi-wayland \
    alacritty \
    thunar \
    grim \
    slurp \
    wl-clipboard \
    mako \
    swww \
    polkit-gnome

# Install PipeWire audio system
log "Installing PipeWire audio system..."
sudo dnf install -y \
    pipewire \
    pipewire-alsa \
    pipewire-pulseaudio \
    pipewire-jack-audio-connection-kit \
    wireplumber \
    pavucontrol \
    playerctl

# Install additional useful packages for MacBook
log "Installing additional packages optimized for MacBook..."
sudo dnf install -y \
    brightnessctl \
    network-manager-applet \
    blueman \
    firefox \
    file-roller \
    gnome-disk-utility \
    htop \
    neofetch \
    ranger \
    tree \
    vim \
    git \
    curl \
    wget

# Install fonts for better experience
log "Installing fonts..."
sudo dnf install -y \
    google-noto-fonts \
    google-noto-emoji-fonts \
    google-noto-sans-cjk-fonts \
    google-noto-serif-cjk-fonts \
    jetbrains-mono-fonts \
    liberation-fonts \
    dejavu-fonts-common

# Enable system services
log "Enabling system services..."
sudo systemctl enable bluetooth
sudo systemctl enable NetworkManager

# Start services immediately
sudo systemctl start bluetooth
sudo systemctl start NetworkManager

# Create Hyprland configuration directory
log "Setting up Hyprland configuration..."
mkdir -p ~/.config/hypr

# Create optimized Hyprland configuration for MacBook M1 Air
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Hyprland Configuration for MacBook M1 Air (Asahi Linux)
# Optimized for Apple Silicon with Czech keyboard support

# Monitor configuration (MacBook Air 13" default)
monitor=,preferred,auto,1

# MacBook-specific environment variables
env = XCURSOR_SIZE,24
env = WLR_NO_HARDWARE_CURSORS,1
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = XDG_CURRENT_DESKTOP,Hyprland

# Execute apps at launch
exec-once = waybar
exec-once = mako
exec-once = swww init
exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = blueman-applet

# Input configuration optimized for MacBook
input {
    kb_layout = us,cz
    kb_variant = ,qwerty
    kb_options = grp:alt_shift_toggle,caps:escape
    follow_mouse = 1
    
    # MacBook trackpad configuration
    touchpad {
        natural_scroll = yes
        tap-to-click = yes
        drag_lock = yes
        disable_while_typing = yes
        scroll_factor = 0.5
        middle_button_emulation = yes
        tap-and-drag = yes
    }
    
    # Sensitivity optimized for MacBook trackpad
    sensitivity = 0.2
    accel_profile = adaptive
}

# General settings optimized for MacBook display
general {
    gaps_in = 8
    gaps_out = 16
    border_size = 2
    col.active_border = rgba(007accff) rgba(00d4aaff) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    allow_tearing = false
}

# Decoration settings for MacBook Retina display
decoration {
    rounding = 12
    
    blur {
        enabled = true
        size = 6
        passes = 2
        new_optimizations = true
        xray = true
        ignore_opacity = true
    }
    
    drop_shadow = yes
    shadow_range = 8
    shadow_render_power = 2
    col.shadow = rgba(1a1a1a80)
    shadow_offset = 2 2
    
    # Dim inactive windows slightly
    dim_inactive = true
    dim_strength = 0.1
}

# Animation settings optimized for Apple Silicon performance
animations {
    enabled = yes
    
    bezier = macOS, 0.32, 0.97, 0.53, 1.00
    bezier = overshot, 0.13, 0.99, 0.29, 1.1
    
    animation = windows, 1, 4, macOS, slide
    animation = windowsOut, 1, 4, macOS, slide
    animation = border, 1, 8, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 4, macOS
    animation = workspaces, 1, 4, overshot, slidevert
}

# Layout settings
dwindle {
    pseudotile = yes
    preserve_split = yes
    smart_split = true
    smart_resizing = true
}

master {
    new_is_master = false
    new_on_top = true
    mfact = 0.5
}

# Gestures (important for MacBook trackpad)
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 200
    workspace_swipe_invert = false
    workspace_swipe_min_speed_to_force = 15
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = false
}

# MacBook-specific device settings
device:apple-spi-keyboard {
    kb_layout = us,cz
    kb_variant = ,qwerty
    kb_options = grp:alt_shift_toggle,caps:escape
}

device:apple-spi-trackpad {
    natural_scroll = yes
    tap-to-click = yes
    drag_lock = yes
    disable_while_typing = yes
}

# Key bindings optimized for MacBook
$mainMod = SUPER
$altMod = ALT

# Application shortcuts
bind = $mainMod, Return, exec, alacritty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, Q, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, Space, exec, rofi -show drun -theme ~/.config/rofi/macOS.rasi
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen, 0
bind = $mainMod SHIFT, F, fullscreen, 1

# Move focus with mainMod + vim keys
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows with mainMod + SHIFT + vim keys
bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, L, movewindow, r
bind = $mainMod SHIFT, K, movewindow, u
bind = $mainMod SHIFT, J, movewindow, d

# Resize windows with mainMod + ALT + vim keys
bind = $mainMod $altMod, H, resizeactive, -20 0
bind = $mainMod $altMod, L, resizeactive, 20 0
bind = $mainMod $altMod, K, resizeactive, 0 -20
bind = $mainMod $altMod, J, resizeactive, 0 20

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Screenshot bindings
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Selection copied to clipboard"
bind = $mainMod SHIFT, 3, exec, grim - | wl-copy && notify-send "Screenshot" "Screen copied to clipboard"
bind = $mainMod SHIFT, 4, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot" "Selection saved to Pictures"

# MacBook function keys
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)"
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)"
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle && notify-send "Volume" "Muted: $(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2)"

# MacBook brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness" "$(brightnessctl get)%"
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%- && notify-send "Brightness" "$(brightnessctl get)%"

# Media controls
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Czech keyboard layout toggle
bind = $mainMod, I, exec, hyprctl switchxkblayout apple-spi-keyboard next && notify-send "Keyboard" "Layout switched"

# Special workspace for floating windows
bind = $mainMod SHIFT, grave, movetoworkspace, special
bind = $mainMod, grave, togglespecialworkspace,

# Window rules for better MacBook experience
windowrule = float, ^(pavucontrol)$
windowrule = float, ^(blueman-manager)$
windowrule = float, ^(nm-connection-editor)$
windowrule = float, ^(gnome-calculator)$
windowrule = size 800 600, ^(pavucontrol)$

# Opacity rules
windowrule = opacity 0.9, ^(alacritty)$
windowrule = opacity 0.9, ^(thunar)$

# Workspace rules
workspace = 1, monitor:, default:true
workspace = 2, monitor:
workspace = 3, monitor:
workspace = 4, monitor:
workspace = 5, monitor:
workspace = 6, monitor:
workspace = 7, monitor:
workspace = 8, monitor:
workspace = 9, monitor:
workspace = 10, monitor:
EOF

# Create Waybar configuration for MacBook
log "Setting up Waybar configuration..."
mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 8,
    "margin-top": 8,
    "margin-left": 16,
    "margin-right": 16,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["keyboard-state", "pulseaudio", "network", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬",
            "urgent": "",
            "focused": "",
            "default": ""
        },
        "persistent_workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": []
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true
    },
    
    "keyboard-state": {
        "numlock": false,
        "capslock": true,
        "format": {
            "numlock": "N {icon}",
            "capslock": "󰪛 {icon}"
        },
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "timezone": "Europe/Prague",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% 󰂄",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) 󰖩",
        "format-ethernet": "{ipaddr}/{cidr} 󰈀",
        "tooltip-format": "{ifname} via {gwaddr} 󰊗",
        "format-linked": "{ifname} (No IP) 󰈀",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "on-click-right": "nm-connection-editor"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol",
        "on-click-right": "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", "SF Pro Display", monospace;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.8);
    border-radius: 16px;
    color: #cdd6f4;
    transition-property: background-color;
    transition-duration: .5s;
    backdrop-filter: blur(20px);
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 8px;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: #6c7086;
    transition: all 0.3s ease;
}

#workspaces button:hover {
    background: rgba(116, 199, 236, 0.2);
    color: #74c7ec;
}

#workspaces button.active {
    background-color: #74c7ec;
    color: #1e1e2e;
    font-weight: bold;
}

#workspaces button.urgent {
    background-color: #f38ba8;
    color: #1e1e2e;
}

#window {
    margin: 0 4px;
    padding: 0 8px;
    color: #a6adc8;
    font-weight: 500;
}

#clock,
#battery,
#network,
#pulseaudio,
#tray,
#keyboard-state {
    padding: 0 12px;
    color: #cdd6f4;
    border-radius: 8px;
    margin: 0 2px;
}

#clock {
    background-color: rgba(116, 199, 236, 0.1);
    color: #74c7ec;
    font-weight: bold;
}

#battery {
    background-color: rgba(166, 227, 161, 0.1);
    color: #a6e3a1;
}

#battery.charging, #battery.plugged {
    background-color: rgba(166, 227, 161, 0.2);
}

#battery.critical:not(.charging) {
    background-color: rgba(243, 139, 168, 0.2);
    color: #f38ba8;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#network {
    background-color: rgba(203, 166, 247, 0.1);
    color: #cba6f7;
}

#pulseaudio {
    background-color: rgba(250, 179, 135, 0.1);
    color: #fab387;
}

#keyboard-state {
    background-color: rgba(245, 194, 231, 0.1);
    color: #f5c2e7;
    font-size: 11px;
}

#tray {
    background-color: rgba(88, 91, 112, 0.1);
}

@keyframes blink {
    to {
        background-color: rgba(243, 139, 168, 0.5);
        color: #f38ba8;
    }
}

tooltip {
    background: rgba(30, 30, 46, 0.9);
    border-radius: 8px;
    border: 1px solid rgba(116, 199, 236, 0.3);
}
EOF

# Create Rofi configuration with macOS-like theme
log "Setting up Rofi configuration..."
mkdir -p ~/.config/rofi

cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    terminal: "alacritty";
    drun-display-format: "{name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "   Apps ";
    display-run: "   Run ";
    display-window: " 﩯  Window";
    display-Network: " 󰤨  Network";
    sidebar-mode: true;
}

@theme "macOS"
EOF

cat > ~/.config/rofi/macOS.rasi << 'EOF'
* {
    bg-col:  #1e1e2e;
    bg-col-light: #313244;
    border-col: #74c7ec;
    selected-col: #74c7ec;
    blue: #74c7ec;
    fg-col: #cdd6f4;
    fg-col2: #f38ba8;
    grey: #6c7086;

    width: 600;
    font: "SF Pro Display 14";
}

element-text, element-icon , mode-switcher {
    background-color: inherit;
    text-color:       inherit;
}

window {
    height: 360px;
    border: 2px;
    border-color: @border-col;
    background-color: @bg-col;
    border-radius: 16px;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col;
    border-radius: 8px;
    padding: 2px;
}

prompt {
    background-color: @blue;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 6px;
    margin: 20px 0px 0px 20px;
}

textbox-prompt-colon {
    expand: false;
    str: ":";
}

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px 0px 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 1;
    lines: 5;
    background-color: @bg-col;
}

element {
    padding: 8px;
    background-color: @bg-col;
    text-color: @fg-col;
    border-radius: 8px;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @bg-col;
}

mode-switcher {
    spacing: 0;
}

button {
    padding: 10px;
    background-color: @bg-col-light;
    text-color: @grey;
    vertical-align: 0.5;
    horizontal-align: 0.5;
}

button selected {
    background-color: @bg-col;
    text-color: @blue;
}

message {
    background-color: @bg-col-light;
    margin: 2px;
    padding: 2px;
    border-radius: 8px;
}

textbox {
    padding: 6px;
    margin: 20px 0px 0px 20px;
    text-color: @blue;
    background-color: @bg-col-light;
}
EOF

# Create Alacritty configuration
log "Setting up Alacritty configuration..."
mkdir -p ~/.config/alacritty

cat > ~/.config/alacritty/alacritty.yml << 'EOF'
# Alacritty Configuration for MacBook M1 Air

window:
  padding:
    x: 12
    y: 12
  dynamic_padding: false
  decorations: buttonless
  opacity: 0.9
  startup_mode: Windowed
  title: Alacritty
  dynamic_title: true

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: JetBrains Mono
    style: Regular
  bold:
    family: JetBrains Mono
    style: Bold
  italic:
    family: JetBrains Mono
    style: Italic
  bold_italic:
    family: JetBrains Mono
    style: Bold Italic
  size: 14.0
  offset:
    x: 0
    y: 0
  glyph_offset:
    x: 0
    y: 0

draw_bold_text_with_bright_colors: false

# Catppuccin Mocha theme
colors:
  primary:
    background: '#1e1e2e'
    foreground: '#cdd6f4'
    dim_foreground: '#7f849c'
    bright_foreground: '#cdd6f4'

  cursor:
    text: '#1e1e2e'
    cursor: '#f5e0dc'

  vi_mode_cursor:
    text: '#1e1e2e'
    cursor: '#b4befe'

  search:
    matches:
      foreground: '#1e1e2e'
      background: '#a6adc8'
    focused_match:
      foreground: '#1e1e2e'
      background: '#a6e3a1'
    footer_bar:
      foreground: '#1e1e2e'
      background: '#a6adc8'

  hints:
    start:
      foreground: '#1e1e2e'
      background: '#f9e2af'
    end:
      foreground: '#1e1e2e'
      background: '#a6adc8'

  selection:
    text: '#1e1e2e'
    background: '#f5e0dc'

  normal:
    black: '#45475a'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#bac2de'

  bright:
    black: '#585b70'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#a6adc8'

  dim:
    black: '#45475a'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#bac2de'

  indexed_colors:
    - { index: 16, color: '#fab387' }
    - { index: 17, color: '#f5e0dc' }

bell:
  animation: EaseOutExpo
  duration: 0
  color: '#ffffff'

selection:
  semantic_escape_chars: ",│`|:\"' ()[]{}<>\t"
  save_to_clipboard: true

cursor:
  style:
    shape: Block
    blinking: On
  vi_mode_style: None
  blink_interval: 750
  unfocused_hollow: true
  thickness: 0.15

live_config_reload: true

shell:
  program: /bin/bash
  args:
    - --login

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }
  hide_when_typing: false

hints:
  alphabet: "jfkdls;ahgurieowpq"
  enabled:
   - regex: "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001f\u007f-\u009f<>\"\\s{-}\\^⟨⟩`]+"
     command: open
     post_processing: true
     mouse:
       enabled: true
       mods: None
     binding:
       key: U
       mods: Control|Shift

key_bindings:
  # MacBook-style bindings
  - { key: A,         mods: Command,       action: SelectAll                    }
  - { key: C,         mods: Command,       action: Copy                         }
  - { key: V,         mods: Command,       action: Paste                        }
  - { key: Q,         mods: Command,       action: Quit                         }
  - { key: W,         mods: Command,       action: Quit                         }
  - { key: N,         mods: Command,       action: SpawnNewInstance             }
  
  # Font size
  - { key: Key0,      mods: Command,       action: ResetFontSize                }
  - { key: Equals,    mods: Command,       action: IncreaseFontSize             }
  - { key: Plus,      mods: Command,       action: IncreaseFontSize             }
  - { key: Minus,     mods: Command,       action: DecreaseFontSize             }
  
  # Navigation
  - { key: Left,      mods: Command,       chars: "\x01"                        }
  - { key: Right,     mods: Command,       chars: "\x05"                        }
  - { key: Left,      mods: Alt,           chars: "\x1bb"                       }
  - { key: Right,     mods: Alt,           chars: "\x1bf"                       }
EOF

# Create screenshots directory
log "Creating screenshots directory..."
mkdir -p ~/Pictures/Screenshots

# Create desktop entry for Hyprland
log "Creating desktop entry for Hyprland..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Set up Czech keyboard layout system-wide
log "Configuring Czech keyboard layout..."
sudo localectl set-x11-keymap us,cz pc105 ,qwerty grp:alt_shift_toggle,caps:escape

# Create a simple startup script
log "Creating startup script..."
cat > ~/.config/hypr/startup.sh << 'EOF'
#!/bin/bash

# MacBook-specific startup optimizations
echo "Starting Hyprland session for MacBook M1 Air..."

# Set keyboard layout
hyprctl keyword input:kb_layout "us,cz"
hyprctl keyword input:kb_variant ",qwerty"
hyprctl keyword input:kb_options "grp:alt_shift_toggle,caps:escape"

# Set trackpad settings
hyprctl keyword input:touchpad:natural_scroll true
hyprctl keyword input:touchpad:tap-to-click true
hyprctl keyword input:touchpad:drag_lock true

# Optimize for battery life
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true

echo "Hyprland startup complete!"
EOF

chmod +x ~/.config/hypr/startup.sh

success "Installation completed successfully!"
echo ""
echo -e "${GREEN}🍎 MacBook M1 Air Hyprland Setup Complete! 🍎${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Reboot your system"
echo "2. Log out and select Hyprland from your display manager"
echo "3. The system will automatically configure for your MacBook"
echo ""
echo -e "${YELLOW}Key bindings (MacBook optimized):${NC}"
echo "Super+Return: Terminal (Alacritty)"
echo "Super+Q: Close window"
echo "Super+Shift+Q: Exit Hyprland"
echo "Super+E: File manager"
echo "Super+Space: Application launcher (Rofi)"
echo "Super+I: Switch keyboard layout (US ⟷ Czech)"
echo "Super+H/J/K/L: Move focus (vim-style)"
echo "Super+Shift+H/J/K/L: Move windows"
echo "Super+Alt+H/J/K/L: Resize windows"
echo "Super+1-0: Switch workspaces"
echo "Super+Shift+1-0: Move window to workspace"
echo "Super+Shift+S: Screenshot selection"
echo "Super+Shift+3: Screenshot full screen"
echo "3-finger swipe: Switch workspaces"
echo ""
echo -e "${PURPLE}MacBook-specific features:${NC}"
echo "✓ Czech keyboard layout (Alt+Shift to switch)"
echo "✓ Optimized trackpad settings"
echo "✓ Function keys for brightness/volume"
echo "✓ macOS-like animations and blur effects"
echo "✓ Retina display optimizations"
echo "✓ Power management optimizations"
echo ""
echo -e "${BLUE}Configuration files created:${NC}"
echo "~/.config/hypr/hyprland.conf"
echo "~/.config/waybar/config"
echo "~/.config/rofi/config.rasi"
echo "~/.config/alacritty/alacritty.yml"
echo ""
echo -e "${GREEN}Enjoy your new Hyprland setup on MacBook M1 Air! 🚀${NC}"
    drop_shadow = yes
    shadow_range = 8
    shadow_render_power = 2
    col.shadow = rgba(1a1a1a80)
    shadow_offset = 2 2
    
    # Dim inactive windows slightly
    dim_inactive = true
    dim_strength = 0.1
}

# Animation settings optimized for Apple Silicon performance
animations {
    enabled = yes
    
    bezier = macOS, 0.32, 0.97, 0.53, 1.00
    bezier = overshot, 0.13, 0.99, 0.29, 1.1
    
    animation = windows, 1, 4, macOS, slide
    animation = windowsOut, 1, 4, macOS, slide
    animation = border, 1, 8, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 4, macOS
    animation = workspaces, 1, 4, overshot, slidevert
}

# Layout settings
dwindle {
    pseudotile = yes
    preserve_split = yes
    smart_split = true
    smart_resizing = true
}

master {
    new_is_master = false
    new_on_top = true
    mfact = 0.5
}

# Gestures (important for MacBook trackpad)
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 200
    workspace_swipe_invert = false
    workspace_swipe_min_speed_to_force = 15
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = false
}

# MacBook-specific device settings
device:apple-spi-keyboard {
    kb_layout = us,cz
    kb_variant = ,qwerty
    kb_options = grp:alt_shift_toggle,caps:escape
}

device:apple-spi-trackpad {
    natural_scroll = yes
    tap-to-click = yes
    drag_lock = yes
    disable_while_typing = yes
}

# Key bindings optimized for MacBook
$mainMod = SUPER
$altMod = ALT

# Application shortcuts
bind = $mainMod, Return, exec, alacritty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, Q, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, Space, exec, rofi -show drun -theme ~/.config/rofi/macOS.rasi
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen, 0
bind = $mainMod SHIFT, F, fullscreen, 1

# Move focus with mainMod + vim keys
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows with mainMod + SHIFT + vim keys
bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, L, movewindow, r
bind = $mainMod SHIFT, K, movewindow, u
bind = $mainMod SHIFT, J, movewindow, d

# Resize windows with mainMod + ALT + vim keys
bind = $mainMod $altMod, H, resizeactive, -20 0
bind = $mainMod $altMod, L, resizeactive, 20 0
bind = $mainMod $altMod, K, resizeactive, 0 -20
bind = $mainMod $altMod, J, resizeactive, 0 20

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Screenshot bindings
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Selection copied to clipboard"
bind = $mainMod SHIFT, 3, exec, grim - | wl-copy && notify-send "Screenshot" "Screen copied to clipboard"
bind = $mainMod SHIFT, 4, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot" "Selection saved to Pictures"

# MacBook function keys
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)"
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)"
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle && notify-send "Volume" "Muted: $(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2)"

# MacBook brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness" "$(brightnessctl get)%"
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%- && notify-send "Brightness" "$(brightnessctl get)%"

# Media controls
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Czech keyboard layout toggle
bind = $mainMod, I, exec, hyprctl switchxkblayout apple-spi-keyboard next && notify-send "Keyboard" "Layout switched"

# Special workspace for floating windows
bind = $mainMod SHIFT, grave, movetoworkspace, special
bind = $mainMod, grave, togglespecialworkspace,

# Window rules for better MacBook experience
windowrule = float, ^(pavucontrol)$
windowrule = float, ^(blueman-manager)$
windowrule = float, ^(nm-connection-editor)$
windowrule = float, ^(gnome-calculator)$
windowrule = size 800 600, ^(pavucontrol)$

# Opacity rules
windowrule = opacity 0.9, ^(alacritty)$
windowrule = opacity 0.9, ^(thunar)$

# Workspace rules
workspace = 1, monitor:, default:true
workspace = 2, monitor:
workspace = 3, monitor:
workspace = 4, monitor:
workspace = 5, monitor:
workspace = 6, monitor:
workspace = 7, monitor:
workspace = 8, monitor:
workspace = 9, monitor:
workspace = 10, monitor:
EOF

# Create Waybar configuration for MacBook
log "Setting up Waybar configuration..."
mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 8,
    "margin-top": 8,
    "margin-left": 16,
    "margin-right": 16,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["keyboard-state", "pulseaudio", "network", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬",
            "urgent": "",
            "focused": "",
            "default": ""
        },
        "persistent_workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": []
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true
    },
    
    "keyboard-state": {
        "numlock": false,
        "capslock": true,
        "format": {
            "numlock": "N {icon}",
            "capslock": "󰪛 {icon}"
        },
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "timezone": "Europe/Prague",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% 󰂄",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) 󰖩",
        "format-ethernet": "{ipaddr}/{cidr} 󰈀",
        "tooltip-format": "{ifname} via {gwaddr} 󰊗",
        "format-linked": "{ifname} (No IP) 󰈀",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "on-click-right": "nm-connection-editor"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol",
        "on-click-right": "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", "SF Pro Display", monospace;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(30, 30, 46, 0.8);
    border-radius: 16px;
    color: #cdd6f4;
    transition-property: background-color;
    transition-duration: .5s;
    backdrop-filter: blur(20px);
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 8px;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: #6c7086;
    transition: all 0.3s ease;
}

#workspaces button:hover {
    background: rgba(116, 199, 236, 0.2);
    color: #74c7ec;
}

#workspaces button.active {
    background-color: #74c7ec;
    color: #1e1e2e;
    font-weight: bold;
}

#workspaces button.urgent {
    background-color: #f38ba8;
    color: #1e1e2e;
}

#window {
    margin: 0 4px;
    padding: 0 8px;
    color: #a6adc8;
    font-weight: 500;
}

#clock,
#battery,
#network,
#pulseaudio,
#tray,
#keyboard-state {
    padding: 0 12px;
    color: #cdd6f4;
    border-radius: 8px;
    margin: 0 2px;
}

#clock {
    background-color: rgba(116, 199, 236, 0.1);
    color: #74c7ec;
    font-weight: bold;
}

#battery {
    background-color: rgba(166, 227, 161, 0.1);
    color: #a6e3a1;
}

#battery.charging, #battery.plugged {
    background-color: rgba(166, 227, 161, 0.2);
}

#battery.critical:not(.charging) {
    background-color: rgba(243, 139, 168, 0.2);
    color: #f38ba8;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#network {
    background-color: rgba(203, 166, 247, 0.1);
    color: #cba6f7;
}

#pulseaudio {
    background-color: rgba(250, 179, 135, 0.1);
    color: #fab387;
}

#keyboard-state {
    background-color: rgba(245, 194, 231, 0.1);
    color: #f5c2e7;
    font-size: 11px;
}

#tray {
    background-color: rgba(88, 91, 112, 0.1);
}

@keyframes blink {
    to {
        background-color: rgba(243, 139, 168, 0.5);
        color: #f38ba8;
    }
}

tooltip {
    background: rgba(30, 30, 46, 0.9);
    border-radius: 8px;
    border: 1px solid rgba(116, 199, 236, 0.3);
}
EOF

# Create Rofi configuration with macOS-like theme
log "Setting up Rofi configuration..."
mkdir -p ~/.config/rofi

cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    terminal: "alacritty";
    drun-display-format: "{name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "   Apps ";
    display-run: "   Run ";
    display-window: " 﩯  Window";
    display-Network: " 󰤨  Network";
    sidebar-mode: true;
}

@theme "macOS"
EOF

cat > ~/.config/rofi/macOS.rasi << 'EOF'
* {
    bg-col:  #1e1e2e;
    bg-col-light: #313244;
    border-col: #74c7ec;
    selected-col: #74c7ec;
    blue: #74c7ec;
    fg-col: #cdd6f4;
    fg-col2: #f38ba8;
    grey: #6c7086;

    width: 600;
    font: "SF Pro Display 14";
}

element-text, element-icon , mode-switcher {
    background-color: inherit;
    text-color:       inherit;
}

window {
    height: 360px;
    border: 2px;
    border-color: @border-col;
    background-color: @bg-col;
    border-radius: 16px;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col;
    border-radius: 8px;
    padding: 2px;
}

prompt {
    background-color: @blue;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 6px;
    margin: 20px 0px 0px 20px;
}

textbox-prompt-colon {
    expand: false;
    str: ":";
}

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px 0px 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 1;
    lines: 5;
    background-color: @bg-col;
}

element {
    padding: 8px;
    background-color: @bg-col;
    text-color: @fg-col;
    border-radius: 8px;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @bg-col;
}

mode-switcher {
    spacing: 0;
}

button {
    padding: 10px;
    background-color: @bg-col-light;
    text-color: @grey;
    vertical-align: 0.5;
    horizontal-align: 0.5;
}

button selected {
    background-color: @bg-col;
    text-color: @blue;
}

message {
    background-color: @bg-col-light;
    margin: 2px;
    padding: 2px;
    border-radius: 8px;
}

textbox {
    padding: 6px;
    margin: 20px 0px 0px 20px;
    text-color: @blue;
    background-color: @bg-col-light;
}
EOF

# Create Alacritty configuration
log "Setting up Alacritty configuration..."
mkdir -p ~/.config/alacritty

cat > ~/.config/alacritty/alacritty.yml << 'EOF'
# Alacritty Configuration for MacBook M1 Air

window:
  padding:
    x: 12
    y: 12
  dynamic_padding: false
  decorations: buttonless
  opacity: 0.9
  startup_mode: Windowed
  title: Alacritty
  dynamic_title: true

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: JetBrains Mono
    style: Regular
  bold:
    family: JetBrains Mono
    style: Bold
  italic:
    family: JetBrains Mono
    style: Italic
  bold_italic:
    family: JetBrains Mono
    style: Bold Italic
  size: 14.0
  offset:
    x: 0
    y: 0
  glyph_offset:
    x: 0
    y: 0

draw_bold_text_with_bright_colors: false

# Catppuccin Mocha theme
colors:
  primary:
    background: '#1e1e2e'
    foreground: '#cdd6f4'
    dim_foreground: '#7f849c'
    bright_foreground: '#cdd6f4'

  cursor:
    text: '#1e1e2e'
    cursor: '#f5e0dc'

  vi_mode_cursor:
    text: '#1e1e2e'
    cursor: '#b4befe'

  search:
    matches:
      foreground: '#1e1e2e'
      background: '#a6adc8'
    focused_match:
      foreground: '#1e1e2e'
      background: '#a6e3a1'
    footer_bar:
      foreground: '#1e1e2e'
      background: '#a6adc8'

  hints:
    start:
      foreground: '#1e1e2e'
      background: '#f9e2af'
    end:
      foreground: '#1e1e2e'
      background: '#a6adc8'

  selection:
    text: '#1e1e2e'
    background: '#f5e0dc'

  normal:
    black: '#45475a'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#bac2de'

  bright:
    black: '#585b70'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#a6adc8'

  dim:
    black: '#45475a'
    red: '#f38ba8'
    green: '#a6e3a1'
    yellow: '#f9e2af'
    blue: '#89b4fa'
    magenta: '#f5c2e7'
    cyan: '#94e2d5'
    white: '#bac2de'

  indexed_colors:
    - { index: 16, color: '#fab387' }
    - { index: 17, color: '#f5e0dc' }

bell:
  animation: EaseOutExpo
  duration: 0
  color: '#ffffff'

selection:
  semantic_escape_chars: ",│`|:\"' ()[]{}<>\t"
  save_to_clipboard: true

cursor:
  style:
    shape: Block
    blinking: On
  vi_mode_style: None
  blink_interval: 750
  unfocused_hollow: true
  thickness: 0.15

live_config_reload: true

shell:
  program: /bin/bash
  args:
    - --login

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }
  hide_when_typing: false

hints:
  alphabet: "jfkdls;ahgurieowpq"
  enabled:
   - regex: "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001f\u007f-\u009f<>\"\\s{-}\\^⟨⟩`]+"
     command: open
     post_processing: true
     mouse:
       enabled: true
       mods: None
     binding:
       key: U
       mods: Control|Shift

key_bindings:
  # MacBook-style bindings
  - { key: A,         mods: Command,       action: SelectAll                    }
  - { key: C,         mods: Command,       action: Copy                         }
  - { key: V,         mods: Command,       action: Paste                        }
  - { key: Q,         mods: Command,       action: Quit                         }
  - { key: W,         mods: Command,       action: Quit                         }
  - { key: N,         mods: Command,       action: SpawnNewInstance             }
  
  # Font size
  - { key: Key0,      mods: Command,       action: ResetFontSize                }
  - { key: Equals,    mods: Command,       action: IncreaseFontSize             }
  - { key: Plus,      mods: Command,       action: IncreaseFontSize             }
  - { key: Minus,     mods: Command,       action: DecreaseFontSize             }
  
  # Navigation
  - { key: Left,      mods: Command,       chars: "\x01"                        }
  - { key: Right,     mods: Command,       chars: "\x05"                        }
  - { key: Left,      mods: Alt,           chars: "\x1bb"                       }
  - { key: Right,     mods: Alt,           chars: "\x1bf"                       }
EOF

# Create screenshots directory
log "Creating screenshots directory..."
mkdir -p ~/Pictures/Screenshots

# Create desktop entry for Hyprland
log "Creating desktop entry for Hyprland..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Set up Czech keyboard layout system-wide
log "Configuring Czech keyboard layout..."
sudo localectl set-x11-keymap us,cz pc105 ,qwerty grp:alt_shift_toggle,caps:escape

# Create a simple startup script
log "Creating startup script..."
cat > ~/.config/hypr/startup.sh << 'EOF'
#!/bin/bash

# MacBook-specific startup optimizations
echo "Starting Hyprland session for MacBook M1 Air..."

# Set keyboard layout
hyprctl keyword input:kb_layout "us,cz"
hyprctl keyword input:kb_variant ",qwerty"
hyprctl keyword input:kb_options "grp:alt_shift_toggle,caps:escape"

# Set trackpad settings
hyprctl keyword input:touchpad:natural_scroll true
hyprctl keyword input:touchpad:tap-to-click true
hyprctl keyword input:touchpad:drag_lock true

# Optimize for battery life
echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true

echo "Hyprland startup complete!"
EOF

chmod +x ~/.config/hypr/startup.sh

success "Installation completed successfully!"
echo ""
echo -e "${GREEN}🍎 MacBook M1 Air Hyprland Setup Complete! 🍎${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Reboot your system"
echo "2. Log out and select Hyprland from your display manager"
echo "3. The system will automatically configure for your MacBook"
echo ""
echo -e "${YELLOW}Key bindings (MacBook optimized):${NC}"
echo "Super+Return: Terminal (Alacritty)"
echo "Super+Q: Close window"
echo "Super+Shift+Q: Exit Hyprland"
echo "Super+E: File manager"
echo "Super+Space: Application launcher (Rofi)"
echo "Super+I: Switch keyboard layout (US ⟷ Czech)"
echo "Super+H/J/K/L: Move focus (vim-style)"
echo "Super+Shift+H/J/K/L: Move windows"
echo "Super+Alt+H/J/K/L: Resize windows"
echo "Super+1-0: Switch workspaces"
echo "Super+Shift+1-0: Move window to workspace"
echo "Super+Shift+S: Screenshot selection"
echo "Super+Shift+3: Screenshot full screen"
echo "3-finger swipe: Switch workspaces"
echo ""
echo -e "${PURPLE}MacBook-specific features:${NC}"
echo "✓ Czech keyboard layout (Alt+Shift to switch)"
echo "✓ Optimized trackpad settings"
echo "✓ Function keys for brightness/volume"
echo "✓ macOS-like animations and blur effects"
echo "✓ Retina display optimizations"
echo "✓ Power management optimizations"
echo ""
echo -e "${BLUE}Configuration files created:${NC}"
echo "~/.config/hypr/hyprland.conf"
echo "~/.config/waybar/config"
echo "~/.config/rofi/config.rasi"
echo "~/.config/alacritty/alacritty.yml"
echo ""
echo -e "${GREEN}Enjoy your new Hyprland setup on MacBook M1 Air! 🚀${NC}"