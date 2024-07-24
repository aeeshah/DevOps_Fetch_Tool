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
sudo systemctl enable docker nginx || error_exit "Failed to enable Docker or Nginx services."
sudo systemctl start docker nginx || error_exit "Failed to start Docker or Nginx services."

# Create the monitoring script
echo "Creating the monitoring script..."
cat << 'EOF' | sudo tee /usr/local/bin/monitor.sh > /dev/null
#!/bin/bash

LOG_FILE="/var/log/system_monitor.log"

# Ensure the log file exists
touch $LOG_FILE

while true; do
    # Log current timestamp
    echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")" >> $LOG_FILE
    
    # Log active ports and services
    echo "Active ports and services:" >> $LOG_FILE
    lsof -iTCP -sTCP:LISTEN -P -n | awk 'NR>1 {print $3, $9, $1}' >> $LOG_FILE
    echo "--------------------------------------------------" >> $LOG_FILE

    # Log Docker containers
    echo "Docker containers:" >> $LOG_FILE
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}" >> $LOG_FILE
    echo "--------------------------------------------------" >> $LOG_FILE

    # Log Nginx domains and configurations
    echo "Nginx domains and configurations:" >> $LOG_FILE
    nginx -T 2>/dev/null | grep -E "server_name|root" >> $LOG_FILE
    echo "--------------------------------------------------" >> $LOG_FILE

    # Log user information and last login times
    echo "User information and last login times:" >> $LOG_FILE
    printf "%-15s | %-10s | %-10s | %-20s\n" "USERNAME" "USER ID" "GROUP ID" "LAST LOGIN" >> $LOG_FILE
    echo "--------------------------------------------------" >> $LOG_FILE

    # Fetch and log user details
    for username in $(cut -d: -f1 /etc/passwd); do
        if id "$username" &>/dev/null; then
            user_id=$(id -u "$username")
            group_id=$(id -g "$username")
            last_login=$(lastlog -u "$username" | awk 'NR>1 {print $4 " " $5 " " $6}')
            printf "%-15s | %-10s | %-10s | %-20s\n" "$username" "$user_id" "$group_id" "$last_login" >> $LOG_FILE
        fi
    done
    echo "--------------------------------------------------" >> $LOG_FILE

    # Sleep for 60 seconds before next iteration
    sleep 60
done
EOF

# Make the monitoring script executable
echo "Making the monitoring script executable..."
sudo chmod +x /usr/local/bin/monitor.sh || error_exit "Failed to make monitor.sh executable."

# Create logrotate configuration
echo "Creating logrotate configuration..."
cat << 'EOF' | sudo tee /etc/logrotate.d/system_monitor > /dev/null
/var/log/system_monitor.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl restart system_monitor.service
    endscript
}
EOF

# Create the systemd service file
echo "Creating the systemd service file..."
cat << 'EOF' | sudo tee /etc/systemd/system/system_monitor.service > /dev/null
[Unit]
Description=System Activity Monitoring Service

[Service]
ExecStart=/usr/local/bin/monitor.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
echo "Reloading systemd and setting up the service..."
sudo systemctl daemon-reload || error_exit "Failed to reload systemd daemon."
sudo systemctl enable system_monitor.service || error_exit "Failed to enable system_monitor service."
sudo systemctl start system_monitor.service || error_exit "Failed to start system_monitor service."

echo "System monitoring setup completed successfully."
