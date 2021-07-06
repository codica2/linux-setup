#!/bin/bash
# Make sure non root
if [[ "${UID}" -eq 0 ]]; then
    echo 'Its non root script...' >&2
    exit 1
fi

# Marketing
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
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo ${PASS_DEV} | sudo -S apt --fix-broken install -y >>installation.log 2>&1 &&
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_${PACK_ARCH}.${PACK} >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo -S ${MANAG} ${INSTALL_PARM} ${AUTO_APP} google-chrome-stable_current_${PACK_ARCH}.${PACK} >>installation.log 2>&1 &&
            echo ${PASS_DEV} | sudo rm -rf /var/lib/apt/lists/lock &&
            echo ${PASS_DEV} | sudo rm -rf /var/cache/apt/archives/lock &&
            echo ${PASS_DEV} | sudo rm -rf /var/lib/dpkg/lock &&
            rm -rf $(pwd)/google-chrome-stable_current_${PACK_ARCH}.${PACK}* >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Installing Google Chrome" 6 50 0
# ----------------------------------------------------------------------------

# Add repository and do system updates
apt_repos=("ppa:giuspen/ppa" "ppa:gezakovacs/ppa" "ppa:stebbins/handbrake-releases"
    "ppa:openshot.developers/ppa")

# Add repos
for APT_REPO in ${apt_repos[@]}; do
    if [[ ${DISTRO} == "Deb" ]]; then
        {
            for ((i = 0; i <= 100; i += 30)); do
                sleep 1
                echo ${i}
                echo "Adding repositories ..."
                echo ${PASS_DEV} | sudo -S add-apt-repository -y ${APT_REPO} >>installation.log 2>&1 &&
                    echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
            done
        } | whiptail --gauge "Adding repositories" 6 50 0
    fi
done
# ----------------------------------------------------------------------------

# Update apt cache
if [[ ${DISTRO} != "Rpm" ]]; then
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 1
            echo ${i}
            echo "Update ..."
            echo ${PASS_DEV} | sudo -S apt -y update >>installation.log 2>&1
            echo -e "\e[32mDone!\e[0m"
        done
    } | whiptail --gauge "Update ..." 6 50 0
fi

# Package installation array; just add to list to have new package installed
yum_packages=("nano" "tree" "curl" "wget" "snapd" "guake" "wine" "gparted" "unetbootin" "gnome-tweak-tool"
    "zip" "unzip" "sharutils" "uudeview" "arj" "cabextract" "file-roller" "git" "postresql" "snapd" "tmux"
    "zsh" "double-qt" "filezilla" "ftp" "sftp" "flameshot" "gimp" "slack" "evolution" "vlc" "ca-certificates"
    "gnupg2" "preload" "p7zip" "unar" "uudenview" "cabextract" "file-roller" "cherrytree"
    "dconf-editor" "unzip" "wine32")

# Loop through list of packs
for YUM_PACK in "${yum_packages[@]}"; do
    if [[ ${DISTRO} == "Rpm" ]]; then
        {
            for ((i = 0; i <= 100; i += 20)); do
                sleep 0.1
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
    "gnugpg-agent" "curl" "guake" "preload" "wine64" "virtualbox" "synaptic" "gparted" "unetbootin"
    "gnome-tweak-tool" "p7zip-rar" "p7zip-full" "unace" "unrar" "zip" "unzip" "sharutils" "rar" "uudeview"
    "mpack" "arj" "cabextract" "file-roller" "uck" "ubuntu-make" "git" "tmux" "zsh" "cherrytree"
    "doublecmd-qt" "filezilla" "dconf-editor" "flameshot" "gimp" "handbreak-gtk" "openshot-qt"
    "simplescreenrecorder" "evolution")

# Loop
for APT_PACK in "${apt_packages[@]}"; do
    if [[ $DISTRO == "Deb" ]]; then
        {
            for ((i = 0; i <= 100; i += 20)); do
                sleep 0.1
                echo ${i}
                echo "Installing ${APT_PACK}..."
                echo ${PASS_DEV} | sudo -S ${INSTALLER} ${PACK_INSTALL_PARM} -y ${APT_PACK} >>installation.log 2>&1 &&
                    echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
            done
        } | whiptail --gauge "Installing ${APT_PACK^} ..." 6 50 0
    fi
done

# Virtualbox - program for creating virtual machines
if [[ ${DISTRO} == "Rpm" ]]; then
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 1
            echo ${i}
            echo "Install VirtualBox ..."
            wget https://download.virtualbox.org/virtualbox/6.1.22/VirtualBox-6.1-6.1.22_144080_fedora33-1.x86_64.${PACK} >>installation.log 2>&1 &&
                echo ${PASS_DEV} | sudo -S yum localinstall -y VirtualBox-6.1-6.1.22_144080_fedora33-1.x86_64.${PACK} >>installation.log 2>&1 &&
                rm -rf ${USER_HOME_DIR}/VirtualBox-6.1-6.1.22_144080_fedora33-1.x86_64.${PACK}* >>installation.log 2>&1 &&
                echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        done
    } | whiptail --gauge "Install VirtualBox ..." 6 60 0
fi

# Snap installation
snap_packages=("handbrake-jz" "simplescreenrecorder" "code --classic")

# Loop
for SNAP in "${snap_packages[@]}"; do
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 0.1
            echo ${i}
            echo "Installing ${SNAP}..."
            echo ${PASS_DEV} | sudo -S snap install ${SNAP} >>installation.log 2>&1 &&
                echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        done
    } | whiptail --gauge "Installing ${SNAP} ..." 6 50 0
done

# Extra
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 0.1
        echo ${i}
        echo "Configure binds ..."
        gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "['None']"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "Print"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "/usr/bin/flameshot gui"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemoOn/plugins/media-keys/custom-keybindings/custom0/ name "FlameScreen"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
        echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Configure binds ..." 6 50 0
# ---------------------------------------------------------------------------
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

# Other
# Add Russian keyboard
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Add Russian keyboard ..."
        echo -e 'XKBLAYOUT=us,ru\nBACKSPACE=guess\nXKBVARIANT=,' | echo ${PASS_DEV} | sudo -S tee /etc/default/keyboard &&
            gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]" &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Add Russian Keyboard ..." 6 60 0

# Disabling crash reports
# Remove extra packages
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Fix ..."

        echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo ${PASS_DEV} | sudo -S ${INSTALLER} remove -y rhythmbox >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
        echo ${PASS_DEV} | sudo -S ${INSTALLER} remove -y totem >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Remove extra packages ..." 6 60 0

:# ----------------------------------------------------------------------------
# Slack - corporate messenger
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

# Upgrade and fix broken
# Upgrade
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo ${i}
        echo "Upgrade ..."
        echo ${PASS_DEV} | sudo -S ${INSTALLER} upgrade -y >>installation.log 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Fix ..." 6 60 0

# Fix broken packages
if [[ ${DISTRO} != "Rpm" ]]; then
    {
        for ((i = 0; i <= 100; i += 20)); do
            sleep 0.1
            echo ${i}
            echo "Update ..."
            echo ${PASS_DEV} | sudo -S apt -y --fix-broken install >>installation.log 2>&1
            echo -e "\e[32mDone!\e[0m"
        done
    } | whiptail --gauge "Update ..." 6 50 0
fi
