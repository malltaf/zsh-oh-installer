#!/bin/bash
###############################################################

function zshcheck(){ 
    [[ $PKT_MGR == "brew" ]] && DIR=/usr/local/Cellar/zsh || DIR=/usr/bin/zsh
    ls ${DIR} &>/dev/null && echo "Found zsh. Go on." || { echo "Zsh not found, nothing to delete. Exit."; exit 1; }
}
function pwcheck (){
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
function thmenter(){
    echo; read -p "[$(($SNUMB-1))/$SNUMB] Enter your preferred theme [default is robbyrussell, recommended is fatllama]: " ZSH_DEFAULT_THEME;
    ZSH_DEFAULT_THEME=${ZSH_DEFAULT_THEME:-robbyrussell}
}
function thmcheck(){
    ls $HOME/.oh-my-zsh/themes/$ZTHEME.zsh-theme &>/dev/null || ls ${ZSH_CUSTOM}/themes/$ZTHEME.zsh-theme &>/dev/null && \
    { echo "Found $ZTHEME theme. Accepted."; ZSH_DEFAULT_THEME=$ZTHEME; } || { echo "$ZTHEME theme not found."; thmenter; }
}
function getoh (){
    echo; echo "[$(($SNUMB-3))/$SNUMB] wget oh-my-zsh";
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
}
###############################################################

function downloadmod (){
    echo; echo "[$(($SNUMB-2))/$SNUMB] theme";
    wget -O ${ZSH_CUSTOM}/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh/master/fatllama.zsh-theme
    echo; echo "[$(($SNUMB-2))/$SNUMB] fast-syntax-highlighting";
    git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting
    echo; echo "[$(($SNUMB-2))/$SNUMB] history-substring-search";
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search
    echo; echo "[$(($SNUMB-2))/$SNUMB] zsh-autosuggestions";
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions

    { [[ $ZTHEME ]] && thmcheck; } || { [[ $ZEASY ]] && ZSH_DEFAULT_THEME="robbyrussell"; } || { thmenter; }
    echo "[$(($SNUMB-1))/$SNUMB] Theme you entered is $ZSH_DEFAULT_THEME"; echo;
    # Get and export username and theme
    sed -i.tmp "6s/^/export USER_ZSH=$(echo $USER)/" $HOME/.zshrc
    sed -i.tmp "7s/^/export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)/" $HOME/.zshrc
    rm -rf $HOME/.zshrc.tmp
}
###############################################################
#Find and replace the string that contains shell permissions
function pamtosuf(){
export NRPAM=$(awk '/pam_shells.so/{ print NR; exit }' /etc/pam.d/chsh)
echo $PASSWD | grep -rl "pam_shells.so" /etc/pam.d/chsh | sudo -S xargs sed -i "$(echo $NRPAM)s/required/sufficient/g"
}
function pamtoreq(){
echo $PASSWD | grep -rl "pam_shells.so" /etc/pam.d/chsh | sudo -S xargs sed -i "$(echo $NRPAM)s/sufficient/required/g"
}
###############################################################

function ubuntu-install(){
    pwcheck
    echo; echo "[$(($SNUMB-3))/$SNUMB] $PKT_MGR install";
    echo $PASSWD | sudo -S $PKT_MGR install -y zsh
    getoh

    echo; echo "[$(($SNUMB-3))/$SNUMB] change shell to zsh";
    pamtosuf
    echo $PASSWD | sudo -S chsh -s `which zsh` $USER;
    [[ $ZEASY ]] && echo "No root shell change" || {
        while true; do
            read -p "[$(($SNUMB-3))/$SNUMB] Do you want to change root shell too? [y/N]: " yn
            case $yn in
                [yY] | [yY][Ee][Ss]  ) echo "[$(($SNUMB-3))/$SNUMB] sudo change root shell to zsh"; echo $PASSWD | sudo -S chsh -s `which zsh`; break;;
                [nN] | [n|N][O|o] | '' ) echo "[$(($SNUMB-3))/$SNUMB] root shell stays default"; break;;
                * ) echo "Please answer y[es] or N[o].";;
            esac
        done
    }
    echo; echo "[$(($SNUMB-2))/$SNUMB] zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/zshrc/.zshrc-linux
    downloadmod
    pamtoreq
}
###############################################################

function mac-install(){
    # To remember your path
    ZPWD=$(pwd)
    cd /usr/local/Cellar
    mkdir zsh zsh-completions 2> /dev/null
    cd $ZPWD
    echo "[$(($SNUMB-3))/$SNUMB] make chown for brew (/usr/local/Cellar/zsh*)";
    chown -R $(whoami):admin /usr/local/Cellar/zsh*
    echo; echo "[$(($SNUMB-3))/$SNUMB] $PKT_MGR install";
    $PKT_MGR install -y zsh zsh-completions
    getoh

    echo; echo "[$(($SNUMB-3))/$SNUMB] change shell to brew zsh";
    dscl . -create /Users/$USER UserShell `which zsh`
    echo; echo "[$(($SNUMB-2))/$SNUMB] zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/zshrc/.zshrc-mac
    downloadmod
}
###############################################################

function linux-remove(){
    pamtosuf
    echo $PASSWD | sudo -S $PKT_MGR remove -y zsh;
    echo $PASSWD | sudo -S chsh -s `which bash` $USER;
    pamtoreq
}
function mac-remove(){
    $PKT_MGR remove -y zsh
    echo $PASSWD | sudo -S dscl -P $PASSWD . -create /Users/$USER UserShell `which bash`
    rm -rf /usr/local/Cellar/zsh*
}
function zsh-remove(){
    zshcheck
    pwcheck
    uninstall_oh_my_zsh 2> /dev/null
    rm -rf ~/.oh*
    rm -rf ~/.zsh*
    [[ $PKT_MGR == "brew" ]] && mac-remove || linux-remove
}
###############################################################

function distroway(){
    echo "You use $DISTRO distribution"
    case "$DISTRO" in
        "darwin" ) 
                PKT_MGR="brew"; wetry; if [[ $ZSHDO == "install" ]]; then mac-install; else zsh-remove; fi;;
        "ubuntu" | "Ubuntu" ) 
                PKT_MGR="apt"; wetry; if [[ $ZSHDO == "install" ]]; then ubuntu-install; else zsh-remove; fi;;
        "centos" ) 
                PKT_MGR="yum"; wetry; if [[ $ZSHDO == "install" ]]; then centos-install; else zsh-remove; fi;; #
        * ) echo "Unknown OS, exit."; exit 1;;
    esac
}
function wetry(){ echo "We will try $PKT_MGR as a packet manager for $ZSHDO zsh"; }


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

# Give step numbers
SNUMB=5
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
# Install/Uninstall
[[ $ZRMV ]] && { ZSHDO="uninstall"; distroway; } || {
{ [[ $ZEASY ]] || [[ $ZTHEME ]] && ZSHDO="install"; } || {
    while true; do
        read -p "Do you want to install or uninstall ZSH? [1(I)/2(u)]: " iu
        case $iu in
            [1] | [Ii] | '' ) ZSHDO="install"; break;;
            [2] | [Uu] ) ZSHDO="uninstall"; break;;
            * ) echo "Please answer 1 or 2.";;
        esac
    done
    }
distroway;
}

unset DIR DISTRO NRPAM PASSWD PKT_MGR SNUMB UNAME ZEASY ZPWD ZRMV ZSHDO ZTHEME
echo; echo; echo "Start the new session to changes to take effect.";
