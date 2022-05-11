#!/bin/bash

# -----------------------------------------------------------------------------
# Use crontab for execute this script daily/monthly
# Make backup for /var/www/vhosts/moodledata en /root/moodledata-date
# Make db backup complete
# Upload to GDrive with rclone
# -----------------------------------------------------------------------------

# Start
backups_log=/root/backups_log.txt
backup_name=$( date "+%Y-%m-%d-%H:%M:%S-moodle.tar.gz")
dbsql_name= $( date "+%Y-%m-%d-%H:%M:%S-moodle.sql")
echo "---------------------" >> $backups_log
echo $(date "+[%Y-%m-%d %H:%M:%S] New backup") >> $backups_log

if mountpoint -q /tmp/mount_point ; then
	# Stop apache service
	echo $(date "+[%Y-%m-%d %H:%M:%S] Stopping services") >> $backups_log
	systemctl stop apache2
	#

	echo $(date "+[%Y-%m-%d %H:%M:%S] Creating tar.gz /var/www/vhosts/moodledata") >> $backups_log
	tar -czvf /tmp/mount_point/$backup_name /var/www/vhosts/moodledata >> /dev/null

	# Mysqldump to database
	echo $(date "+[%Y-%m-%d %H:%M:%S] Creating .sqp /root/$dbsql_name") >> $backups_log
	mysqldump --add-drop-database --add-drop-table --add-drop-trigger --databases moodle >> /tmp/mount_point/$nombresql
	#

	# Start apache service
	echo $(date "+[%Y-%m-%d %H:%M:%S] Starting services") >> $backups_log
	systemctl start apache2

	# Upload to drive with rclone
	echo $(date "+[%Y-%m-%d %H:%M:%S] Uploading to drive") >> $backups_log
	rclone move drive/mount_point/$backup_name drive:backup
	rclone move drive/mount_point/$dbsql_name drive:backup

	echo $(date "+[%Y-%m-%d %H:%M:%S] End backup :)") >> $backups_log
else
	# If /tmp/mount_point is not a mountpoint
	echo $(date "+[%Y-%m-%d %H:%M:%S] Backup not done") >> $backups_log
	echo $(date "+[%Y-%m-%d %H:%M:%S] Fin de backup :(") >> $backups_log
fi

rclone sync backups_log.txt	drive/mount_point
