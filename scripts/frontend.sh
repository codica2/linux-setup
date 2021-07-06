#!/bin/bash
# Make sure non root
if [[ "${UID}" -eq 0 ]]; then
    echo 'Its non root script...' >&2
    exit 1
fi

# Frontend
# ----------------------------------------------------------------------------

# Password
PASS_DEV=$(whiptail --passwordbox "Please re-enter your secret password" 8 78 --title "Password request for installation" 3>&1 1>&2 2>&3)
exitstatus=$?

# Distro check according to exit status of package managers search
YUM_CMD=$(ls /usr/bin/ | egrep "^yum$")

# Define packs type to download and distro
if [[ ${?} != 0 ]]; then
    DISTRO=Deb
else
    DISTRO=Rpm
fi

# Define distro vars
if [[ ${DISTRO} != "Rpm" ]]; then
    PACK="deb" && MANAG="dpkg" && INSTALLER="apt" && PACK_ARCH="amd64" && INSTALL_PARM=" -i" && AUTO_APP=" " && PACK_INSTALL_PARM="install"
else
    PACK="rpm" && MANAG="yum" && INSTALLER="yum" && PACK_ARCH="x86_64" && INSTALL_PARM="install" && AUTO_APP=" -y" && PACK_INSTALL_PARM="install"
fi

