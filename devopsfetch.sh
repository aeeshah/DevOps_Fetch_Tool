#!/bin/bash

# Function to display help information
display_help() {
    echo -e "Usage:"
    echo -e "  $0 -p\t\tDisplay all active ports and services"
    echo -e "  $0 -p <port_number>\tDisplay detailed information for a specific port"
    echo -e "  $0 -u\t\tList all users and their last login times"
    echo -e "  $0 -u <username>\tProvide detailed information about a specific user"
    echo -e "  $0 -d\t\tList all Docker images and containers"
    echo -e "  $0 -d <container_name>\tProvide detailed information about a specific Docker container"
    echo -e "  $0 -n\t\t\tDisplay all Nginx domains and their ports"
    echo -e "  $0 -n <domain>\tProvide detailed configuration information for a specific Nginx domain"
    echo -e "  $0 -t <start_time> [end_time]\tDisplay system logs within a specified time range"
    echo -e "  $0 -h | --help\tDisplay help message"
}

# Function to display all active ports and services in the specified format
display_active_ports() {
    echo -e "USER\tPORT\tSERVICE"
    sudo lsof -iTCP -sTCP:LISTEN -P -n | awk 'NR>1 {print $3, $9, $2}' | while read user port pid; do
        port_num=$(echo $port | sed -n 's/.*:\([0-9]*\)/\1/p')
        service=$(ps -p $pid -o comm=)
        echo -e "$user\t$port_num\t$service"
    done
}

# Function to display detailed information for a specific port
display_port_info() {
    local port_number=$1
    echo -e "Information for port $port_number:"
    echo -e "==============================="
    echo -e "USER\tPORT\tSERVICE"
    sudo lsof -iTCP:$port_number -sTCP:LISTEN -P -n | awk 'NR>1 {print $3, $9, $2}' | while read user port pid; do
        port_num=$(echo $port | sed -n 's/.*:\([0-9]*\)/\1/p')
        service=$(ps -p $pid -o comm=)
        echo -e "$user\t$port_num\t$service"
    done
}

# Function to list all users and their last login times
display_all_users() {
    separator="--------------------"
    separator="${separator}${separator}"
    rows="%-15s| %s\n"
    table_width=37

    # Display header with column names
    printf "%-20s| %-20s\n" "USER" "LAST LOGIN"
    printf "%.${table_width}s\n" "$separator"
    
    # Display user details in a formatted table
    lastlog | awk 'NR>1 {printf "%-20s| %s %s %s\n", $1, $4, $5, $6}'
}

# Function to display detailed information about a specific user
display_user_info() {
    local username=$1
    if id "$username" &>/dev/null; then
        user_id=$(id -u "$username")
        group_id=$(id -g "$username")
        last_login=$(lastlog -u "$username" | awk 'NR>1 {print $4 " " $5 " " $6}')

        separator="----------------------------------------"
        rows="%-15s| %7d| %8d| %s\n"
        table_width=44

        printf "%-15s| %7s| %7s| %s\n" "USERNAME" "USER ID" "GROUP ID" "LAST LOGIN"
        printf "%.${table_width}s\n" "$separator"
        printf "$rows" "$username" "$user_id" "$group_id" "$last_login"
    else
        echo -e "User $username does not exist."
    fi
}


# Function to list all Docker images and containers
display_docker_info() {
    separator="-------------------------------------------------------------"
    rows="%-30s| %-20s| %-12s| %s\n"
    table_width=60

    echo -e "DOCKER IMAGES:"
    printf "%-30s| %-20s| %-12s| %s\n" "REPOSITORY" "TAG" "IMAGE ID" "SIZE"
    printf "%.${table_width}s\n" "$separator"
    docker images --format "{{.Repository}}|{{.Tag}}|{{.ID}}|{{.Size}}" | \
    while IFS='|' read -r repo tag id size; do
        printf "$rows" "$repo" "$tag" "$id" "$size"
    done

    echo -e "\nDOCKER CONTAINERS:"
    printf "%-15s| %-30s| %-15s| %-15s\n" "CONTAINER ID" "IMAGE" "NAME" "STATUS"
    printf "%.${table_width}s\n" "$separator"
    docker ps --format "{{.ID}}|{{.Image}}|{{.Names}}|{{.Status}}" | \
    while IFS='|' read -r id image names status; do
        printf "%-15s| %-30s| %-15s| %-15s\n" "$id" "$image" "$names" "$status"
    done
}


