## Crontab Scripts - Debian

These are scripts to faciliate cronjobs on a Debian server.

Add these to crontab -e

<code>45 23 * * * bash /root/scripts/cron_scripts/cron_mysql_optimize.sh >/dev/null 2>&1</code><br>
<code>0 18 * * * bash /root/scripts/cron_scripts/cron_log_rotation.sh >/dev/null 2>&1</code>