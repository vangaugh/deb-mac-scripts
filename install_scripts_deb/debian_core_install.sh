#!/usr/bin/env bash

# DEBIAN CORE INSTALL

# Disable user prompt
DEBIAN_FRONTEND=noninteractive

exec   > >(tee -ia core_install.log)
exec  2> >(tee -ia core_install.log >& 2)
exec 19> core_install.log

export BASH_XTRACEFD="19"
set -x

# Make Directories
mkdir -p ~/Projects/
mkdir -p ~/dotfiles
mkdir -p ~/scripts
mkdir -p ~/backups

# Update list of available packages
apt autoclean && apt update -y -q

# Update installed packages
apt full-upgrade -y && apt autoremove -y

# Install the most common packages that will be usefull under development environment
apt install zip unzip git curl wget zsh net-tools fail2ban htop sqlite3 nload mlocate nano apt-utils software-properties-common build-essential -y -q

# Fix SSH keys. First, install OpenSSH server:
apt install openssh-server -y -q
update-rc.d -f ssh remove
update-rc.d -f ssh defaults

#Move the old SSH keys somewhere else:
# mkdir -p /etc/ssh/insecure_original_default_keys
# mv /etc/ssh/ssh_host_* /etc/ssh/insecure_original_default_keys/

#And finally, make new SSH keys for this machine.
dpkg-reconfigure openssh-server

#Set ssh to start running on all runlevels:
update-rc.d -f ssh enable 2 3 4 5

# Add non root users (sudo permissions)
useradd -m vangaugh
passwd vangaugh

# Add user to sudo group
usermod -a -G sudo vangaugh

# Install Python and Pip
apt install python3 python3-full python3-venv -y -q
apt install python3-dev python3-pip -y -q

# Upgrade pip
# python3 -m pip install --upgrade pip

# Direnv
# https://www.willandskill.se/sv/articles/install-direnv-on-ubuntu-18-04-in-1-min
# https://github.com/RobertDeRose/virtualenv-autodetect

# Create virtual environment
# python3 -m venv venv && echo layout virtualenv $PWD  > .envrc

# Install Requirements
# python3 -m pip install -r requirements.txt

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
chsh -s $(which zsh)

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
export ZSH_CUSTOM

# Powerlevel10k Theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}"/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}"/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}"/plugins/zsh-syntax-highlighting
git clone https://github.com/RobertDeRose/virtualenv-autodetect.git "${ZSH_CUSTOM}"/plugins/virtualenv-autodetect

# backup .zshrc file
mv ~/.zshrc ~/.zshrc.BAK

# .deb_zshrc
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.zshrc > ~/.zshrc

# .deb_custom_aliases
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.custom_aliases > ~/.custom_aliases

# .deb_nanorc
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/zsh_dotfiles_deb/.nanorc > ~/.nanorc

# empty_trash.sh
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/empty_trash.sh > ~/scripts/empty_trash.sh

# server_update.sh
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/server_update.sh> ~/scripts/server_update.sh

# git_pull_all.sh
wget -q -O - https://raw.githubusercontent.com/vangaugh/deb-mac-scripts/main/maint_scripts_deb/git_pull_all.sh > ~/scripts/git_pull_all.sh

chmod +x ~/scripts/*.sh
cd $HOME

# Install colorls
apt install ruby ruby-dev -y -q
gem install colorls

echo ""
echo "Everything installed. Reboot the machine!"
echo ""
