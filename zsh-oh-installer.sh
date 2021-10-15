#!/bin/bash
###############################################################

function zshcheck(){ 
    { [[ $(which zsh) ]] &> /dev/null; } && echo "Found zsh. Go on." || { echo "Zsh not found, nothing to do. Exit."; exit 1; }
}
function pwcheck(){
# Get password
    echo -n "[sudo] password for $USER: "; read -s PASSWD; echo;
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
    echo; echo "Download k";
    git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM}/plugins/k
    # Set a less bright color for dir for k
	sed -i 's/K_COLOR_DI="0;34"/K_COLOR_DI="0;94"/g' ${ZSH_CUSTOM}/plugins/k/k.sh

    { [[ $ZTHEME ]] && thmcheck; } || { [[ $ZEASY ]] && ZSH_DEFAULT_THEME="robbyrussell"; } || { thmenter; }
    echo "Theme you entered is $ZSH_DEFAULT_THEME"; echo;
    # Get new git_promt_info function if theme is fatllama
    [[ "$ZSH_DEFAULT_THEME" == "fatllama" ]] && { mkdir -p ${ZSH_CUSTOM}/lib && wget -O ${ZSH_CUSTOM}/lib/git.zsh https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/lib/git.zsh; }
    # Get and export username and theme
    sed -i.tmp "6s|^|export ZSH_USER_M=$(echo $HOME)|" $HOME/.zshrc
    sed -i.tmp "7s|^|export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)|" $HOME/.zshrc
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
    if [[ $EUID -ne 0 ]]; then
        echo $PASSWD | sudo -S chsh -s $(which zsh) $USER;
    else
        echo $PASSWD | sudo -S chsh -s $(which zsh);
    fi
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
    $PKT_MGR install -y zsh
    getoh

    echo; echo "Change shell to brew zsh";
    dscl . -create /Users/$USER UserShell $(which zsh)
    echo; echo "Download macos zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/zshrc/.zshrc-mac
    downloadmod
}
###############################################################

function linuxbash(){
    pamtosuf
    echo $PASSWD | sudo -S chsh -s $(which bash) $USER;
    pamtoreq
}
function linuxremove(){
    echo $PASSWD | sudo -S $PKT_MGR remove -y zsh;
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
    if [[ $PKT_MGR != "brew" ]]; then
        while true; do
            read -p "Do you want to remove ZSH from the system? [Y/n]: " yns
            case $yns in
                [yY] | [yY][Ee][Ss] | '' ) linuxremove; break;;
                [nN] | [nN][Oo] ) echo "Removed only oh-my-zsh."; break;;
                * ) echo "Please answer y(es) or n(o).";;
            esac
        done
        linuxbash
    else
        macremove
    fi
}
###############################################################

function wetry(){
    echo "We will try $1 as a packet manager for $ZSHDO zsh"
}
function distroway(){
    echo "You use $DISTRO distribution"    
    # Number of the row for linux chsh
    [[ $DISTRO != darwin ]] && export NRPAM=$(awk '/pam_shells.so/{ print NR; exit }' /etc/pam.d/chsh) 2> /dev/null
    case "$DISTRO" in
        "darwin" ) 
                PKT_MGR="brew"; wetry "$PKT_MGR"
                if [[ $ZSHDO == "install" ]]; then macinstall; else zshremove; fi
                ;;
        "ubuntu" | "Ubuntu" ) 
                PKT_MGR="apt"; wetry "$PKT_MGR"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                ;;
        "debian" | "Debian" ) 
                PKT_MGR="apt"; wetry "$PKT_MGR"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                ;;
        "armbian" | "Armbian" ) 
                PKT_MGR="apt"; wetry "$PKT_MGR"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                ;;
        "centos" | "*centos*") 
                PKT_MGR="yum"; wetry "$PKT_MGR"
                if [[ $ZSHDO == "install" ]]; then linuxinstall; else zshremove; fi
                ;; 
        * ) echo "Unknown OS, exit."; exit 1;;
    esac
    echo; echo "Start the new session to changes to take effect."; echo "If the shell has not been changed - please logout/login to take effect.";
    unset DIR DISTRO NRPAM PASSWD PKT_MGR UNAME ZEASY ZPWD ZRMV ZSHDO ZTHEME lg iu yn yns
}

###################### Here is the start ######################

# Options -y: with defaults; -t with argument: name of zsh theme; -r: remove;
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
