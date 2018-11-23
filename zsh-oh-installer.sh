#!/bin/bash
###############################################################

function zshcheck(){ 
    { [[ $(which zsh) ]] &> /dev/null; } && echo "Found zsh. Go on." || { echo "Zsh not found, nothing to do. Exit."; exit 1; }
}
function pwcheck(){
# Get password
    echo -n "Enter your user-with-sudo-rights password: "; read -s PASSWD; echo;
    export PASSWD=$(echo $PASSWD)
# Check sudo rights
sudo -k
if sudo -lS &> /dev/null << EOF
$PASSWD
EOF
    then echo "Correct password. Go on."; else echo "Wrong password. Exit."; exit 1;
fi
}
function shcheck(){
    grep -Fxq "$(which zsh)" /etc/shells && echo "Found zsh is /etc/shells." || \
    { echo "zsh is not found in /etc/shells. Try to add."; \
    echo $PASSWD | sudo -S sh -c "echo '$(which zsh)' | sudo tee -a /etc/shells"; }
}
function thmenter(){
    echo; read -p "Enter your preferred theme [default is robbyrussell, recommended is fatllama]: " ZSH_DEFAULT_THEME;
    ZSH_DEFAULT_THEME=${ZSH_DEFAULT_THEME:-robbyrussell}
}
function thmcheck(){
    ls $HOME/.oh-my-zsh/themes/$ZTHEME.zsh-theme &>/dev/null || ls ${ZSH_CUSTOM}/themes/$ZTHEME.zsh-theme &>/dev/null && \
    { echo "Found $ZTHEME theme. Accepted."; ZSH_DEFAULT_THEME=$ZTHEME; } || { echo "$ZTHEME theme not found."; thmenter; }
}

###############################################################
function getoh(){
    echo; echo "Wget oh-my-zsh";
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
}
function downloadmod(){
    echo; echo "Download fatllama theme";
    wget -O ${ZSH_CUSTOM}/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/themes/fatllama.zsh-theme
    echo; echo "Download fast-syntax-highlighting";
    git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting
    echo; echo "Download history-substring-search";
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search
    echo; echo "Download zsh-autosuggestions";
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions

    { [[ $ZTHEME ]] && thmcheck; } || { [[ $ZEASY ]] && ZSH_DEFAULT_THEME="robbyrussell"; } || { thmenter; }
    echo "Theme you entered is $ZSH_DEFAULT_THEME"; echo;
    # Get and export username and theme
    sed -i.tmp "6s/^/export ZSH_USER_M=$(echo $USER)/" $HOME/.zshrc
    sed -i.tmp "7s/^/export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)/" $HOME/.zshrc
    rm -rf $HOME/.zshrc.tmp
}
###############################################################
#Find and replace the string that contains shell permissions
function pamtosuf(){
    [[ $NRPAM != "" ]] && { echo $PASSWD | grep -rl "pam_shells.so" /etc/pam.d/chsh | sudo -S xargs sed -i "$(echo $NRPAM)s/required/sufficient/g"; }
}
function pamtoreq(){
    [[ $NRPAM != "" ]] && { echo $PASSWD | grep -rl "pam_shells.so" /etc/pam.d/chsh | sudo -S xargs sed -i "$(echo $NRPAM)s/sufficient/required/g"; }
}
###############################################################

function linuxinstall(){
    pwcheck
    echo; echo "Do $PKT_MGR install zsh";
    echo $PASSWD | sudo -S $PKT_MGR install -y zsh
    getoh

    echo; echo "Change shell to zsh";
    shcheck

    # If is not empty then change permissions for chsh
    pamtosuf   
    echo $PASSWD | sudo -S chsh -s $(which zsh) $USER;
    [[ $ZEASY ]] && echo "No root shell change" || {
        while true; do
            read -p "Do you want to change root shell too? [y/N]: " yn
            case $yn in
                [yY] | [yY][Ee][Ss]  ) echo "Do sudo change root shell to zsh"; echo $PASSWD | sudo -S chsh -s $(which zsh); break;;
                [nN] | [nN][Oo] | '' ) echo "Root shell stays default"; break;;
                * ) echo "Please answer y[es] or N[o].";;
            esac
        done
    }
    echo; echo "Download linux zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/zshrc/.zshrc-linux
    downloadmod
    # Back permissions for chsh
    pamtoreq
}
###############################################################