# Function to display detailed information about a specific Docker container
display_container_info() {
    local container_name=$1
    if docker ps -q -f name="$container_name" &>/dev/null; then
        separator="-------------------------------------------------------------"
        rows="%-20s| %s\n"
        table_width=60

        echo -e "Details for container $container_name:"
        echo -e "==============================================================="
        printf "%-20s| %s\n" "FIELD" "VALUE"
        printf "%.${table_width}s\n" "$separator"
        
        docker inspect "$container_name" --format '
            Container ID: {{.Id}}
            Image: {{.Image}}
            Status: {{.State.Status}}
            Created: {{.Created}}
            Ports: {{range $p, $conf := .NetworkSettings.Ports}}{{$p}}: {{range $i, $c := $conf}}{{if $i}}, {{end}}{{$c.HostIp}}{{end}}{{end}}
        ' | sed 's/^[ \t]*//; s/[ \t]*$//' | while IFS=':' read -r field value; do
            printf "$rows" "$field" "$value"
        done
    else
        echo -e "Container $container_name does not exist or is not running."
    fi
}


# Function to display all Nginx domains
display_nginx() {
    separator="-------------------------------------------------------------"
    rows="%-40s| %-10s\n"
    table_width=60

    echo -e "NGINX DOMAINS:"
    printf "%-40s| %-10s\n" "Domain" "Proxy" "Config File"
    printf "%.${table_width}s\n" "$separator"

    for file in /etc/nginx/sites-enabled/*; do
        server_name=$(grep -m 1 'server_name' "$file" | awk '{print $2}' | sed 's/;//')
        proxy_pass=$(grep -m 1 'proxy_pass' "$file" | awk '{print $2}' | sed 's/;//')
        printf "$server_name" "$proxy_pass" "$file"
    done


#    grep -r 'server_name' /etc/nginx/sites-enabled/ /etc/nginx/conf.d/ 2>/dev/null | \
 #   awk -F ':' '{print $1}' | \
  #  while read file; do
   #     grep -oP 'server_name\s+\K.*' "$file" | \
    #    tr ' ' '\n' | \
     ##      printf "$rows" "$domain" "$file"
       # done
    
}

# Function to display detailed configuration for a specific Nginx domain
display_nginx_config() {
    local domain=$1
    separator="-------------------------------------------------------------"
    rows="%-40s| %s\n"
    table_width=60

    echo -e "Configuration for domain $domain:"
    printf "%-40s| %s\n" "Server Domain" "CONFIGURATION File" "Proxy"
    printf "%.${table_width}s\n" "$separator"
    grep -E -A 8 "\b$domain\b" /etc/nginx/sites-enabled/* | awk 'NR>2 {print $2, $3, $4}'
}


# Function to display activities within a specified time range
display_time() {
        local start_time=$1
    local end_time=${2:-$(date "+%Y-%m-%d %H:%M:%S")}

    # Validate date format
    date -d "$start_time" "+%Y-%m-%d %H:%M:%S" &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Invalid start date format. Use 'YYYY-MM-DD HH:MM:SS'."
        exit 1
    fi

    date -d "$end_time" "+%Y-%m-%d %H:%M:%S" &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Invalid end date format. Use 'YYYY-MM-DD HH:MM:SS'."
        exit 1
    fi

    if command -v journalctl &>/dev/null; then
        echo -e "System logs from $start_time to $end_time:"
        separator="------------------------------------------------------------------------------------------"
        rows="%-20s| %-10s| %-15s| %s\n"
        table_width=110

        printf "%-20s| %-10s| %-15s| %s\n" "TIME" "USER" "PROCESS" "MESSAGE"
        printf "%.${table_width}s\n" "$separator"

        journalctl --since="$start_time" --until="$end_time" --no-pager | while read -r line; do
            time=$(echo "$line" | awk '{print $1" "$2" "$3}')
            user=$(echo "$line" | awk '{print $4}')
            process=$(echo "$line" | awk '{print $5}' | sed 's/\[.*\]//')
            message=$(echo "$line" | cut -d' ' -f6-)
            printf "$rows" "$time" "$user" "$process" "$message"
        done
    else
        echo -e "journalctl is not available on this system."
    fi
}


# Main script logic
case "$1" in
    -h|--help)
        display_help
        ;;
    -p|--port)
        if [[ -z "$2" ]]; then
            display_active_ports
        else
            display_port_info "$2"
        fi
        ;;
    -u|--user)
        if [[ -z "$2" ]]; then
            display_all_users
        else
            display_user_info "$2"
        fi
        ;;
    -d|--docker)
        if [[ -z "$2" ]]; then
            display_docker_info
        else
            display_container_info "$2"
        fi
        ;;
        
     -n|--nginx)
        if [[ -n $2 ]]; then
            display_nginx  
        else
            display_nginx_config "$2"
                
        fi
        ;;
     -t|--time)
         if [[ $# -lt 2 ]]; then
                echo "Error: Please provide at least the start time."
                display_help
                exit 1
         fi
         start_time=$2
         end_time=$3
         shift 2
         display_time "$start_time" "$end_time"
         exit 0
         ;;
    *)
    
        echo -e "Invalid option. Use -h or --help for usage instructions."
        ;;
esac