#!/usr/bin/bash

# UPDATED MAY 24, 2024 - Installs LEMP STACK (NGINX/PHP8.2-FPM/MARIADB)

# Disable user prompt
DEBIAN_FRONTEND=noninteractive

# Logging
exec   > >(tee -ia post_install.log)
exec  2> >(tee -ia bpost_install.log >& 2)
exec 19> post_install.log

export BASH_XTRACEFD="19"
set -x

# Update list of available packages
apt update -y -q

# Update installed packages
apt full-upgrade -y && apt autoremove -y

# Download Custom Scripts from Github
mkdir -p ~/scripts/cron_scripts

# Install Nginx && PHP-FPM stack
apt install php8.2-memcached php8.2-curl php8.2-fpm php8.2-gd php8.2-mbstring php8.2-mcrypt php8.2-opcache php8.2-xml php8.2-sqlite3 php8.2-mysql php-imagick php-mysql php-json php-gd php-zip php-imap php-mbstring php-curl php-exif php-ldap -y -q

phpenmod imap mbstring

# Create a folder to backup current installation of Nginx && PHP-FPM
now=$(date +"%Y-%m-%d_%H-%M-%S")

# Add custom repository for Nginx
apt-add-repository ppa:hda-me/nginx-stable -y

# Update list of available packages
apt update -y -q

# Install custom Nginx package
apt install nginx -y -q
systemctl unmask nginx.service

# Install Brottli package for Nginx
# https://blog.cloudflare.com/results-experimenting-brotli/
apt install libnginx-mod-http-brotli-filter -y -q

# Disable external access to PHP-FPM scripts
sed -i "s/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/fpm/php.ini

# Create an additional configuration folder for Nginx
mkdir -p /etc/nginx/conf.d

# Download list of bad bots, bad ip's and bad referres
# https://github.com/mitchellkrogza/nginx-badbot-blocker
wget -O /etc/nginx/conf.d/blacklist.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blacklist.conf
wget -O /etc/nginx/conf.d/blockips.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blockips.conf

# Create fastcgi.conf
wget -q O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/3f61ed57ac36df22a3f5bd2a0c3684edb8d0beb7/fastcgi.conf >/etc/nginx/fastcgi.conf

# Create php_fastcgi.conf
wget -q -O -  https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/php_fastcgi.conf > /etc/nginx/snippets/php_fastcgi.conf

# Create ssl.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/ssl.conf > /etc/nginx/snippets/ssl.conf

# Create nginx.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/nginx.conf > /etc/nginx/nginx.conf

# Custom default.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/15b5a2989eea10d5611c9d9b3715f5a7e8add62b/default.conf > /etc/nginx/sites-available/default.conf

# DHPARAM Generation
 openssl dhparam -out /etc/nginx/dhparam.pem 4096

# Unlnk default and Symlink localhost.conf

unlink /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled

# Use md5 hash of your hostname to define a root password for MariDB
password=$(hostname | md5sum | awk '{print $1}')

debconf-set-selections <<<"mariadb-server-10.2 mysql-server/root_password password $password"
debconf-set-selections <<<"mariadb-server-10.2 mysql-server/root_password_again password $password"

# Install MariaDB package
apt install mariadb-server -y -q

# Add custom configuration for your Mysql
# All modified variables are available at https://mariadb.com/kb/en/library/server-system-variables/
echo -e "\n[mysqld]\nmax_connections=24\nconnect_timeout=10\nwait_timeout=10\nthread_cache_size=24\nsort_buffer_size=1M\njoin_buffer_size=1M\ntmp_table_size=8M\nmax_heap_table_size=1M\nbinlog_cache_size=8M\nbinlog_stmt_cache_size=8M\nkey_buffer_size=1M\ntable_open_cache=64\nread_buffer_size=1M\nquery_cache_limit=1M\nquery_cache_size=8M\nquery_cache_type=1\ninnodb_buffer_pool_size=8M\ninnodb_open_files=1024\ninnodb_io_capacity=1024\ninnodb_buffer_pool_instances=1" >>/etc/mysql/my.cnf

# Write down current password for MariaDB in my.cnf
echo -e "\n[client]\nuser = root\npassword = $password" >>/etc/mysql/my.cnf

# MySQL Secure Install
myql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${password}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

# Restart MariaDB
service mysql restart

# Install Mysqltuner for future improvements of MariaDB installation
apt install mysqltuner -y -q

# Create Hello World page
echo -e "<html>\n<body>\n<h1>Hello World!<h1>\n</body>\n</html>" >/var/www/html/index.html

# Create phpinfo page
echo -e "<?php phpinfo(); ?>" > /var/www/html/info.php

# Maximize the limits of file system usage
echo -e "*       soft    nofile  1000000" >>/etc/security/limits.conf
echo -e "*       hard    nofile  1000000" >>/etc/security/limits.conf

# Switch to the ondemand state of PHP-FPM
sed -i "s/^pm = .*/pm = ondemand/" /etc/php/8.2/fpm/pool.d/www.conf

# Use such number of children that will not hurt other parts of the system
# Let's assume that system itself needs 128 MB of RAM
# Let's assume that we let have MariaDB another 256 MB to run
# And finally let's assume that Nginx will need something like 8 MB to run
# On the 1 GB system that leads up to 632 MB of free memory
# If we give one PHP-FPM child a moderate amount of RAM for example 32 MB that will let us create 19 PHP-FPM proccesses at max

