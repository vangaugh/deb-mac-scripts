#!/usr/bin/env bash

# UPDATED MAY 12, 2024

#######################################
# Hardening script for Ubuntu and Debian by headintheclouds
# Date Sept 10, 2023
#######################################

# Disable user prompt
DEBIAN_FRONTEND=noninteractive

# Step 1: Document the host information
echo -e "\e[33mStep 1: Documenting host information\e[0m"
echo "Hostname: $(hostname)"
echo "Kernel version: $(uname -r)"
echo "Distribution: $(lsb_release -d | cut -f2)"
echo "CPU information: $(lscpu | grep 'Model name')"
echo "Memory information: $(free -h | awk '/Mem/{print $2}')"
echo "Disk information: $(lsblk | grep disk)"
echo

# Step 2: BIOS protection
echo -e "\e[33mStep 2: BIOS protection\e[0m"
echo "Checking if BIOS protection is enabled..."
if [ -f /sys/devices/system/cpu/microcode/reload ]; then
  echo "BIOS protection is enabled"
else
  echo "BIOS protection is not enabled"
fi
echo ""

# Step 3: Hard disk encryption
echo -e "\e[33mStep 3: Hard disk encryption\e[0m"
echo "Checking if hard disk encryption is enabled..."
if [ -d /etc/luks ]; then
  echo "Hard disk encryption is enabled"
else
  echo "Hard disk encryption is not enabled"
fi
echo ""

# Step 4: Disk partitioning
echo -e "\e[33mStep 4: Disk partitioning\e[0m"
echo "Checking if disk partitioning is already done..."
if [ -d /home -a -d /var -a -d /usr ]; then
  echo "Disk partitioning is already done"
else
  echo "Disk partitioning is not done or incomplete"
fi
fdisk /dev/sda
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mount /dev/sda1 /mnt
echo

# Step 5: Lock the boot directory
echo -e "\e[33mSstep 5: Lock the boot directory\e[0m"
echo "Locking the boot directory..."
chmod 700 /boot
echo ""

# Step 6: Disable USB usage
echo -e "\e[33mStep 6: Disable USB usage\e[0m"
echo "Disabling USB usage..."
echo 'blacklist usb-storage' | tee /etc/modprobe.d/blacklist-usbstorage.conf
echo ""

# Step 7: Update your system
echo -e "\e[33mStep 7: Updating your system\e[0m"
nala update && nala upgrade -y -q
echo ""

# Step 8: Check the installed packages
echo -e "\e[33mStep 8: Checking the installed packages\e[0m"
dpkg --get-selections | grep -v deinstall
echo ""

# Step 9: Check for open ports
echo -e "\e[33mStep 9: Checking for open ports\e[0m"
netstat -tulpn
echo ""

# Step 10: Secure SSH
#echo -e "\e[33mStep 10: Securing SSH\e[0m"
# sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
# sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# systemctl restart sshd
#echo

# Step 11: Enable SELinux
echo -e "\e[33mStep 11: Enabling SELinux\e[0m"
echo "Checking if SELinux is installed..."
if [ -f /etc/selinux/config ]; then
  echo "SELinux is already installed"
else
  echo "SELinux is not installed, installing now..."
  nala install selinux-utils selinux-basics -y -q
fi
echo "Enabling SELinux..."
selinux-activate
echo ""

# Step 12: Set network parameters
echo -e "\e[33mStep 12: Setting network parameters\e[0m"
echo "Setting network parameters..."
sysctl -p
echo ""

# Step 13: Manage password policies
echo -e "\e[33mStep 13: Managing password policies\e[0m"
echo "Modifying the password policies..."
sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/g' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/g' /etc/login.defs
sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t14/g' /etc/login.defs
echo ""

# Step 14: Permissions and verifications
echo -e "\e[33mStep 14: Permissions and verifications\e[0m"
echo "Setting the correct permissions on sensitive files..."
chmod 700 /etc/shadow /etc/gshadow /etc/passwd /etc/group
chmod 600 /boot/grub/grub.cfg
chmod 644 /etc/fstab /etc/hosts /etc/hostname /etc/timezone /etc/bash.bashrc
echo "Verifying the integrity of system files..."
debsums -c
echo ""

