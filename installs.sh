#!/bin/bash

set -e

# Function to display a message and exit on error
error_exit() {
    echo "$1" >&2
    exit 1
}

# Update package lists and install necessary packages
echo "Updating package lists and installing necessary packages..."
sudo apt update || error_exit "Failed to update package lists."
sudo apt install -y lsof journalctl logrotate docker.io nginx || error_exit "Failed to install necessary packages."

# Ensure Docker and Nginx services are enabled and started
echo "Enabling and starting Docker and Nginx services..."
sudo systemctl enable docker || error_exit "Failed to enable Docker service."
sudo systemctl start docker || error_exit "Failed to start Docker service."
sudo systemctl enable nginx || error_exit "Failed to enable Nginx service."
sudo systemctl start nginx || error_exit "Failed to start Nginx service."

