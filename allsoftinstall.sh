#!/bin/bash
###############################################################
source functions.sh

function software(){
	pwcheck
	echo $PASSWD | sudo -S apt update -y;
	echo $PASSWD | sudo -S apt install -y xclip wget git;
	echo $PASSWD | sudo -S curl https://getmic.ro | bash;
	echo $PASSWD | sudo -S mv micro /usr/bin
	echo "{
    \"clipboard\": \"terminal\"
}" > ~/.config/micro/settings.json
}

ZSHCOMMAND(){
	/bin/bash zsh-oh-installer.sh	
}

echo "1 - Install git/wget/micro etc";echo "2 - (Un)Install oh-my-zsh with plugins (wget and git is needed)";echo "3 - Install 1 and 2 (with default options)"
while true; do
    read -p "[1/2/>3<]: " ae
    case $ae in
        [1] ) INDO="apps"; break;;
        [2] ) INDO="zsh"; break;;
        [3] | '' ) INDO="all"; break;;
        * ) echo "Please answer 1 or 2 or 3 (default option).";;
    esac
done

case "$INDO" in
    "apps" ) software;;
    "zsh" )  while true; do
		        read -p "Make your choice \n1 - Full installation with fatllama theme\n2 - Uninstall oh-my-zsh\n3 - Just run zsh-installer with choice\n[>1</2/3]: " iu
		        case $iu in
		            [1] | '' ) ZSHCOMMAND - -y -t fatllama; break;;
		            [2] ) ZSHCOMMAND - -r; break;;
		            [3] ) ZSHCOMMAND; break;;
		            * ) echo "Please answer 1(default) or 2 or 3";;
		        esac
		     done;;
	"all" )  software; tes;;
    * ) echo "Unknown error of choice, exit."; exit 1;;
esac

exit 0
