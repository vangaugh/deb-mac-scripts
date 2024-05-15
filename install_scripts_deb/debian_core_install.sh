#!/usr/bin/env bash

# UPDATED MAY 24, 2024

# Disable user prompt
DEBIAN_FRONTEND=noninteractive

exec   > >(tee -ia bash.log)
exec  2> >(tee -ia bash.log >& 2)
exec 19> bash.log

export BASH_XTRACEFD="19"
set -x

# Make Directories
mkdir -p ~/projects/github_repos
mkdir -p ~/dotfiles
mkdir -p ~/scripts
mkdir -p ~/backups
touch ~/.functions

# Update list of available packages
apt autoclean && apt update -y -q

# Update installed packages
apt full-upgrade -y && apt autoremove -y

# Install the most common packages that will be usefull under development environment
apt install zip unzip git curl wget zsh net-tools fail2ban htop sqlite3 nload mlocate nano software-properties-common build-essential -y -q

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
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/54b7b1c4eee7c4c7af5f5ec41ab90cbd42491fc5/.zshrc > ~/.zshrc

# .deb_custom_aliases
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/54b7b1c4eee7c4c7af5f5ec41ab90cbd42491fc5/.custom_aliases > ~/.custom_aliases

# .deb_nanorc
wget -q -O - https://gist.githubusercontent.com/vangaugh/a46117b3a969ae84840f19785e6dbc9a/raw/54b7b1c4eee7c4c7af5f5ec41ab90cbd42491fc5/.nanorc > ~/.nanorc

# empty_trash.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/8d2cf6d65fc31b983b104f11cad0e4ef159db59b/empty_trash.sh > ~/scripts/empty_trash.sh

# server_update.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/8d2cf6d65fc31b983b104f11cad0e4ef159db59b/server_update.sh > ~/scripts/server_update.sh

# git_pull_all.sh
wget -q -O - https://gist.githubusercontent.com/vangaugh/34740e580d9027fd3273e23b96974975/raw/8d2cf6d65fc31b983b104f11cad0e4ef159db59b/git_pull_all.sh > ~/scripts/git_pull_all.sh

chmod +x ~/scripts/*.sh
cd $HOME

# Install colorls
apt install ruby ruby-dev -y -q
gem install colorls

# Configure the default ZSH configuration for new users.
cp ~/.zshrc /etc/skel/
cp ~/.p10k.zsh /etc/skel/
cp -r ~/.oh-my-zsh /etc/skel/
chmod -R 755 /etc/skel/
chown -R root:root /etc/skel/

echo ""
echo "Everything installed. Reboot the machine!"
echo ""
