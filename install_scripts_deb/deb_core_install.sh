#!/usr/bin/env bash

#########################################
## UPDATED SERVER INSTALL SCRIPT - CORE - DEBIAN 12 AND HIGHER
## BY VanGaugh and ro0t3d
## Oct 16, 2024
#########################################

#########################################
# SET SCRIPT VARIABLES AND OTHER ACTIONS
#########################################

# DISABLE USER PROMPT
DEBIAN_FRONTEND=noninteractive

# SET COLOR
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
PURPLE="e[35m"
CYAN="e[36m"
ENDCOLOR="\e[0m"

# INPUT SCRIPT VAIABLES
USER=$(logname)
HOME=/home/$USER

# RUN SCRIPT AS ROOT
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

# GO TO TEMP FOLDER
cd /tmp

# INSTALL NALA PACKAGE MANAGER
sudo apt update &&
sudo apt install nala -y &&
sudo nala update -y &&
sudo nala upgrade -y

# INSTALL STANDARD ESSENTIAL CORE PACKAGES
declare -A essential
essentials=(
  apt-transport-https
  apt-utils
  build-essential
  ca-certificates
  curl
  dialog
  dkms
  gnupg
  htop
  lsb-release
  module-assistant
  nano
  net-tools
  software-properties-common
  systemd-sysv
  tar
  tree
  unzip
  wget
  zip
  zsh
)

printf "\n${CYAN}======================== INSTALLING ESSENTIAL PACKAGE $1 ========================${ENDCOLOR}\n"
for key in "${essentials[@]}"; do
  echo $key | xargs nala install --no-install-recommends -y
done
printf "\n${CYAN}=============== ESSENTIAL PACKAGES INSTALLED $1 =============== ${ENDCOLOR}\n"

#########################################
# FUNCTIONS FOR EASY SCRIPTING
#########################################

# INSTALLATION MESSAGE
print_installation_message() {
  printf "\n${BLUE}=============================== INSTALLING $1 ==============================${ENDCOLOR}\n"
}

# NALA FULL UPDATE MESSAGE
print_nala_update_message() {
  printf "\n${YELLOW}=============================== $1 IS UPDATING! ==============================${ENDCOLOR}\n"
}

# NALA UPGRADE MESSAGE
print_nala_upgrade_message() {
  printf "\n${YELLOW}=============================== $1 IS UPGRADING! ==============================${ENDCOLOR}\n"
}

# NALA UPDATE/UPGRADE COMPLETED SUCCESSFULLY MESSAGE
print_nala_update_success() {
  printf "\n${GREEN}=============================== $1 IS DONE UPDATING/UPRADING! ==============================${ENDCOLOR}\n"
}

# INSTALLATION MESSAGE SUCCESS
print_installation_message_success() {
  printf "\n${GREEN}======================== $1 INSTALLED SUCCESSFULLY! ========================${ENDCOLOR}\n"
  go_temp
}

# NALA CLEANUP/FIX MESSAGE
print_nala_cleanup_message() {
  printf "\n${PINK}=============================== $1 IS CLEANING UP SYSTEM! ==============================${ENDCOLOR}\n"
}

# NALA CLEANUP/FIX MESSAGE
print_nala_cleanup_message_success() {
  printf "\n${PINK}=============================== $1 SUCCESSULLY CLEANED UP THE SYSTEM! ==============================${ENDCOLOR}\n"
}

# GOTO TEMP FOLDER
go_temp() {
  cd /tmp
}

# REBOOT MACHINE
reboot_now() { 
    sudo shutdown -r now
}

# NALA UPDATE
nala_update() {
  print_nala_update_message NALA
  sudo nala clean &&
  sudo nala update
  
  print_nala_update_success NALA
}

# NALA FULL UPGRADE
nala_upgrade() {
  print_nala_upgrade_message NALA
  sudo nala upgrade -y &&
  sudo nala autoremove -y
  
  print_nala_update_success NALA
}

# NALA CLEANUP
nala_cleanup() {
  print_nala_cleanup_message NALA
  sudo nala install --fix-broken -y &&
    sudo nala autoremove -y &&
    sudo nala autopurge -y &&
    sudo nala clean
  
  print_nala_cleanup_message_success NALA
}

# DOCUMENT THE HOST IMFORMATION
sysinfo() {
  print_installation_message sysinfo
  echo "1: Documenting host information"
  echo "Hostname: $(hostname)"
  echo "Kernel version: $(uname -r)"
  echo "Distribution: $(lsb_release -d | cut -f2)"
  echo "CPU information: $(lscpu | grep 'Model name')"
  echo "Memory information: $(free -h | awk '/Mem/{print $2}')"
  echo "Disk information: $(lsblk | grep disk)"
  echo ""
  
  print_installation_message_success sysinfo
}

#########################################
# INSTALLTION FUNCTIONS START
#########################################

