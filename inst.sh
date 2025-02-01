#!/bin/bash

# Function to install dependencies on Ubuntu/Debian
install_ubuntu_debian() {
    echo "Installing dependencies on Ubuntu/Debian..."
    sudo apt-get update
    sudo apt-get install -y clang gcc nasm elixir git
    git clone https://github.com/DrxcoDev/SuperPengu.git
    cd SuperPengu
    touch config.pengu
    mkdir env/usr/conf
}

# Function to install dependencies on Fedora
install_fedora() {
    echo "Installing dependencies on Fedora..."
    sudo dnf install -y clang gcc nasm elixir git
    git clone https://github.com/DrxcoDev/SuperPengu.git
    cd SuperPengu
    touch config.pengu
    mkdir env/usr/conf
}

# Function to install dependencies on Arch Linux
install_archlinux() {
    echo "Installing dependencies on Arch Linux..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm clang gcc nasm elixir git
    git clone https://github.com/DrxcoDev/SuperPengu.git
    cd SuperPengu
    touch config.pengu
    mkdir env/usr/conf
}

# Detect the distribution
if [ -f /etc/os-release ]; then
    # Read the /etc/os-release file to get the distribution name
    . /etc/os-release
    DISTRIB=$ID

    case $DISTRIB in
        ubuntu|debian|linuxmint|elementary|pop)
            install_ubuntu_debian
            ;;
        fedora|centos|rhel)
            install_fedora
            ;;
        arch|manjaro|artix|cachyos)
            install_archlinux
            ;;
        *)
            echo "Unsupported distribution. Only Fedora, Ubuntu, Debian, Arch Linux and their derivatives are supported."
            exit 1
            ;;
    esac
else
    echo "Could not determine the operating system distribution."
    exit 1
fi

# Final message
echo "Installation complete. Clang, GCC, NASM, and Elixir are ready to use."
