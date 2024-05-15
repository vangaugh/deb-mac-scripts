#!/usr/bin/env bash

# UPDATED MAY 24, 2024

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Clear the color after that
clear='\033[0m'

echo "-------------------------------"
echo "-------------------------------"
echo -e "${blue}Current Version Info Follows:${clear}"
echo "-------------------------------"
echo ""
echo -e "${green}Hostname:${clear}\t \t $(hostname)"
echo -e "${green}Kernel version:${clear}\t \t $(uname -r)"
echo -e "${green}Distribution:${clear}\t \t $(lsb_release -d | cut -f2)"
echo -e "${green}Memory information:${clear}\t $(free -h | awk '/Mem/{print $2}')"
echo ""
echo -e "${green}Disk Information:${clear}"
echo -e "$(df -H /)${clear}"
echo ""
echo "------------------------------"
echo -e "     ${blue}Performing updates:${clear}"
echo "------------------------------"
apt clean && apt update && apt full-upgrade -y && apt autoremove -y
echo ""
echo "------------------------------"
echo -e " ${blue}Device Version Info Follows:${clear}"
echo "------------------------------"
echo ""
echo -e "${green}Hostname:${clear} \t \t $(hostname)"
echo -e "${green}Kernel version:${clear}\t \t $(uname -r)"
echo -e "${green}Distribution:${clear}\t \t $(lsb_release -d | cut -f2)"
echo -e "${green}Memory information:${clear}\t $(free -h | awk '/Mem/{print $2}')"
echo ""
echo -e "${green}Disk information: ${clear}"
echo -e "$(df -H /)"
echo ""
echo "------------------------------"
echo -e " ${blue}DEBIAN SERVER HAS BEEN UPDATED ${clear}"
echo "------------------------------"
echo -e "${green}$(date "+%T") \t Server Updated ${clear}"