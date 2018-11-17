#!/bin/bash

function linux-remove(){
echo $PASSWD | sudo -S $PKT_MGR remove -y zsh
echo $PASSWD | chsh -s `which bash`
}

function mac-remove(){
$PKT_MGR remove -y zsh
echo $PASSWD | sudo -S dscl -P $PASSWD . -create /Users/$USER UserShell `which bash`
rm -rf /usr/local/Cellar/zsh*
}

# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME
unset UNAME

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

# Uminstallation process
echo "You use $DISTRO distribution"

uninstall_oh_my_zsh
rm -rf ~/.oh*
rm -rf ~/.zsh*

echo -n "We will try "
case "$DISTRO" in
    "darwin" ) PKT_MGR="brew"; echo -n "$PKT_MGR as packet manager for uninstall zsh"; echo; mac-remove;;
    "ubuntu" | "Ubuntu" ) PKT_MGR="apt-get"; echo -n "$PKT_MGR as packet manager for uninstall zsh"; linux-remove;;
    "centos" ) PKT_MGR="yum"; echo -n "$PKT_MGR as packet manager for uninstall zsh"; linux-remove;;
    * ) echo "Unknown OS, exit."; exit 1;;
esac
unset DISTRO