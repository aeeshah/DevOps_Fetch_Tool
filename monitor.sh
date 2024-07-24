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

    # Sleep for 5mins minutes before next iteration
    sleep 300
done
