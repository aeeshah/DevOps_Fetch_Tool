# System Monitoring and `devopsfetch` Tool Setup

This repository contains scripts and configuration files to install necessary dependencies, set up continuous monitoring with logging, and include a custom `devopsfetch` tool for detailed system information.

## Table of Contents

1. [Dependencies](#dependencies)
2. [Setup Instructions](#setup-instructions)
3. [Log Rotation](#log-rotation)
4. [Service Configuration](#service-configuration)
5. [Monitoring Script](#monitoring-script)
6. [`devopsfetch` Tool](#devopsfetch-tool)
7. [Usage](#usage)

## Dependencies

The setup script installs the following dependencies:
- `lsof`: To list open files and ports.
- `journalctl`: To view system logs.
- `logrotate`: To manage log rotation.
- `docker.io`: To manage Docker containers.
- `nginx`: To configure and monitor Nginx.

## Setup Instructions

1. **Clone the repository:**

    ```bash
    git clone https://github.com/aeeshah/DevOps_Fetch_Tool.git
    cd DevOps_Fetch_Tool
    ```

2. **Run the setup script:**

    ```bash
    sudo ./setup_monitoring.sh
    ```

    This script will:
    - Install necessary packages.
    - Create and configure the monitoring script.
    - Set up log rotation.
    - Configure and enable a `systemd` service to run the monitoring script.

## Log Rotation

The log rotation is configured to handle the logs generated by the monitoring script. The configuration ensures that:
- Logs are rotated daily.
- Up to 7 days of logs are kept.
- Older logs are compressed.

Log rotation configuration is placed in `/etc/logrotate.d/system_monitor`.

## Service Configuration

The `systemd` service configuration ensures the monitoring script runs continuously and restarts automatically if it fails.

The service configuration is placed in `/etc/systemd/system/system_monitor.service`.

## Monitoring Script

The `monitor.sh` script performs the following tasks every 300 seconds:
- Logs active TCP ports and services.
- Logs Docker containers and their statuses.
- Logs Nginx domain configurations.

The script is located at `/usr/local/bin/monitor.sh`.

## `devopsfetch` Tool

The `devopsfetch` tool is a utility to collect and display various system information, including:

- **Ports**:
  - Display all active ports and services (`-p` or `--port`).
  - Provide detailed information about a specific port (`-p <port_number>`).

- **Users**:
  - List all users and their last login times (`-u` or `--users`).
  - Provide detailed information about a specific user (`-u <username>`).

- **Docker**:
  - List all Docker images and containers (`-d` or `--docker`).
  - Provide detailed information about a specific container (`-d <container_name>`).

- **Nginx**:
  - Display all Nginx domains (`-n` or `--nginx`).
  - Provide detailed configuration information for a specific domain (`-n <domain>`).

- **Time Range**:
  - Display system logs within a specified time range (`-t` or `--time`).

### Usage

To use `devopsfetch`, run the script with the desired options:

- Display all active ports and services:
    ```bash
    ./devopsfetch.sh -p
    ```

- Provide detailed information about a specific port:
    ```bash
    ./devopsfetch.sh -p <port_number>
    ```

- List all users and their last login times:
    ```bash
    ./devopsfetch.sh -u
    ```

- Provide detailed information about a specific user:
    ```bash
    ./devopsfetch.sh -u <username>
    ```

- List all Docker images and containers:
    ```bash
    ./devopsfetch.sh -d
    ```

- Provide detailed information about a specific container:
    ```bash
    ./devopsfetch.sh -d <container_name>
    ```

- Display all Nginx domains:
    ```bash
    ./devopsfetch.sh -n
    ```

- Provide detailed configuration information for a specific domain:
    ```bash
    ./devopsfetch.sh -n <domain>
    ```

- Display system logs within a specified time range:
    ```bash
    ./devopsfetch.sh -t "2024-07-24 00:00:00" "2024-07-24 23:59:59"
    ```
