#!/bin/bash

# Name
if (whiptail --title "____ 'Ubuntu Initial Configurator Version 2.0' ____" --yesno "This is the basic setup for Ubuntu, would you like to continue?" 10 60); then
    echo -e "\e[32mWe continue to configure!\e[0m"
else
    echo -e "\e[32mBye!\e[0m" && exit
fi

# Search directory
directory="$(find /home/ -name 'ubuntu_config')"
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 1
        echo $i
        directory="$(find /home/ -name 'ubuntu_config')"
    done
} | whiptail --gauge "Please wait, looking for a folder!" 6 60 0

# Menu
OPTION=$(whiptail --title "Install / Uninstall / Configure Major Programs" --menu "Select the desired action:" 20 78 3 \
    "1" "Install Marketing Pack" \
    "2" "Install Development Pack" \
    "3" "Install Front-end Pack" \
    "4" "Install Full Pack" 3>&1 1>&2 2>&3 4>&4)
exitstatus=$?

# Check Exit Status
if [ $exitstatus = 0 ]; then
    echo -e "\e[32mYou choosed:\e[0m" $OPTION
else
    echo -e "\e[32mBye!\e[0m" && exit
fi

# Password
PASS=$(whiptail --passwordbox "Please enter your secret password" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
exitstatus=$?

# Check Exit Status
if [ $exitstatus = 0 ]; then
    echo -e "\e[32mStart\e[0m"
else
    echo -e "\e[32mBye!\e[0m" && exit
fi

# selection of menu items
case "$OPTION" in
1) bash $directory/scripts/marketing.sh && echo -e '\e[32mInstall Marketing Pack\e[0m' && echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m" ;;
2) bash $directory/scripts/developer.sh && echo -e '\e[32mInstall Development Pack\e[0m' && echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m" ;;
3) bash $directory/scripts/frontend.sh && echo -e '\e[32mInstall Front-end Pack\e[0m' && echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m" ;;
4) bash $directory/scripts/developer.sh && echo -e '\e[32mInstall Full Pack\e[0m' && echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m" ;;
esac

# dependency recovery
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 0.1
        echo $i
        echo "Dependency recovery ..."
        echo $PASS | sudo -S apt install -y -f >/dev/null 2>&1 &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Dependency recovery ..." 6 50 0

# removing unnecessary packets, clearing APT cache
{
    for ((i = 0; i <= 100; i += 20)); do
        sleep 0.1
        echo $i
        echo -e "\e[36mClean ...\e[0m"
        echo $PASS | sudo -S apt autoremove -y >/dev/null 2>&1
        echo $PASS | sudo -S apt-get autoclean -y >/dev/null &&
            echo -e "\e[32mDone!\e[0m" || echo -e "\e[31mError...\e[0m"
    done
} | whiptail --gauge "Clean ..." 6 50 0

echo -e "\e[1;32m!!!Ready!!!\e[0m"