# Check median of how much PHP-FPM child consumes with the following command
ps --no-headers -o "rss,cmd" -C php-fpm8.2 | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"M") }'
ram=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
free=$(((ram / 1024) - 128 - 256 - 8))
php=$(((free / 32)))
children=$(printf %.0f $php)
sed -i "s/^pm.max_children = .*/pm.max_children = $children/" /etc/php/8.2/fpm/pool.d/www.conf

# Comment default dynamic mode settings and make them more adequate
sed -i "s/^pm.start_servers = .*/;pm.start_servers = 5/" /etc/php/8.2/fpm/pool.d/www.conf
sed -i "s/^pm.min_spare_servers = .*/;pm.min_spare_servers = 2/" /etc/php/8.2/fpm/pool.d/www.conf
sed -i "s/^pm.max_spare_servers = .*/;pm.max_spare_servers = 2/" /etc/php/8.2/fpm/pool.d/www.conf

# State what amount of request one PHP-FPM child can sustain
sed -i "s/^;pm.max_requests = .*/pm.max_requests = 400/" /etc/php/8.2/fpm/pool.d/www.conf

# State after what amount of time unused PHP-FPM children will stop
sed -i "s/^;pm.process_idle_timeout = .*/pm.process_idle_timeout = 10s;/" /etc/php/8.2/fpm/pool.d/www.conf

# Create a /status path for your webserver in order to track current requests to it
# Use IP/status to check PHP-FPM stats or IP/status?full&html for more detailed results
sed -i "s/^;pm.status_path = \/status/pm.status_path = \/status/" /etc/php/8.2/fpm/pool.d/www.conf

# Create a /ping path for your PHP-FPM installation in order to be able to make heartbeat calls to it
sed -i "s/^;ping.path = \/ping/ping.path = \/ping/" /etc/php/8.2/fpm/pool.d/www.conf

# PHP Settings for vgcrm
sed -i "s/^max_execution_time = 30/max_execution_time = 180/" /etc/php/8.2/fpm/php.ini
sed -i "s/^max_input_time = 60/max_input_time = 180/" /etc/php/8.2/fpm/php.ini
sed -i "s/^memory_limit = 128M/memory_limit = 256M/" /etc/php/8.2/fpm/php.ini
sed -i "s/^post_max_size = 8M/post_max_size = 100M/" /etc/php/8.2/fpm/php.ini
sed -i "s/^upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/8.2/fpm/php.ini

# Enable PHP-FPM Opcache
sed -i "s/^;opcache.enable=0/opcache.enable=1/" /etc/php/8.2/fpm/php.ini

# Set maximum memory limit for OPcache
sed -i "s/^;opcache.memory_consumption=64/opcache.memory_consumption=64/" /etc/php/8.2/fpm/php.ini

# Raise the maximum limit of variable that can be stored in OPcache
sed -i "s/^;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=16/" /etc/php/8.2/fpm/php.ini

# Set maximum amount fo files to be cached in OPcache
sed -i "s/^;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=65536/" /etc/php/8.2/fpm/php.ini

# Enabled using directory path in order to avoid collision between two files with identical names in OPcache
sed -i "s/^;opcache.use_cwd=1/opcache.use_cwd=1/" /etc/php/8.2/fpm/php.ini

# Enable validation of changes in php files
sed -i "s/^;opcache.validate_timestamps=1/opcache.validate_timestamps=1/" /etc/php/8.2/fpm/php.ini

# Set validation period in seconds for OPcache file
sed -i "s/^;opcache.revalidate_freq=2/opcache.revalidate_freq=2/" /etc/php/8.2/fpm/php.ini

# Disable comments to be put in OPcache code
sed -i "s/^;opcache.save_comments=1/opcache.save_comments=0/" /etc/php/8.2/fpm/php.ini

# Enable fast shutdown
sed -i "s/^;opcache.fast_shutdown=0/opcache.fast_shutdown=1/" /etc/php/8.2/fpm/php.ini

# Set period in seconds in which PHP-FPM should restart if OPcache is not accessible
sed -i "s/^;opcache.force_restart_timeout=180/opcache.force_restart_timeout=30/" /etc/php/8.2/fpm/php.ini

wget -q -O - https://gist.githubusercontent.com/vangaugh/10ef5fe18095f958d97f7fae641a4fc5/raw/7442ed39d930c88245595411f0a1ef4ad1894032/cron_log_rotation.sh > ~/scripts/cron_scripts/cron_log_rotation.sh

wget -q -O - https://gist.githubusercontent.com/vangaugh/10ef5fe18095f958d97f7fae641a4fc5/raw/7442ed39d930c88245595411f0a1ef4ad1894032/cron_mysql_optimize.sh > ~/scripts/cron_scripts/cron_mysql_optimize.sh


wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/lemp_restart.sh > ~/scripts/lemp_restart.sh

wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/server_update.sh > ~/scripts/server_update.sh

wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/empty_trash.sh > ~/scripts/empty_trash.sh

chmod +x ~/scripts/*.sh
chmod +x ~/scripts/cron_scripts/*.sh

# Reload Nginx installation
systemctl enable nginx.service
systemctl restart nginx.service
/etc/init.d/nginx reload

# Reload PHP-FPM installation
systemctl enable php8.2-fpm
systemctl restart php8.2-fpm
/etc/init.d/php8.2-fpm reload

# Reload MariaDB installation
systemctl enable mariadb
systemctl restart mariadb
/etc/init.d/mariadb reload

apt clean && apt update && apt full-upgrade -y && apt autoremove -y

echo ""
echo "LEMP Server installed. Reboot the machine!"
echo "mariadb root password = $password"
echo "Password location = /etc/mysql/my.cnf"
echo ""
echo "You should run mysql_secure_install"