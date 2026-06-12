FROM codercom/example-desktop:ubuntu

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/usr/local/nvm
ENV APPIMAGE_EXTRACT_AND_RUN=1

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    apt-transport-https \
    software-properties-common \
  && install -d -m 0755 /etc/apt/keyrings \
  && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg \
  && chmod a+r /etc/apt/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg \
  && chmod a+r /etc/apt/keyrings/packages.microsoft.gpg \
  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ubuntu-desktop-minimal \
    gnome-shell \
    gnome-session \
    gnome-terminal \
    gnome-tweaks \
    gnome-control-center \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-desktop-icons-ng \
    gnome-shell-extension-ubuntu-dock \
    yaru-theme-gnome-shell \
    yaru-theme-gtk \
    yaru-theme-icon \
    yaru-theme-sound \
    adwaita-icon-theme-full \
    google-chrome-stable \
    code \
    dotnet-sdk-10.0 \
    dotnet-sdk-8.0 \
    libreoffice \
    evince \
    eog \
    file-roller \
    gedit \
    nautilus \
    xdg-user-dirs \
    xdg-utils \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    dbus-x11 \
    dconf-cli \
    gnome-keyring \
    seahorse \
    libsecret-1-0 \
    libsecret-1-dev \
    fuse3 \
    libfuse2t64 \
    libfuse3-3 \
    libwebkit2gtk-4.1-0 \
    libwebkit2gtk-4.1-dev \
    webkit2gtk-driver \
    libgtk-3-0 \
    libayatana-appindicator3-1 \
    libnss3 \
    libxss1 \
    libgbm1 \
    libdrm2 \
    libasound2t64 \
    libxkbcommon0 \
    libxrandr2 \
    libxdamage1 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libxrender1 \
    libx11-xcb1 \
    libgl1 \
    libegl1 \
    libvulkan1 \
    mesa-vulkan-drivers \
    vulkan-tools \
    fonts-cantarell \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto-color-emoji \
    git \
    jq \
    nano \
    vim \
    build-essential \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    zlib1g-dev \
    libssl-dev \
    libicu-dev \
    htop \
    tree \
    unzip \
    zip \
    p7zip-full \
    ffmpeg \
    mpv \
    vlc \
    gimp \
    inkscape \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$NVM_DIR" \
  && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install --lts \
  && nvm alias default 'lts/*' \
  && nvm use default \
  && npm install -g pnpm@11.3.0 \
  && ln -sf "$NVM_DIR/versions/node/$(nvm version default)/bin/node" /usr/local/bin/node \
  && ln -sf "$NVM_DIR/versions/node/$(nvm version default)/bin/npm" /usr/local/bin/npm \
  && ln -sf "$NVM_DIR/versions/node/$(nvm version default)/bin/npx" /usr/local/bin/npx \
  && ln -sf "$NVM_DIR/versions/node/$(nvm version default)/bin/corepack" /usr/local/bin/corepack \
  && ln -sf "$NVM_DIR/versions/node/$(nvm version default)/bin/pnpm" /usr/local/bin/pnpm \
  && node --version \
  && npm --version \
  && pnpm --version \
  && cat > /etc/profile.d/nvm.sh <<'EOF'
export NVM_DIR=/usr/local/nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
EOF
RUN printf '\n[ -s /etc/profile.d/nvm.sh ] && . /etc/profile.d/nvm.sh\nexport PATH="$HOME/.dotnet/tools:$PATH"\n' >> /etc/bash.bashrc \
  && chown -R coder:coder "$NVM_DIR"

RUN mkdir -p /etc/skel/.config/autostart /usr/local/share/applications

COPY image-assets/desktop-defaults.sh /usr/local/bin/desktop-defaults
COPY image-assets/chrome-coder /usr/local/bin/chrome-coder
COPY image-assets/code-coder /usr/local/bin/code-coder
COPY image-assets/appimage-run /usr/local/bin/appimage-run
COPY image-assets/desktop-defaults.desktop /etc/skel/.config/autostart/desktop-defaults.desktop
COPY image-assets/google-chrome-coder.desktop /usr/local/share/applications/google-chrome-coder.desktop
COPY image-assets/code-coder.desktop /usr/local/share/applications/code-coder.desktop

RUN chmod +x /usr/local/bin/desktop-defaults /usr/local/bin/chrome-coder /usr/local/bin/code-coder /usr/local/bin/appimage-run

USER coder
