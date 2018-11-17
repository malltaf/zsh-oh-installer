#!/bin/bash

while true; do
    read -p "Do you want to install or uninstall ZSH? [1(I)/2(u)]: " iu
    case $iu in
        [1] | [Ii] | '' ) wget -O - https://raw.githubusercontent.com/malltaf/zsh/master/zsh-install.sh | bash; break;;
        [2] | [Uu] ) wget -O - https://raw.githubusercontent.com/malltaf/zsh/master/zsh-remove.sh | bash; break;;
        * ) echo "Please answer 1 or 2.";;
    esac
done
