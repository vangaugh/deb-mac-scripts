#!/usr/bin/env bash

## UPDATED SERVER INSTALL SCRIPT - CORE - DEBIAN 12 AND HIGHER
## BY VanGaugh and ro0t3d
## Oct 16, 2024

# Set Color
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

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

# Get USER name
USER=$(logname)

# Get HOME folder path
HOME=/home/$USER

# Go TEMP folder
cd /tmp

# Update
printf "\n${BLUE}========================Installing Updating========================${ENDCOLOR}\n"
apt-get -y update
printf "${GREEN}========================Updated successfully!========================${ENDCOLOR}\n"

# Upgrade
printf "\n${BLUE}===========================Upgrading===========================${ENDCOLOR}\n"
apt-get -y upgrade && apt-get -y full-upgrade && apt-get autoremove -y
printf "${GREEN}==========================Upgraded successfully!===========================${ENDCOLOR}\n"

# Install standard package
declare -A essential
essentials=(
  software-properties-common
  build-essential
  module-assistant
  dkms
  apt-transport-https
  ca-certificates
  curl
  nano
  gnupg
  lsb-release
  wget
  dialog
  tree
  zsh
  htop
  zip
  unzip
  net-tools
  apt-utils

)

printf "\n${BLUE}========================Installing standard package $1========================${ENDCOLOR}\n"
for key in "${essentials[@]}"; do
  echo $key | xargs apt-get install -y
done
printf "\n${BLUE}===============Standard packages are installed successfully=============== ${ENDCOLOR}\n"

# Go /tmp
go_temp() {
  cd /tmp
}

# Cleanup
clean-up() {
  print_installation_message clean-up
  sudo apt -f install &&
    sudo apt -y autoremove &&
    sudo apt -y autoclean &&
    sudo apt -y clean &&
    rm -rf .zshrc.pre-oh-my-zsh .zshrc.BAK .bash_history .bash_logout .bashrc
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

## Main script and installation candidates

# Fix SSH keys. First, install OpenSSH server:
install_ssh() {
  print_installation_message SSH
  apt install openssh-server -y -q
  update-rc.d -f ssh remove
  update-rc.d -f ssh defaults

  #Move the old SSH keys somewhere else:
  mkdir -p /etc/ssh/insecure_original_default_keys
  mv /etc/ssh/ssh_host_* /etc/ssh/insecure_original_default_keys/

  #And finally, make new SSH keys for this machine.
  dpkg-reconfigure openssh-server

  #Set ssh to start running on all runlevels:
  update-rc.d -f ssh enable 2 3 4 5
  print_installation_message_success SSH

}

# GIT
install_git() {
  print_installation_message GIT
  apt -y install git
  print_installation_message_success GIT
}

# OpenJDK
install_openJDK() {
  print_installation_message OpenJDK
  apt -y install default-jdk
  print_installation_message OpenJDK

}

# ORACLE JAVA JDK 18 &  ORACLE JAVA JDK 21 & ORACLE JAVA JDK 17 && SPRING BOOT CLI
install_javaJDK() {
  print_installation_message JAVA-JDK-18
  wget https://download.oracle.com/java/18/latest/jdk-18.0.2_linux-x64_bin.tar.gz
  mkdir /usr/local/java/
  tar xf jdk-18.0.2_linux-x64_bin.tar.gz -C /usr/local/java/
  update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk-18.0.2/bin/java" 1
  update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk-18.0.2/bin/javac" 1
  update-alternatives --set java /usr/local/java/jdk-18.0.2/bin/java
  update-alternatives --set javac /usr/local/java/jdk-18.0.2/bin/javac
  echo -e '\n# JAVA Configuration' >>$HOME/.profile
  echo 'JAVA_HOME=/usr/local/java/jdk-18.0.2/bin/java' >>$HOME/.profile
  source $HOME/.profile
  print_installation_message_success JAVA-JDK-18
  print_installation_message JAVA-JDK-21
  wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
  tar xf jdk-21_linux-x64_bin.tar.gz -C /usr/local/java/
  update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk-21/bin/java" 2
  update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk-21/bin/javac" 2
  print_installation_message_success JAVA-JDK-21
}

install_docker() {
  print_installation_message Docker
  apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update
  apt-get -y install docker-ce docker-ce-cli containerd.io
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

# Powerlevel10k Theme
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
  apt install python3 python3-full python3-venv -y -q
  apt install python3-dev python3-pip -y -q

  # Upgrade pip
  python3 -m pip install --upgrade pip

  # Direnv
  # https://www.willandskill.se/sv/articles/install-direnv-on-ubuntu-18-04-in-1-min
  # https://github.com/RobertDeRose/virtualenv-autodetect

  # Create virtual environment
  # python3 -m venv venv && echo layout virtualenv $PWD  > .envrc

  print_installation_message_success python3

}

# Install colorls
install_colorls() {
  print_installation_message colorls
  apt install ruby ruby-dev -y -q
  gem install colorls
  print_installation_message_success colorls
}

# Install FiraCodeNF
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

# Automatically execute all functions starting with "install_"
for func in $(declare -F | awk '{print $3}' | grep "^install_"); do
  $func
done

printf "\n${BLUE}===============Installing Dependencies========================${ENDCOLOR}\n"
# Install dependencies & Cleanup
clean-up
printf "${GREEN}===============Dependencies are installed successfully!===============${ENDCOLOR}\n"

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
