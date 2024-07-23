# Devopsfetch

`devopsfetch` is a versatile bash script for DevOps tasks that includes functionality to display system information, manage Docker containers, and handle Nginx configurations. It also supports querying system logs based on date ranges.

## Features

- **Port Information**
  - List all active ports and services
  - Display detailed information about a specific port

- **Users Information**
  - List all users and their last login times
  - Provide detailed information about a specific user

- **Docker Information**
  - List all Docker images and containers
  - Provide detailed information about a specific container

- **Nginx Information**
  - Display all Nginx domains
  - Provide detailed configuration information for a specific domain

- **Time Range**
  - Display system logs within a specified time range

## Requirements

- `bash`
- `journalctl` (Linux) or equivalent system logging command
- `docker` (for Docker-related commands)
- `nginx` (for Nginx-related commands)

## Usage

### Port Information

- List all active ports and services:
  ```bash
  ./devopsfetch.sh -p
  ```

- Display detailed information about a specific port:
  ```bash
  ./devopsfetch.sh -p <port_number>
  ```

### Users Information

- List all users and their last login times:
  ```bash
  ./devopsfetch.sh -u
  ```

- Provide detailed information about a specific user:
  ```bash
  ./devopsfetch.sh -u <username>
  ```

### Docker Information

- List all Docker images and containers:
  ```bash
  ./devopsfetch.sh -d
  ```

- Provide detailed information about a specific container:
  ```bash
  ./devopsfetch.sh -d <container_name>
  ```

### Nginx Information

- Display all Nginx domains:
  ```bash
  ./devopsfetch.sh -n
  ```

- Provide detailed configuration information for a specific domain:
  ```bash
  ./devopsfetch.sh -n <domain>
  ```

### Time Range

- Display system logs within a specified time range:
  ```bash
  ./devopsfetch.sh -t <start_date> [end_date]
  ```

  - Example for a single day:
    ```bash
    ./devopsfetch.sh -t 2024-07-23
    ```

  - Example for a date range:
    ```bash
    ./devopsfetch.sh -t 2024-07-18 2024-07-22
    ```

### Help

- Display help message:
  ```bash
  ./devopsfetch.sh -h
  ```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/aeeshah/DevOps_Fetch_Tool
   ```

2. Navigate to the directory:
   ```bash
   cd devopsfetch
   ```

3. Make the script executable:
   ```bash
   chmod +x devopsfetch.sh
   ```

**Note:** The `devopsfetch` script is designed for use on Linux systems and may require modifications to work on other operating systems.

```