function macinstall(){
    # To remember your path
    ZPWD=$(pwd)
    cd /usr/local/Cellar
    mkdir zsh zsh-completions 2> /dev/null
    cd $ZPWD
    echo "Make chown for brew (/usr/local/Cellar/zsh*)";
    chown -R $(whoami):admin /usr/local/Cellar/zsh*
    echo; echo "Do $PKT_MGR install zsh";
    $PKT_MGR install -y zsh zsh-completions
    getoh

    echo; echo "Change shell to brew zsh";
    dscl . -create /Users/$USER UserShell $(which zsh)
    echo; echo "Download macos zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/zshrc/.zshrc-mac
    downloadmod
}
###############################################################

function linuxremove(){
    pamtosuf
    echo $PASSWD | sudo -S $PKT_MGR remove -y zsh;
    echo $PASSWD | sudo -S chsh -s $(which bash) $USER;
    pamtoreq
}
function macremove(){
    $PKT_MGR remove -y zsh
    echo $PASSWD | sudo -S dscl -P $PASSWD . -create /Users/$USER UserShell $(which bash)
    rm -rf /usr/local/Cellar/zsh*
}
function zshremove(){
    zshcheck
    pwcheck
    uninstall_oh_my_zsh 2> /dev/null
    rm -rf ~/.oh*
    rm -rf ~/.zsh*
    [[ $PKT_MGR == "brew" ]] && macremove || linuxremove
}
###############################################################

function distroway(){
    echo "You use $DISTRO distribution"    
    # Number of the row for linux chsh
    [[ $DISTRO != darwin ]] && export NRPAM=$(awk '/pam_shells.so/{ print NR; exit }' /etc/pam.d/chsh) 2> /dev/null
    case "$DISTRO" in
        "darwin" ) 
                PKT_MGR="brew"; echo "We will try $PKT_MGR as a packet manager for $ZSHDO zsh"
                if [[ $ZSHDO == "install" ]]; then macinstall; else zshremove; fi
                ;;
        "ubuntu" | "Ubuntu" ) 
                PKT_MGR="apt"; echo "We will try $PKT_MGR as a packet manager for $ZSHDO zsh"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                ;;
        "centos" | "*centos*") 
                PKT_MGR="yum"; echo "We will try $PKT_MGR as a packet manager for $ZSHDO zsh"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                while true; do
                    read -p "Make logout to changes to take effect. Do you want to logout now? This will close all opened applications. [y/N]: " lg
                    case $lg in
                        [yY] | [yY][Ee][Ss]  ) echo "Logout"; gnome-session-quit --no-prompt; break;;
                        [nN] | [nN][Oo] | '' ) echo "You choose do not logout"; break;;
                        * ) echo "Please answer y[es] or N[o].";;
                    esac
                done
                ;; 
        * ) echo "Unknown OS, exit."; exit 1;;
    esac
    echo; [[ $PKT_MGR != "yum" ]] && echo "Start the new session to changes to take effect."
    unset DIR DISTRO NRPAM PASSWD PKT_MGR UNAME ZEASY ZPWD ZRMV ZSHDO ZTHEME lg iu yn
}

###################### Here is the start ######################

# Options -y: installation with all defaults; -t with argument: name of zsh theme; -r: remove - priority option;
# -y: Install zsh with oh-my-zsh AND robbyrussell theme (if -t is empty) TO the user who runs (only for linux) WITH passwords prompt; 
# -y: Priority in the script = 3 (low);
# -t: do ONLY install; Priority in the script = 2 (high);
# -r: do ONLY remove; Priority in the script = 1 (highest);
while getopts :yrt: option; do
case "${option}"
in
    y) ZEASY=true;;
    t) ZTHEME=${OPTARG};;
    r) ZRMV=true;;
    \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
    *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
esac; done

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
[[ "$UNAME" == "linux" ]] && {
    # If available, use LSB to identify distribution
    [ -f /etc/lsb-release -o -d /etc/lsb-release.d ] && export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//) || \
    # Otherwise, use release info file
    export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
}
# For everything else (or if above failed), just use generic identifier
[[ "$DISTRO" == "" ]] && export DISTRO=$UNAME
# Cut first word
export DISTRO=$(echo $DISTRO | cut -d" " -f1)
# Install/Uninstall
if [[ $ZRMV ]]; then ZSHDO="uninstall";
elif [[ $ZEASY ]] || [[ $ZTHEME ]]; then ZSHDO="install";
else
    while true; do
        read -p "Do you want to install or uninstall ZSH? [1(I)/2(u)]: " iu
        case $iu in
            [1] | [Ii] | '' ) ZSHDO="install"; break;;
            [2] | [Uu] ) ZSHDO="uninstall"; break;;
            * ) echo "Please answer 1 or 2.";;
        esac
    done
fi
distroway
exit 0
