#!/usr/bin/env bash

# UPDATED MAY 24, 2024

# Execute Commands
/etc/init.d/nginx restart && /etc/init.d/php8.2-fpm restart && /etc/init.d/mariadb restart

echo -e "\n\033[32m Server Restart Complete!\033[0m\n"