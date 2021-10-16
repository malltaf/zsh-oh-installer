#!/bin/bash
###############################################################
source ./functions.sh

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
