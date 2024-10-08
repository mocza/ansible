#!/bin/bash
# Run this script as the root user right after OS install as a preliminary step before applying automated configuration using Ansible pull.
#
# curl https://raw.githubusercontent.com/mocza/ansible/main/preface.sh | sudo bash
#
# On a network device running OpenWRT (installs only python but no git nad ansible so ansible-pull won't work):
# wget -qO- https://raw.githubusercontent.com/mocza/ansible/main/preface.sh | sh
#
# This script is meant to do minimal settings before any other automated configuration to a fresh OS installation can happen:
# - detects OS: Debian or Arch Linux
# - detects PVE host and configures apt sources for PVE no-subscription repository
# - installs pre-requisites for Ansible
#
# Run ansible-pull as root for the first time (sudo might not be setup) to deploy configuration once the this script was executed:
# ansible-pull -U https://github.com/mocza/ansible.git --vault-id @prompt


# Function to configure PVE no-subscription repository
configure_pve_repo() {
    echo "Configuring Proxmox VE no-subscription repository..."
    tee /etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF

    # Disable the enterprise repository
    mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.disabled

    # Disable the CEPH repository
    mv /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.disabled
}

# Function to install prerequisites on Debian-based systems
install_debian() {
    echo "Detected Debian-based system."

    # Check if it's a Proxmox VE host
    if command -v pveversion &> /dev/null; then
        echo "Detected Proxmox VE host."
        configure_pve_repo
    fi    

    # Update package list
    echo "Updating package list..."
    apt-get update

    # Install Git
    echo "Installing Git..."
    apt-get install -y git
    
    echo "Installing Ansible..."
    apt-get install -y ansible

    # Verify installations
    echo "Verifying installations..."
    echo -n "Git version: "
    git --version
    echo -n "Ansible version: "
    ansible --version
}

# Function to install prerequisites on Arch Linux systems
install_arch() {
    echo "Detected Arch Linux system."
    
    # Update package list and install prerequisites
    echo "Updating package list..."
    pacman -Syu --noconfirm

    # Install Git and Ansible
    echo "Installing Git and Ansible..."
    pacman -S --noconfirm git ansible

    # Verify installations
    echo "Verifying installations..."
    echo -n "Git version: "
    git --version
    echo -n "Ansible version: "
    ansible --version
}

install_openwrt() {
    echo "Updating opkg package list..."
    opkg update

    echo "Installing Python..."
    opkg install python3

    if [ $? -eq 0 ]; then
        echo "Python successfully installed."
    else
        echo "Failed to install Python."
    fi
}

# Detect the operating system
if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/arch-release ]; then
    install_arch
elif [ -f /etc/openwrt_release ] || [ -f /etc/openwrt_version ]; then
    install_openwrt
else
    echo "Unsupported operating system."
    exit 1
fi

echo "Prerequisites for ansible-pull have been installed."
