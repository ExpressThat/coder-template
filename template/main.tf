terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI. Leave empty to use the provisioner's default Docker socket."
  type        = string
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU Cores"
  description  = "The number of CPU cores allocated to the workspace container."
  type         = "number"
  default      = "2"
  mutable      = true
  icon         = "/icon/memory.svg"

  option {
    name  = "2 Cores"
    value = "2"
  }
  option {
    name  = "4 Cores"
    value = "4"
  }
  option {
    name  = "8 Cores"
    value = "8"
  }
}

data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory allocated to the workspace container."
  type         = "number"
  default      = "4"
  mutable      = true
  icon         = "/icon/memory.svg"

  option {
    name  = "4 GB"
    value = "4"
  }
  option {
    name  = "8 GB"
    value = "8"
  }
  option {
    name  = "16 GB"
    value = "16"
  }
}

data "coder_parameter" "dotfiles_url" {
  name         = "dotfiles_url"
  display_name = "Dotfiles URL"
  description  = "Optional dotfiles repository to apply when the workspace starts."
  default      = ""
  mutable      = true
  icon         = "/icon/git.svg"
}

locals {
  container_name = "coder-${lower(data.coder_workspace_owner.me.name)}-${lower(data.coder_workspace.me.name)}"
  image_name     = "rosssearle/ubuntu-desktop:0.0.5"
}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  startup_script = <<-EOT
    set -e

    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    mkdir -p ~/.config/autostart
    if [ -f /etc/skel/.config/autostart/desktop-defaults.desktop ]; then
      cp /etc/skel/.config/autostart/desktop-defaults.desktop ~/.config/autostart/desktop-defaults.desktop
    fi

    if [ -n "$DOTFILES_URI" ]; then
      coder dotfiles "$DOTFILES_URI" --yes
    fi
  EOT

  env = {
    DOTFILES_URI        = data.coder_parameter.dotfiles_url.value
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = data.coder_workspace_owner.me.email
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = data.coder_workspace_owner.me.email
  }

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "2_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }
}

module "code-server" {
  count  = data.coder_workspace.me.start_count
  source = "registry.coder.com/coder/code-server/coder"

  version = "~> 1.0"

  agent_id = coder_agent.main.id
  order    = 1
}

module "kasmvnc" {
  count  = data.coder_workspace.me.start_count
  source = "registry.coder.com/coder/kasmvnc/coder"

  version = "~> 1.3"

  agent_id            = coder_agent.main.id
  desktop_environment = "xfce"
  subdomain           = false
  order               = 2
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"

  lifecycle {
    ignore_changes = all
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count

  image    = local.image_name
  name     = local.container_name
  hostname = data.coder_workspace.me.name

  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]

  cpu_shares = data.coder_parameter.cpu.value * 1024
  memory     = data.coder_parameter.memory.value * 1024
  shm_size   = 2048

  # AppImages prefer FUSE. The image also sets APPIMAGE_EXTRACT_AND_RUN=1 so
  # direct AppImage execution falls back cleanly when the host blocks FUSE.
  privileged = true

  capabilities {
    add = ["SYS_ADMIN"]
  }

  devices {
    host_path      = "/dev/fuse"
    container_path = "/dev/fuse"
    permissions    = "rwm"
  }

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
