#!/usr/bin/env bash

# RESTARTS LEMP SERVER (NGINX / MARIADB / PHP-FPM

# Execute Commands
sudo /etc/init.d/nginx restart && 
sudo /etc/init.d/php8.2-fpm restart &&
sudo /etc/init.d/mariadb restart

echo "---------------------------------------------------------------------------------"
echo -e "\n\033[32m Server Restart Complete!\033[0m\n"
