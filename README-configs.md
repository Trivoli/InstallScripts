# Hyprland Configuration for MacBook M1 Air (Asahi Linux)

This repository contains a comprehensive Hyprland configuration optimized for MacBook M1 Air running Asahi Linux, with excellent Czech keyboard support.

## 📁 Configuration Files

### 🖥️ Hyprland Configuration
- **File**: `HyprlandConfig`
- **Location**: `~/.config/hypr/hyprland.conf`
- **Features**:
  - Czech keyboard layout support (US/CZ with Alt+Shift toggle)
  - MacBook trackpad gestures
  - Optimized for Apple Silicon
  - Modern animations and blur effects
  - Comprehensive keybindings

### 🎨 Waybar Configuration
- **Files**: 
  - `waybar-config.json` → `~/.config/waybar/config`
  - `waybar-style.css` → `~/.config/waybar/style.css`
- **Features**:
  - Modern Catppuccin-inspired theme
  - Czech timezone (Europe/Prague)
  - System monitoring (CPU, memory, temperature)
  - Battery status with MacBook optimizations
  - Network and audio controls

### 💻 Alacritty Terminal Configuration
- **File**: `alacritty.yml`
- **Location**: `~/.config/alacritty/alacritty.yml`
- **Features**:
  - JetBrainsMono Nerd Font
  - Catppuccin Mocha color scheme
  - Czech keyboard character bindings
  - Vi mode support
  - Optimized for MacBook display

## 🚀 Installation Instructions

### 1. Create Configuration Directories
```bash
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/alacritty
```

### 2. Copy Configuration Files
```bash
# Hyprland configuration
cp HyprlandConfig ~/.config/hypr/hyprland.conf

# Waybar configuration
cp waybar-config.json ~/.config/waybar/config
cp waybar-style.css ~/.config/waybar/style.css

# Alacritty configuration
cp alacritty.yml ~/.config/alacritty/alacritty.yml
```

### 3. Install Required Dependencies
Make sure you have these packages installed:

```bash
# Essential Hyprland packages
sudo dnf install hyprland waybar alacritty

# Additional utilities
sudo dnf install rofi thunar polkit-gnome
sudo dnf install wl-clipboard cliphist grim slurp swappy
sudo dnf install brightnessctl playerctl pavucontrol
sudo dnf install hyprpaper hypridle hyprlock
sudo dnf install swaync wlogout

# Fonts
sudo dnf install jetbrains-mono-fonts-all
```

### 4. Set Up Fish Shell (Optional)
```bash
sudo dnf install fish
chsh -s /usr/bin/fish
```

## ⌨️ Czech Keyboard Features

### Layout Switching
- **Alt + Shift**: Toggle between US and Czech layouts
- **Caps Lock**: Acts as Escape key
- **Right Alt**: Compose key for special characters

### Czech Character Bindings in Alacritty
- **Alt + Y**: ž/Ž
- **Alt + X**: č/Č  
- **Alt + C**: ć/Ć
- **Alt + V**: š/Š
- **Alt + B**: ř/Ř
- **Alt + N**: ň/Ň
- **Alt + M**: ď/Ď
- **Alt + ,**: ť/Ť
- **Alt + ;**: ů/Ů

## 🎯 Key Bindings (Hyprland)

### Window Management
- **Super + T**: Open Alacritty terminal
- **Super + Q**: Close active window
- **Super + V**: Toggle floating mode
- **Super + F**: Toggle fullscreen
- **Super + R**: Open application launcher (Rofi)

### Navigation
- **Super + Arrow Keys**: Move focus
- **Super + H/J/K/L**: Move focus (Vim-style)
- **Super + Shift + Arrow Keys**: Move windows
- **Super + Ctrl + Arrow Keys**: Resize windows

### Workspaces
- **Super + 1-9**: Switch to workspace
- **Super + Shift + 1-9**: Move window to workspace
- **Super + S**: Toggle scratchpad

### MacBook Function Keys
- **Brightness**: F1/F2 keys
- **Volume**: F10/F11/F12 keys
- **Media**: Play/Pause/Next/Previous

### Screenshots
- **Print**: Area screenshot with editor
- **Shift + Print**: Full screen screenshot with editor
- **Super + Print**: Area screenshot to file
- **Super + Shift + Print**: Full screen screenshot to file

## 🎨 Customization

### Changing Colors
The configuration uses the Catppuccin color scheme. To customize colors, edit:
- Hyprland: `col.active_border` and `col.inactive_border` in `hyprland.conf`
- Waybar: Color definitions in `waybar-style.css`
- Alacritty: Colors section in `alacritty.yml`

### Adding Applications to Startup
Add to the `exec-once` section in `hyprland.conf`:
```
exec-once = your-application
```

### Modifying Waybar Modules
Edit `waybar-config.json` to add/remove modules from the bar.

## 🔧 Troubleshooting

### Czech Keyboard Not Working
1. Verify the layout is set correctly:
   ```bash
   localectl status
   ```
2. Set the layout if needed:
   ```bash
   sudo localectl set-keymap us
   sudo localectl set-x11-keymap us,cz pc104 ,qwerty grp:alt_shift_toggle
   ```

### Waybar Not Starting
1. Check if the config is valid:
   ```bash
   waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css
   ```
2. Check for missing dependencies

### Font Issues in Alacritty
1. Install JetBrainsMono Nerd Font:
   ```bash
   sudo dnf install jetbrains-mono-fonts-all
   ```
2. Refresh font cache:
   ```bash
   fc-cache -fv
   ```

## 📱 MacBook-Specific Features

### Trackpad Gestures
- **3-finger swipe**: Switch workspaces
- **Tap to click**: Enabled
- **Natural scrolling**: Enabled

### Power Management
- **Brightness control**: Automatic with function keys
- **Battery optimization**: Configured in Waybar

### Display Scaling
- **HiDPI support**: Properly configured for MacBook displays
- **Fractional scaling**: Available through Hyprland

## 🆘 Support

If you encounter issues:
1. Check the Hyprland logs: `journalctl -f -t Hyprland`
2. Verify all dependencies are installed
3. Check the Asahi Linux documentation for hardware-specific issues

## 📄 License

These configurations are provided as-is. Feel free to modify and distribute.

---

**Enjoy your beautifully configured Hyprland setup on your MacBook M1 Air! 🚀**