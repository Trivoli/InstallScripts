#!/bin/bash

# Hyprland Nvidia Installation Script for Arch Linux
# This script installs Hyprland with Nvidia support and basic configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    error "This script is designed for Arch Linux with pacman package manager"
fi

log "Starting Hyprland Nvidia installation..."

# Update system
log "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install yay if not present
if ! command -v yay &> /dev/null; then
    log "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install Nvidia drivers
log "Installing Nvidia drivers..."
sudo pacman -S --needed --noconfirm \
    nvidia \
    nvidia-utils \
    nvidia-settings \
    lib32-nvidia-utils \
    egl-wayland

# Install Hyprland and dependencies
log "Installing Hyprland and dependencies..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland \
    polkit-kde-agent \
    waybar \
    wofi \
    kitty \
    thunar \
    grim \
    slurp \
    wl-clipboard \
    mako \
    swww

# Install additional useful packages
log "Installing additional packages..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    brightnessctl \
    playerctl \
    network-manager-applet \
    bluez \
    bluez-utils \
    blueman

# Enable services
log "Enabling system services..."
sudo systemctl enable bluetooth
sudo systemctl enable NetworkManager

# Create Hyprland config directory
log "Setting up Hyprland configuration..."
mkdir -p ~/.config/hypr

# Create basic Hyprland configuration
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Hyprland Configuration with Nvidia Support

# Monitor configuration
monitor=,preferred,auto,auto

# Nvidia specific environment variables
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = XCURSOR_SIZE,24

# Execute your favorite apps at launch
exec-once = waybar
exec-once = mako
exec-once = swww init
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = blueman-applet

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration settings
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animation settings
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout settings
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Gestures
gestures {
    workspace_swipe = off
}

# Key bindings
$mainMod = SUPER

bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

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
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy

# Media keys
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Brightness keys
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
EOF

# Create basic waybar config
log "Setting up Waybar configuration..."
mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "clock", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{name}: {icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "hyprland/window": {
        "format": "{}"
    },
    
    "tray": {
        "spacing": 10
    },
    
    "clock": {
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
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
        "on-click": "pavucontrol"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(43, 48, 59, 0.8);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#clock,
#battery,
#cpu,
#memory,
#network,
#pulseaudio,
#tray {
    padding: 0 10px;
    color: #ffffff;
}

#window {
    margin: 0 4px;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #26A65B;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}
EOF

# Create kernel parameters for Nvidia
log "Configuring kernel parameters for Nvidia..."
if [ -f /etc/default/grub ]; then
    sudo cp /etc/default/grub /etc/default/grub.backup
    if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia-drm.modeset=1 /' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        warn "Kernel parameters updated. Reboot required for changes to take effect."
    fi
fi

# Create mkinitcpio configuration for Nvidia
log "Configuring initramfs for Nvidia..."
if [ -f /etc/mkinitcpio.conf ]; then
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
    if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
        sudo sed -i 's/MODULES=(/&nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
        warn "Initramfs updated. Reboot required for changes to take effect."
    fi
fi

# Create desktop entry for Hyprland
log "Creating desktop entry for Hyprland..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

log "Installation completed successfully!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Reboot your system to load Nvidia kernel modules"
echo "2. Log out and select Hyprland from your display manager"
echo "3. Use Super+R to open application launcher (wofi)"
echo "4. Use Super+Q to open terminal (kitty)"
echo "5. Use Super+E to open file manager (thunar)"
echo ""
echo -e "${YELLOW}Key bindings:${NC}"
echo "Super+Q: Terminal"
echo "Super+C: Close window"
echo "Super+M: Exit Hyprland"
echo "Super+E: File manager"
echo "Super+R: Application launcher"
echo "Super+V: Toggle floating"
echo "Super+1-0: Switch workspaces"
echo "Super+Shift+1-0: Move window to workspace"
echo "Print: Screenshot selection"
echo "Shift+Print: Screenshot full screen"
echo ""
echo -e "${BLUE}Configuration files created:${NC}"
echo "~/.config/hypr/hyprland.conf"
echo "~/.config/waybar/config"
echo "~/.config/waybar/style.css"
echo ""
echo -e "${GREEN}Installation complete! Please reboot your system.${NC}"g"
echo "Super+1-0: Switch workspaces"
echo "Super+Shift+1-0: Move window to workspace"
echo "Print: Screenshot selection"
echo "Shift+Print: Screenshot full screen"
echo ""
echo -e "${BLUE}Configuration files created:${NC}"
echo "~/.config/hypr/hyprland.conf"
echo "~/.config/waybar/config"
echo "~/.config/waybar/style.css"
echo ""
echo -e "${GREEN}Installation complete! Please reboot your system.${NC}"