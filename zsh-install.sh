#!/bin/bash
###############################################################

function zshcheck(){ 
    if [[ $PKT_MGR == "brew" ]]; then DIR=/usr/local/Cellar/zsh; else DIR=/usr/bin/zsh; fi
    if ls ${DIR} &>/dev/null
        then echo "Found zsh. Go on."; else echo "Zsh not found, nothing to delete. Exit."; exit 1;
    fi
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
    then echo "Correct password. Go on.";
    else echo "Wrong password. Exit."; exit 1;
fi
}
function thmenter(){
    echo; read -p "[$(($snumb-1))/$snumb] Enter your preferred theme [default is robbyrussell, recommended is fatllama]: " ZSH_DEFAULT_THEME;
    ZSH_DEFAULT_THEME=${ZSH_DEFAULT_THEME:-robbyrussell}
}
function thmcheck(){
    if ls $HOME/.oh-my-zsh/themes/$ZTHEME.zsh-theme &>/dev/null || ls ${ZSH_CUSTOM}/themes/$ZTHEME.zsh-theme &>/dev/null
        then echo "Found $ZTHEME theme. Accepted."; ZSH_DEFAULT_THEME=$ZTHEME; 
        else echo "$ZTHEME theme not found."; thmenter;
    fi
}
function getoh (){
    echo; echo "[$(($snumb-3))/$snumb] wget oh-my-zsh";
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
}

###############################################################

function downloadmod (){
    echo; echo "[$(($snumb-2))/$snumb] theme";
    wget -O ${ZSH_CUSTOM}/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh/master/fatllama.zsh-theme
    echo; echo "[$(($snumb-2))/$snumb] fast-syntax-highlighting";
    git clone https://github.com/zdharma/fast-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting
    echo; echo "[$(($snumb-2))/$snumb] history-substring-search";
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/zsh-history-substring-search
    echo; echo "[$(($snumb-2))/$snumb] zsh-autosuggestions";
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
    
    if [[ $ZTHEME ]]; then thmcheck;
    elif [[ $ZEASY ]]; then ZSH_DEFAULT_THEME="robbyrussell";
    else thmenter
    fi
    echo "[$(($snumb-1))/$snumb] Theme you entered is $ZSH_DEFAULT_THEME"; echo;

    # Get and export username and theme
    sed -i.tmp "6s/^/export USER_ZSH=$(echo $USER)/" $HOME/.zshrc
    sed -i.tmp "7s/^/export ZSH_DEFAULT_THEME=$(echo $ZSH_DEFAULT_THEME)/" $HOME/.zshrc
    rm -rf $HOME/.zshrc.tmp
}
###############################################################

function ubuntu-install(){
    pwcheck
    echo; echo "[$(($snumb-3))/$snumb] $PKT_MGR install";
    echo $PASSWD | sudo -S $PKT_MGR install -y zsh
    getoh

    echo; echo "[$(($snumb-3))/$snumb] change shell to zsh";
    echo $PASSWD | chsh -s `which zsh`
    if [[ $ZEASY ]]; then echo "No root shell change"; 
    else
        while true; do
            read -p "[$(($snumb-3))/$snumb] Do you want to change root shell too? [y/N]: " yn
            case $yn in
                [yY] | [yY][Ee][Ss]  ) echo "[$(($snumb-3))/$snumb] sudo change root shell to zsh"; echo $PASSWD | sudo -S chsh -s `which zsh`; break;;
                [nN] | [n|N][O|o] | '' ) echo "[$(($snumb-3))/$snumb] root shell stays default"; break;;
                * ) echo "Please answer y[es] or N[o].";;
            esac
        done
    fi
    echo; echo "[$(($snumb-2))/$snumb] zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/zshrc/.zshrc-linux
    downloadmod
}
###############################################################

function mac-install(){
    cd /usr/local/Cellar
    mkdir zsh zsh-completions 2> /dev/null
    cd $pwd

    echo "[$(($snumb-3))/$snumb] make chown for brew (/usr/local/Cellar/zsh*)";
    chown -R $(whoami):admin /usr/local/Cellar/zsh*
    echo; echo "[$(($snumb-3))/$snumb] $PKT_MGR install";
    $PKT_MGR install -y zsh zsh-completions
    getoh

    echo; echo "[$(($snumb-3))/$snumb] change shell to brew zsh";
    dscl . -create /Users/$USER UserShell `which zsh`
    echo; echo "[$(($snumb-2))/$snumb] zshrc";
    wget -O $HOME/.zshrc https://raw.githubusercontent.com/malltaf/zsh/master/zshrc/.zshrc-mac
    downloadmod
}
###############################################################

function linux-remove(){
    echo $PASSWD | sudo -S $PKT_MGR remove -y zsh
    echo $PASSWD | chsh -s `which bash`
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
    if [[ $PKT_MGR == "brew" ]]; then mac-remove; else linux-remove; fi
}
###############################################################

function wetry(){ echo "We will try $PKT_MGR as packet manager for $zshdo zsh"; }



###################### Here is the start ######################

# Options -y: installation with all defaults; -t with argument: name of zsh theme
# -y: Install zsh with oh-my-zsh AND robbyrussell theme (if -t is empty) TO the user who runs (only for linux)
while getopts :yt: option
do
    case "${option}"
    in
        y) ZEASY=true;;
        t) ZTHEME=${OPTARG};;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
# To remember your path
pwd=$(pwd)
# Give step numbers
snumb=5
# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [[ "$UNAME" == "linux" ]]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[[ "$DISTRO" == "" ]] && export DISTRO=$UNAME

# Install/Uninstall
if [[ $ZEASY ]]; then echo "Install zsh"; zshdo="install";
else 
    while true; do
        read -p "Do you want to install or uninstall ZSH? [1(I)/2(u)]: " iu;
        case $iu in
            [1] | [Ii] | '' ) zshdo="install"; break;;
            [2] | [Uu] ) zshdo="uninstall"; break;;
            * ) echo "Please answer 1 or 2.";;
        esac
    done
fi

echo "You use $DISTRO distribution"
case "$DISTRO" in
    "darwin" ) 
            PKT_MGR="brew"; wetry; if [[ $zshdo == "install" ]]; then mac-install; else zsh-remove; fi;;
    "ubuntu" | "Ubuntu" ) 
            PKT_MGR="apt"; wetry; if [[ $zshdo == "install" ]]; then ubuntu-install; else zsh-remove; fi;;
    "centos" ) 
            PKT_MGR="yum"; wetry; if [[ $zshdo == "install" ]]; then centos-install; else zsh-remove; fi;; #
    * ) echo "Unknown OS, exit."; exit 1;;
esac
unset UNAME DISTRO pwd PASSWD PKT_MGR zshdo snumb

echo; echo; echo "Start the new session to changes to take effect.";
