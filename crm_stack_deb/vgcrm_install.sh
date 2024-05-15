apt install php8.2-mysql php8.2-json php8.2-gd php8.2-zip php8.2-imap php8.2-mbstring php8.2-curl php8.2-exif php8.2-ldap

sudo apt install -y php8.2-cli php8.2-dev php8.2-pgsql php8.2-sqlite3 php8.2-gd php8.2-curl php8.2-memcached php8.2-imap php8.2-mysql php8.2-mbstring php8.2-xml php8.2-imagick php8.2-zip php8.2-bcmath php8.2-soap php8.2-intl php8.2-readline php8.2-common php8.2-pspell php8.2-tidy php8.2-xmlrpc php8.2-xsl php8.2-opcache


cd <PATH-TO-ESPOCRM-DIRECTORY>
find . -type d -exec chmod 755 {} + && find . -type f -exec chmod 644 {} +;
find data custom client/custom -type d -exec chmod 775 {} + && find data custom client/custom -type f -exec chmod 664 {} +;
chmod 775 application/Espo/Modules client/modules;
chmod 754 bin/command;

cd <PATH-TO-ESPOCRM-DIRECTORY>
chown -R <OWNER>:<GROUP-OWNER> .;

# PHP.INI
max_execution_time = 180
max_input_time = 180
memory_limit = 256M
post_max_size = 50M
upload_max_filesize = 50M