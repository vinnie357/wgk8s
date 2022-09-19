#!/bin/bash
function tailscale-debian {
# Install tailscale
# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
# install tailscale
sudo apt-get update && sudo apt-get install -y \
tailscale
tailscale --version
}