# Install chrome
{
    for ((i = 0; i <= 100; i += 50)); do
        sleep 1
        echo ${i}
        echo ${PASS_DEV} | sudo -S apt --fix-broken install -y >>installation.log 2>&1 &&
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_${PACK_ARCH}.${PACK} >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S ${MANAG} ${INSTALL_PARM} ${AUTO_APP} google-chrome-stable_current_${PACK_ARCH}.${PACK} >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo rm -rf /var/lib/apt/lists/lock &&
            echo ${PASS_DEV} | sudo rm -rf /var/cache/apt/archives/lock &&
            echo ${PASS_DEV} | sudo rm -rf /var/lib/dpkg/lock &&
            rm -rf $(pwd)/google-chrome-stable_current_${PACK_ARCH}.${PACK}* &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Installing Google Chrome..." 6 50 0

# Fix chrome installation
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Update cache and install curl ..."
        echo ${PASS_DEV} | sudo -S apt update >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S apt install curl -y >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S apt upgrade -y >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S apt --fix-broken install -y >>installation.log 2>&1 &&
            sudo rm /var/lib/apt/lists/lock &&
            sudo rm /var/cache/apt/archives/lock &&
            sudo rm /var/lib/dpkg/lock &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Update cache and install curl ..." 6 50 0

# ----------------------------------------------------------------------------
# Packs

# Repository and system updates
apt_repos=("ppa:giuspen/ppa" "ppa:gezakovacs/ppa" "ppa:stebbins/handbrake-releases"
    "ppa:openshot.developers/ppa")
# Loop
for APT_REPO in ${apt_repos[@]}; do
    if [[ ${DISTRO} == "Deb" ]]; then
        {
            for ((i = 0; i <= 100; i += 50)); do
                sleep 1
                echo ${i}
                echo "Adding repositories ..."
                echo ${PASS_DEV} | sudo -S add-apt-repository -y ${APT_REPO} >>installation.log 2>&1 &&
                    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - >>installation.log 2>&1
                echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
            done
        } | whiptail --gauge "Adding repositories" 6 50 0
    fi
done
# ----------------------------------------------------------------------------

# Package installation array; just add to list to have new package installed
yum_packages=("nano" "tree" "curl" "wget" "snapd" "guake" "wine" "gparted" "unetbootin" "gnome-tweak-tool"
    "zip" "unzip" "sharutils" "uudeview" "arj" "cabextract" "file-roller" "git" "postresql" "snapd" "tmux"
    "zsh" "double-qt" "filezilla" "ftp" "sftp" "flameshot" "gimp" "slack" "evolution" "vlc" "ca-certificates"
    "gnupg2" "preload" "p7zip" "unar" "uudenview" "cabextract" "file-roller" "postgresql-server" "cherrytree"
    "dconf-editor" "unzip" "wine32" "binutils" "gcc" "make" "glibc-devel" "kernel-devel"
    "dkms" "libxkbcommon" "libgomp" "qt5-qtx11extras" "virtualbox")

# Loop through list of packs
for YUM_PACK in "${yum_packages[@]}"; do
    if [[ ${DISTRO} == "Rpm" ]]; then
        {
            for ((i = 0; i <= 100; i += 20)); do
                sleep 1
                echo ${i}
                echo "Installing ${YUM_PACK} ..."
                echo ${PASS_DEV} | sudo -S ${INSTALLER} ${PACK_INSTALL_PARM} ${AUTO_APP} ${YUM_PACK} >>installation.log 2>&1 &&
                    echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
            done
        } | whiptail --gauge "Installing ${YUM_PACK^} ..." 6 50 0
    fi
done

# Package installation...
apt_packages=("snapd" "wine32" "software-properties-common" "nano" "tree" "libxslt1-dev" "libcurl4-openssl-dev" "ibksba8"
    "libksba-dev" "libqtwebkit-dev" "libreadline-dev" "build-essential" "apt-transport-https" "ca-certificates"
    "gnugpg-agent" "g++" "gcc""curl" "guake" "preload" "wine64" "virtualbox" "synaptic" "gparted" "unetbootin"
    "gnome-tweak-tool" "p7zip-rar" "p7zip-full" "make" "unace" "unrar" "zip" "unzip" "sharutils" "rar" "uudeview"
    "mpack" "arj" "cabextract" "file-roller" "uck" "make-guile" "openssh-server" "ubuntu-make" "git" "postgresql" "tmux"
    "postgresql-server-dev-all" "postman" "zsh" "cherrytree" "doublecmd-qt" "filezilla" "packaging-dev" "dconf-editor"
    "checkinstall" "flameshot" "gimp" "handbreak-gtk" "openshot-qt" "simplescreenrecorder" "evolution")

# Loop
for APT_PACK in "${apt_packages[@]}"; do
    if [[ $DISTRO == "Deb" ]]; then
        {
            for ((i = 0; i <= 100; i += 20)); do
                sleep 1
                echo ${i}
                echo "Installing ${APT_PACK}..."
                echo ${PASS_DEV} | sudo -S ${INSTALLER} ${PACK_INSTALL_PARM} -y ${APT_PACK} >>installation.log 2>&1 &&
                    echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
            done
        } | whiptail --gauge "Installing ${APT_PACK^} ..." 6 50 0
    fi
done

# Snap array
snap_packages=("handbrake-jz" "simplescreenrecorder" "postman" "code --classic" "ngrok")

# Loop
for SNAP in "${snap_packages[@]}"; do
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 1
            echo ${i}
            echo "Installing ${SNAP}..."
            echo ${PASS_DEV} | sudo -S snap install ${SNAP} >>installation.log 2>&1 &&
                echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        done
    } | whiptail --gauge "Installing ${SNAP^} ..." 6 50 0
done
# ----------------------------------------------------------------------------
# Development

# VirtualBox - program for creating and managing virtual machines
if [[ ${DISTRO} == "Rpm" ]]; then
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 1
            echo ${i}
            echo "Install VirtualBox ..."
            wget https://download.virtualbox.org/virtualbox/6.1.22/VirtualBox-6.1-6.1.22_144080_fedora33-1.x86_64.${PACK} >>installation.log 2>&1 &&
                echo ${PASS_DEV} | sudo -S yum localinstall VirtualBox-6.1-6.1.22_144080_fedora33-1.x86_64.${PACK} >>installation.log 2>&1 &&
                echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        done
    } | whiptail --gauge "Installing VirtualBox ..." 6 60 0
fi

# SSH generating
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N "" >>installation.log 2>&1 &&
    echo -e "\e[32mGeneraging SSH Done!\e[0m" || echo -e "\e[31mGeneraging SSH Error...\e[0m"

# Redis - an in-memory data structure project implementing a distributed
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Install redis ..."
        wget http://download.redis.io/redis-stable.tar.gz >>installation.log 2>&1 &&
            tar xvzf redis-stable.tar.gz >>installation.log 2>&1 &&
            cd redis-stable >>installation.log 2>&1 && make >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S cp src/redis-server /usr/local/bin/ >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S cp src/redis-cli /usr/local/bin/ >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Redis ..." 6 60 0

