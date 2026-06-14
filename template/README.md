# Coder Docker Desktop Template

This template provisions a Coder workspace as a Docker container with:

- Persistent `/home/coder` volume.
- A custom Docker image based on `codercom/example-desktop:ubuntu`.
- A GNOME/Ubuntu-style desktop with Yaru theming and Ubuntu Dock.
- Browser-based desktop access through the Coder dashboard using the official KasmVNC module.
- code-server access through the Coder dashboard.
- Desktop apps including Google Chrome, VS Code, LibreOffice, Files, Terminal, GIMP, Inkscape, VLC, MPV, Evince, and common CLI tools.
- .NET SDK 10.0, .NET SDK 8.0, NVM with the current Node LTS line, `pnpm@11.3.0`, and Bun.
- Native desktop development dependencies for WebKitGTK/WebView-style apps, keyring integration, Vulkan/LLamaSharp acceleration, and NativeAOT/build tooling.
- CPU, memory, and dotfiles parameters.

## Use It

From this directory, on a machine with the Coder CLI configured:

```powershell
coder templates create docker-desktop
```

For an existing template:

```powershell
coder templates push docker-desktop
```

After creating or updating a workspace, open the workspace dashboard and click **KasmVNC** for the desktop session.

The first template push/build will take a while because the image installs a full GNOME-flavored desktop and several large desktop applications.

## Docker Socket

The template uses the provisioner's default Docker socket. If your Coder provisioner needs an explicit socket, set the `docker_socket` template variable, for example:

```text
unix:///var/run/docker.sock
```

## Layout

- `main.tf` is the Coder template.
- `Dockerfile` builds the custom desktop image.
- `image-assets/` contains scripts and `.desktop` launchers copied into the image.

## Notes

The old generated version installed XFCE, TigerVNC, and noVNC every time the workspace started. This version bakes the desktop and apps into a custom Docker image and uses Coder's official KasmVNC module at runtime.

Google Chrome's Linux package is only available for `amd64`, so this image is intended for an `amd64` Docker host/provisioner.

## LovelyGit

The image includes the toolchain and native dependencies needed for `ExpressThat/LovelyGit` development:

- `dotnet-sdk-10.0` and `dotnet-sdk-8.0`.
- NVM `0.40.3` with Node LTS `24.x`.
- `pnpm@11.3.0`, matching the repository's `packageManager`, plus Bun.
- WebKitGTK 4.1 runtime/development packages, `xdg-desktop-portal`, GTK, keyring/libsecret, Vulkan/Mesa, clang, CMake, Ninja, and NativeAOT build dependencies.

Validated in the image:

```bash
dotnet restore LovelyGit/LovelyGit.csproj
dotnet build LovelyGit/LovelyGit.csproj --no-restore
dotnet tool restore
pnpm install --frozen-lockfile
```

At the time this was checked, LovelyGit's `pnpm generate:csharp-types` command ran Tapper but produced no `src/generated` files, so the frontend build failed on missing generated TypeScript modules. That appears to be a repo/codegen issue rather than a missing image dependency.
