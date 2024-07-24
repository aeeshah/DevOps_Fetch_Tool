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
