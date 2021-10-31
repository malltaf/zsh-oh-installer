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

function zsh-clean(){
	bash -c "$(wget https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/zsh-oh-installer.sh -O -)" $1 $2 $3 $4
}

function zsh-full(){
	[[ -f ./zsh-oh-installer ]] && rm -rf ./zsh-oh-installer
	git clone https://github.com/malltaf/zsh-oh-installer.git
	/bin/bash zsh-oh-installer.sh - -y -t fatllama
	rm -rf ./zsh-oh-installer
}

echo "1 - Install git/wget/micro etc";echo "2 - (Un)Install oh-my-zsh with plugins (wget and git is needed)";echo "3 - Install 1 and 2 (with default options)"
while true; do
    read -p "(1/2/[3]): " ae
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
				echo "1 - Full installation with fatllama theme"; echo "2 - Uninstall oh-my-zsh"; echo "3 - Just run zsh-installer with choice"
		        read -p "Make your choice ([1]/2/3): " iu
		        case $iu in
		            [1] | '' ) zsh-clean - -y -t fatllama; break;;
		            [2] ) zsh-clean - -r; break;;
		            [3] ) zsh-clean; break;;
		            * ) echo "Please answer 1(default) or 2 or 3";;
		        esac
		     done;;
	"all" )  software; zsh-full;;
    * ) echo "Unknown error of choice, exit."; exit 1;;
esac

exit 0