# INSTALL OPENSSH SERVER:
install_ssh() {
  print_installation_message SSH
  nala install openssh-server -y
  update-rc.d -f ssh remove
  update-rc.d -f ssh defaults

  # MOVE OLD SSH KEYS:
  mkdir -p /etc/ssh/insecure_original_default_keys
  mv /etc/ssh/ssh_host_* /etc/ssh/insecure_original_default_keys/

  # CREATE NEW SSH KEYS
  dpkg-reconfigure openssh-server

  # SSH TO RUN AT ALL LEVELS:
  update-rc.d -f ssh enable 2 3 4 5

  # SETUP AUTHORIZED KEYS FOR SSH ACCESS
  mkdir -p $HOME/.ssh
  touch $HOME/.ssh/authorized_keys
  chown -R $USER:$USER $HOME/.ssh
  
  print_installation_message_success SSH

  # SSH BASIC SETTINGS
  print_installation_message SSH Basic Settings
  echo "Disabling root login over SSH..."
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  #echo "Disabling password authentication over SSH..."
  #sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  echo "Disabling X11 forwarding over SSH..."
  sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
  echo "Reloading the SSH service..."
  systemctl reload sshd
  echo ""
  print_installation_message_success SSH Basic Settings
}

# INSTALL git
install_git() {
  print_installation_message GIT
  nala install git -y
  print_installation_message_success GIT
}

# INSTALL docker
install_docker() {
  print_installation_message Docker
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  nala update
  nala install docker-ce docker-ce-cli containerd.io -y
  groupadd docker
  usermod -aG docker $USER
  print_installation_message_success Docker

  # INSTALL docker-compose
 print_installation_message docker-compose
  curl -L "https://github.com/docker/compose/releases/download/2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  docker-compose --version
  print_installation_message_success docker-compose
}

# INSTALL portainer
install_portainer() {
  print_installation_message Portainer
  docker volume create portainer_data
  docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.3
  print_installation_message_success Portainer
}

# INSTALL oh-my-zsh
install_ohmyzsh() {
  print_installation_message ohmyzsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  chsh -s $(which zsh) $USER
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  export ZSH_CUSTOM
  print_installation_message_success ohmyzsh
}

# INSTALL Powerlevel10k Theme & PULL ZSH CONFIGURATION
install_powerlevel10k() {
  print_installation_message powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}"/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}"/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}"/plugins/zsh-syntax-highlighting
  git clone https://github.com/RobertDeRose/virtualenv-autodetect.git "${ZSH_CUSTOM}"/plugins/virtualenv-autodetect

  # BACKUP .zshrc file
  mv ~/.zshrc ~/.zshrc.BAK

  # PULL .deb_zshrc
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.zshrc >~/.zshrc

  # PULL .deb_custom_aliases
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.custom_aliases >~/.custom_aliases

  # PULL .p10k Powerlevel10 terminal config
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.p10k.zsh >~/.p10k.zsh

  # PULL .deb_nanorc
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.nanorc >~/.nanorc

  # PULL empty_trash.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/empty_trash.sh >~/scripts/empty_trash.sh

  # PULL server_update.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/server_update.sh >~/scripts/server_update.sh

  # PULL git_pull_all.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/git_pull_all.sh >~/scripts/git_pull_all.sh

  cd $HOME
  chmod +x ~/scripts/*.sh
  chown -R $USER:$USER .;

  print_installation_message_success powerlevel10k
}

# INSTALL Python & Pip
install_python3() {
  print_installation_message python3
  nala install python3 python3-full python3-venv -y
  nala install python3-dev python3-pip -y
 print_installation_message_success python3
}

# INSTALL colorls
install_colorls() {
 print_installation_message colorls
  nala install ruby ruby-dev -y
  gem install colorls
 print_installation_message_success colorls
}

# INSTALL FiraCodeNF Fonts
install_FiraCodeNF() {
 print_installation_message FiraCodeNF
  rm -rf /usr/local/share/fonts/FiraCodeNF
  mkdir -p /usr/local/share/fonts/FiraCodeNF
  cd /usr/local/share/fonts/FiraCodeNF
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
  unzip FiraCode.zip
  rm -rf *.zip
  cd /usr/local/share/fonts/
  fc-cache -f
  go_temp
  print_installation_message_success FiraCodeNF
}

# END OF INSTALLATION FUNCTIONS LIST
#########################################

#########################################
# EXECUTE ALL THE CUSTOM FUNCTONS
#########################################

# Automatically execute all functions starting with "install_"
for func in $(declare -F | awk '{print $3}' | grep "^install_"); do
  $func
done

printf "\n${GREEN}"

cat <<EOL
===========================================================================
ALL INSTALLATIONS COMPLETE
===========================================================================
EOL
printf "${ENDCOLOR}\n"

cat <<EOL

EOL

#########################################
# CLEANUP SYSTEM
#########################################
install_nala_cleanup &&
rm -rf ~/.{zshrc.pre-oh-my-zsh,zshrc.BAK,bash_history,bash_logout,bashrc}

#########################################
# SYSTEM REBOOT FOR CHANGES TO TAKE EECT
#########################################
printf ${RED}
read -p "Would you like to reboot the system? (y/n): " -n 1 answer
if [[ $answer =~ ^[Yy]$ ]]; then
  reboot_now
fi
printf ${ENDCOLOR}

#########################################
# END OF SCRIPT
#########################################
