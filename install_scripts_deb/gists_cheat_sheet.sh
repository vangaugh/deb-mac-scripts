#!/usr/bin/env bash

# UPDATED MAY 24, 2024

## INSTALL SCRIPTS
#############################################################################################
# deb_core_install.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/822012cd248511bf3ecdfce6b8142642/raw/8694fa2a83b76f1b57967840ad0fe20cc1235d35/debian_core_install.sh > ~/scripts/dev_core_install.sh

# dev_env.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/822012cd248511bf3ecdfce6b8142642/raw/8694fa2a83b76f1b57967840ad0fe20cc1235d35/dev_env.sh > ~/scripts/dev_env.sh

# deb_lemp_server.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/822012cd248511bf3ecdfce6b8142642/raw/8694fa2a83b76f1b57967840ad0fe20cc1235d35/deb_lemp_server.sh > ~/scripts/deb_lemp_server.sh

# dev_server_secure.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/822012cd248511bf3ecdfce6b8142642/raw/8694fa2a83b76f1b57967840ad0fe20cc1235d35/deb_server_secure.sh > ~/scripts/dev_server_secure.sh

## MAC ONLY
#############################################################################################
# .mac_zshrc
wget -q -O - https://gist.githubusercontent.com/vangaugh/8b31c502652cc03edbf5649cecb15fc6/raw/b74c05bf1f6f1b47bae23c9fb8bc12ee7674b57c/.zshrc > ~/.zshrc

# .mac_custom_aliases
wget -q -O - https://gist.githubusercontent.com/vangaugh/8b31c502652cc03edbf5649cecb15fc6/raw/b74c05bf1f6f1b47bae23c9fb8bc12ee7674b57c/.custom_aliases > ~/.custom_aliases

# .mac_nanorc
wget -q -O - https://gist.githubusercontent.com/vangaugh/8b31c502652cc03edbf5649cecb15fc6/raw/b74c05bf1f6f1b47bae23c9fb8bc12ee7674b57c/.nanorc > ~/.nanorc

## DEBIAN LINUX & COMPATIBLE
#############################################################################################
# .deb_zshrc
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/1c025ac7106b8f32e889ee33b15cf42b7801f42a/.zshrc > ~/.zshrc

# .deb_custom_aliases
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/1c025ac7106b8f32e889ee33b15cf42b7801f42a/.custom_aliases > ~/.custom_aliases

# .deb_nanorc
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/1c025ac7106b8f32e889ee33b15cf42b7801f42a/.nanorc > ~/.nanorc

# VGCRM / NGINX FILES / BACKUP SCRIPTS
#############################################################################################
# nginx.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/nginx.conf > /etc/nginx/nginx.conf

# vgcrm.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/vgcrm.conf > /etc/nginx/sites-available/vgcrm.conf

# php_fastcgi.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/php_fastcgi.conf > /etc/nginx/snippets/php_fastcgi.conf

# ssl.conf
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/ssl.conf > /etc/nginx/snippets/ssl.conf

# vgcrm_backup.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/vgcrm_backup.sh > ~/scripts/cron_scripts/vgcrm_backup.sh

# megabackup_crm.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/68c4eb7bd21d195c3fac0c3bfdee55e8/raw/02c6bf168a372e5ced4a993030934f7acf49a466/megabackup_crm.sh > ~/scripts/megabackup_crm.sh

## DEBIAN NGINX / GIT SCRIPTS
#############################################################################################
# lemp_restart.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/lemp_restart.sh > ~/scripts/lemp_restart.sh

# empty_trash.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/empty_trash.sh > ~/scripts/empty_trash.sh

# server_update.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/server_update.sh > ~/scripts/server_update.sh

# git_pull_all.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/2512dc59a5782d87c0ab604eeb4670a5899f3a67/git_pull_all.sh > ~/scripts/git_pull_all.sh

# CRON SCRIPTS
#############################################################################################
# cron_mysql_optimize.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/10ef5fe18095f958d97f7fae641a4fc5/raw/7442ed39d930c88245595411f0a1ef4ad1894032/cron_mysql_optimize.sh > ~/scripts/cron_scripts/cron_mysql_optimize.sh

# cron_log_rotation.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/10ef5fe18095f958d97f7fae641a4fc5/raw/7442ed39d930c88245595411f0a1ef4ad1894032/cron_log_rotation.sh > ~/scripts/cron_scripts/cron_log_rotation.sh