# Docker - a set of platform as a service
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Install docker ..."
        curl -fsSL https://get.docker.com -o get-docker.sh >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S sh get-docker.sh >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Docker ..." 6 60 0

# Docker Compose - a set of platform as a service
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Install docker-compose"
        echo ${PASS_DEV} | sudo -S curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >>installation.log 2>&1
        echo ${PASS_DEV} | sudo -S chmod +x /usr/local/bin/docker-compose >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Docker Compose ..." 6 60 0

# Oh-my-zsh - a delightful & open source framework for Zsh
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Install oh-my-zsh ..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Oh My ZSH ..." 6 60 0

# Slack - corporate messenger

if [[ ${DISTRO} != "Rpm" ]]; then
{
    for ((i = 0; i <= 100; i += 100)); do
        sleep 1
        echo $i
        echo "Install slack ..."
        wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb >/dev/null 2>&1 &&
            echo $PASS_DEV | sudo -S apt install -y ./slack-desktop-*.deb >/dev/null 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Slack ..." 6 60 0
fi

if [[ ${DISTRO} == "Rpm" ]]; then
{
    for ((i = 0; i <= 100; i += 100)); do
        sleep 1
        echo $i
        echo "Install slack ..."
        wget https://downloads.slack-edge.com/linux_releases/slack-4.16.0-0.1.fc21.x86_64.rpm >/dev/null 2>&1 &&
            echo $PASS_DEV | sudo -S yum localinstall -y ./slack-desktop-*.rpm >/dev/null 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install Slack ..." 6 60 0
fi

# Deafult consle ZSH
{
    for ((i = 0; i <= 100; i += 100)); do
        sleep 1
        echo ${i}
        echo "Install ZSH default ..."
        echo 'exec zsh' >>~/.bashrc &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install ZSH as default ..." 6 60 0

# NVM - Node Version Manager
{
    for ((i = 0; i <= 100; i += 100)); do
        sleep 1
        echo ${i}
        echo "Install nvm ..."
        curl -o- -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Install NVM ..." 6 60 0
# ----------------------------------------------------------------------------
# Other

# Add Russian keyboard

{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Configure binds ..."
        gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "['None']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "Print"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "/usr/bin/flameshot gui"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemoOn/plugins/media-keys/custom-keybindings/custom0/ name "FlameScreen"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
        echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Configure binds..." 6 50 0

# Add Russian keyboard
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Add Russian keyboard ..."
        echo -e 'XKBLAYOUT=us,ru\nBACKSPACE=guess\nXKBVARIANT=,' | echo $PASS_DEV | sudo -S tee /etc/default/keyboard &&
            gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]" &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Add Russian Keyboard ..." 6 60 0

# Disabling crash reports
# Player removal rhythmbox
# Remove totem video player
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Fix ..."
        echo ${PASS_DEV} | sudo -S sed -i "s/enabled=1/enabled=0/g" '/etc/default/apport' >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo ${PASS_DEV} | sudo -S ${INSTALLER} remove -y rhythmbox >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo ${PASS_DEV} | sudo -S ${INSTALLER} remove -y totem >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S sysctl -p >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo ${PASS_DEV} | sudo -S usermod -aG docker $USER &&
            echo ${PASS_DEV} | sudo -S systemctl enable docker &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Removing extra software..." 6 60 0

echo "source ${HOME}/.nvm/nvm.sh" >>~/.bash_profile &&
    echo "source ${HOME}/.nvm/nvm.sh" >>~/.bashrc &&
    echo "source ${HOME}/.nvm/nvm.sh" >>~/.zshrc
source ~/.bashrc
# ----------------------------------------------------------------------------

# Upgrade
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Upgrade ..."
        echo ${PASS_DEV} | sudo -S ${INSTALLER} upgrade -y >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Upgrade ..." 6 60 0

# Fix broken
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Upgrade ..."
        echo ${PASS_DEV} | sudo -S apt --fix-broken install -y >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Upgrade ..." 6 60 0