# Step 15: Additional distro process hardening
echo -e "\e[33mStep 15: Additional distro process hardening\e[0m"
echo "Disabling core dumps..."
echo '* hard core 0' | tee /etc/security/limits.d/core.conf
echo "Restricting access to kernel logs..."
chmod 640 /var/log/kern.log
echo "Setting the correct permissions on init scripts..."
chmod 700 /etc/init.d/*
echo ""

# Step 16: Remove unnecessary services
echo -e "\e[33mStep 16: Removing unnecessary services\e[0m"
echo "Removing unnecessary services..."
nala purge rpcbind rpcbind-* -y -q
nala purge nis -y -q
echo ""

# Step 17: Check for security on key files
echo -e "\e[33mStep 17: Checking for security on key files\e[0m"
echo "Checking for security on key files..."
find /etc/ssh -type f -name 'ssh_host_*_key' -exec chmod 600 {} \;
echo ""

# Step 18: Limit root access using
echo -e "\e[33mStep 18: Limiting root access using \e[0m"
echo "Limiting root access using ..."
nala install -y -q
groupadd admin
usermod -a -
sed -i 's/%\tALL=(ALL:ALL) ALL/%admin\tALL=(ALL:ALL) ALL/g' /etc/ers
echo ""

# Step 19: Only allow root to access CRON
echo -e "\e[33mStep 19: Restricting access to CRON\e[0m"
echo "Only allowing root to access CRON..."
chmod 600 /etc/crontab
chown root:root /etc/crontab
chmod 600 /etc/crontab
chmod 600 /etc/cron.hourly/*
chmod 600 /etc/cron.daily/*
chmod 600 /etc/cron.weekly/*
chmod 600 /etc/cron.monthly/*
chmod 600 /etc/cron.d/*
echo ""

# Step 20: Remote access and SSH basic settings
echo -e "\e[33mStep 20: Remote access and SSH basic settings\e[0m"
echo "Disabling root login over SSH..."
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "Disabling password authentication over SSH..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "Disabling X11 forwarding over SSH..."
sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
echo "Reloading the SSH service..."
systemctl reload sshd
echo ""

# Step 21: Disable Xwindow
echo -e "\e[33mStep 21: Disabling Xwindow\e[0m"
echo "Disabling Xwindow..."
systemctl set-default multi-user.target
echo ""

# Step 22: Minimize Package Installation
echo -e "\e[33mStep 22: Minimizing Package Installation\e[0m"
echo "Installing only essential packages..."
nala install --no-install-recommends -y -q systemd-sysv apt-utils
nala --purge autoremove -y -q
echo ""

# Step 23: Checking accounts for empty passwords
echo -e "\e[33mStep 23: Checking accounts for empty passwords\e[0m"
echo "Checking for accounts with empty passwords..."
awk -F: '($2 == "" ) {print}' /etc/shadow
echo ""

# Step 24: Monitor user activities
echo -e "\e[33mStep 24: Monitoring user activities\e[0m"
echo "Installing auditd for user activity monitoring..."
nala install auditd -y -q
echo "Configuring auditd..."
echo "-w /var/log/auth.log -p wa -k authentication" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/passwd -p wa -k password-file" | tee -a /etc/audit/rules.d/audit.rules
echo "-w /etc/group -p wa -k group-file" | tee -a /etc/audit/rules.d/audit.rules
systemctl restart auditd
echo ""

# Step 25: Install and configure fail2ban
echo -e "\e[33mStep 25: Installing and configuring fail2ban\e[0m"
echo "Installing fail2ban..."
nala install fail2ban -y -q
echo "Configuring fail2ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime  = 10m/bantime  = 1h/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban
echo ""

# Step 26: Rootkit detection
echo -e "\e[33mStep 26: Installing and running Rootkit detection...\e[0m"
nala install rkhunter
rkhunter --update
rkhunter --propupd
rkhunter --check
echo

# Step 27: Monitor system logs
echo -e "\e[33mStep 27: Monitoring system logs\e[0m"
echo "Installing logwatch for system log monitoring..."
nala install logwatch -y -q
echo ""

echo -e "\e[32mHardening complete!\e[0m"
