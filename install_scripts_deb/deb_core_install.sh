#!/usr/bin/env bash

#########################################
## UPDATED SERVER INSTALL SCRIPT - CORE - DEBIAN 12 AND HIGHER
## BY VanGaugh and ro0t3d
## Oct 16, 2024
#########################################

#########################################
# SET SCRIPT VARIABLES AND OTHER ACTIONS
#########################################

# Disable user prompt
DEBIAN_FRONTEND=noninteractive

# Logging
exec > >(tee -ia core-install-post.log)
exec 2> >(tee -ia core-install-post.log >&2)
exec 19>core-install-post.log

export BASH_XTRACEFD="19"
set -x

# Set Color
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

# INPUT SCRIPT VAIABLES
USER=$(logname)
HOME=/home/$USER

# For root control
if [ "$(id -u)" != 0 ]; then
  printf "${RED}"
  cat <<EOL
========================================================================
You are not root! This script must be run as root!
========================================================================
EOL
  printf "${ENDCOLOR}"
  exit 1
fi

# Go TEMP folder
cd /tmp

# Update
printf "\n${BLUE}========================Installing Updating========================${ENDCOLOR}\n"
nala -y update
printf "${GREEN}========================Updated successfully!========================${ENDCOLOR}\n"

# Upgrade
printf "\n${BLUE}===========================Upgrading===========================${ENDCOLOR}\n"
nala -y upgrade && nala -y upgrade && nala autoremove -y
printf "${GREEN}==========================Upgraded successfully!===========================${ENDCOLOR}\n"

# Install standard package
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
  nala
  net-tools
  software-properties-common
  systemd-sysv
  tree
  unzip
  wget
  zip
  zsh

)

printf "\n${BLUE}========================Installing standard package $1========================${ENDCOLOR}\n"
for key in "${essentials[@]}"; do
  echo $key | xargs nala install --no-install-recommends -y -q
done
printf "\n${BLUE}===============Standard packages are installed successfully=============== ${ENDCOLOR}\n"

#########################################
# FUNCTIONS FOR EASY SCRIPTING
#########################################

# Go /tmp
go_temp() {
  cd /tmp
}

# Installation Message
print_installation_message() {
  printf "\n${BLUE}===============================Installing $1==============================${ENDCOLOR}\n"
}

# Installation Success Message
print_installation_message_success() {
  printf "${GREEN}========================$1 is installed successfully!========================${ENDCOLOR}\n"
  go_temp
}

# Document the host information
install_sysinfo() {
  print_installation_message sysinfo
  echo -e "\e[33mStep 1: Documenting host information\e[0m"
  echo "Hostname: $(hostname)"
  echo "Kernel version: $(uname -r)"
  echo "Distribution: $(lsb_release -d | cut -f2)"
  echo "CPU information: $(lscpu | grep 'Model name')"
  echo "Memory information: $(free -h | awk '/Mem/{print $2}')"
  echo "Disk information: $(lsblk | grep disk)"
  echo
  print_installation_message_success sysinfo

}

# Fix SSH keys. First, install OpenSSH server:
install_ssh() {
  print_installation_message SSH
  nala install openssh-server -y -q
  update-rc.d -f ssh remove
  update-rc.d -f ssh defaults

  #Move the old SSH keys somewhere else:
  mkdir -p /etc/ssh/insecure_original_default_keys
  mv /etc/ssh/ssh_host_* /etc/ssh/insecure_original_default_keys/

  #And finally, make new SSH keys for this machine.
  dpkg-reconfigure openssh-server

  #Set ssh to start running on all runlevels:
  update-rc.d -f ssh enable 2 3 4 5

  # Harden SSH Server
  # Remote access and SSH basic settings
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
  print_installation_message_success SSH
}

# Install GIT
install_git() {
  print_installation_message GIT
  nala -y install git
  print_installation_message_success GIT
}

# Install Docker
install_docker() {
  print_installation_message Docker
  nala install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  nala update
  nala -y install docker-ce docker-ce-cli containerd.io
  docker run hello-world
  groupadd docker
  usermod -aG docker $USER
  print_installation_message_success Docker

  print_installation_message docker-compose
  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  docker-compose --version
  print_installation_message_success docker-compose
}

# Install Portainer
install_portainer() {
  print_installation_message Portainer
  docker volume create portainer_data
  docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.3
  echo "Please goto https://10.211.55.26:9443 to access Portainer"

  print_installation_message_success Portainer
}

# Install Oh-My-Zsh
install_ohmyzsh() {
  print_installation_message ohmyzsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  chsh -s $(which zsh) ro0t3d
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  export ZSH_CUSTOM
  print_installation_message_success ohmyzsh
}

# Install Powerlevel10k Theme
install_powerlevel10k() {
  print_installation_message powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}"/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}"/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}"/plugins/zsh-syntax-highlighting
  git clone https://github.com/RobertDeRose/virtualenv-autodetect.git "${ZSH_CUSTOM}"/plugins/virtualenv-autodetect

  # backup .zshrc file
  mkdir -p $HOME/scripts
  mv ~/.zshrc ~/.zshrc.BAK

  # .deb_zshrc
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.zshrc >~/.zshrc

  # .deb_custom_aliases
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.custom_aliases >~/.custom_aliases

  # .p10k Powerlevel10 terminal config
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.p10k.zsh >~/.p10k.zsh

  # .deb_nanorc
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.nanorc >~/.nanorc

  # empty_trash.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/empty_trash.sh >~/scripts/empty_trash.sh

  # server_update.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/server_update.sh >~/scripts/server_update.sh

  # git_pull_all.sh
  wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/git_pull_all.sh >~/scripts/git_pull_all.sh

  cd $HOME
  chmod +x ~/scripts/*.sh
  chown -R $USER:$USER .

  print_installation_message_success powerlevel10k
}

# Install Python and Pip
install_python3() {
  nala install python3 python3-full python3-venv -y -q
  nala install python3-dev python3-pip -y -q

  print_installation_message_success python3
}

# Install colorls
install_colorls() {
  print_installation_message colorls
  nala install ruby ruby-dev -y -q
  gem install colorls
  print_installation_message_success colorls
}

# Install FiraCodeNF Fonts
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

#########################################
# EXECUTE ALL THE CUSTOM FUNCTONS ABOVE
#########################################

# Automatically execute all functions starting with "install_"
for func in $(declare -F | awk '{print $3}' | grep "^install_"); do
  $func
done

printf "\n${GREEN}"

cat <<EOL
===========================================================================
Congratulations, everything you wanted to install is installed!
===========================================================================
EOL
printf "${ENDCOLOR}\n"

cat <<EOL

EOL

printf ${RED}
read -p "Are you going to reboot this machine for stability? (y/n): " -n 1 answer
if [[ $answer =~ ^[Yy]$ ]]; then
  reboot
fi
printf ${ENDCOLOR}

cat <<EOL

EOL
