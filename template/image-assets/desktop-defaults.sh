#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/.config"

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  xdg-user-dirs-update || true
fi

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface gtk-theme "Yaru" || true
  gsettings set org.gnome.desktop.interface icon-theme "Yaru" || true
  gsettings set org.gnome.desktop.interface cursor-theme "Yaru" || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" || true
  gsettings set org.gnome.desktop.interface clock-show-weekday true || true
  gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close" || true
  gsettings set org.gnome.desktop.background picture-options "zoom" || true
  gsettings set org.gnome.desktop.background primary-color "#241f31" || true
  gsettings set org.gnome.desktop.background secondary-color "#E95420" || true
  gsettings set org.gnome.desktop.background color-shading-type "vertical" || true
  gsettings set org.gnome.desktop.screensaver primary-color "#241f31" || true
  gsettings set org.gnome.desktop.screensaver secondary-color "#E95420" || true
  gsettings set org.gnome.desktop.screensaver color-shading-type "vertical" || true
  gsettings set org.gnome.shell favorite-apps "['google-chrome-coder.desktop', 'code-coder.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'libreoffice-writer.desktop']" || true
  gsettings set org.gnome.shell enabled-extensions "['ubuntu-dock@ubuntu.com', 'ding@rastersoft.com', 'appindicatorsupport@rgcjonas.gmail.com']" || true
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "LEFT" || true
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true || true
  gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true || true
fi

if command -v xfconf-query >/dev/null 2>&1; then
  xfconf-query -c xsettings -p /Net/ThemeName -s "Yaru" || true
  xfconf-query -c xsettings -p /Net/IconThemeName -s "Yaru" || true
  xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Yaru" || true
  xfconf-query -c xfwm4 -p /general/theme -s "Yaru" || true
  xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC" || true
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s true || true
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s true || true
  xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s true || true
fi

cat > "$HOME/Desktop/Google Chrome.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Exec=chrome-coder %U
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
EOF

cat > "$HOME/Desktop/Visual Studio Code.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Visual Studio Code
Exec=code-coder %F
Icon=com.visualstudio.code
Terminal=false
Categories=Development;IDE;
MimeType=text/plain;inode/directory;
EOF

cat > "$HOME/Desktop/Files.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Files
Exec=nautilus
Icon=org.gnome.Nautilus
Terminal=false
Categories=System;FileManager;
EOF

cat > "$HOME/Desktop/Terminal.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Exec=gnome-terminal
Icon=org.gnome.Terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF

chmod +x "$HOME/Desktop/"*.desktop 2>/dev/null || true

for launcher in "$HOME/Desktop/"*.desktop; do
  [ -f "$launcher" ] || continue

  chmod 0755 "$launcher" 2>/dev/null || true

  if command -v gio >/dev/null 2>&1; then
    gio set "$launcher" metadata::trusted true 2>/dev/null || true

    checksum="$(sha256sum "$launcher" | awk '{print $1}')"
    gio set -t string "$launcher" metadata::xfce-exe-checksum "$checksum" 2>/dev/null || true
  fi

  touch "$launcher" 2>/dev/null || true
done

touch "$HOME/.desktop_defaults_done"
