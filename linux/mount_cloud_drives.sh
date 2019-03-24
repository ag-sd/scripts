#!/bin/bash
rclone --vfs-cache-mode writes mount DropBox: <DOCUMENTS PATH>/rclone/DropBox/ &
rclone --vfs-cache-mode writes mount OneDrive: <DOCUMENTS PATH>/rclone/OneDrive/ &

