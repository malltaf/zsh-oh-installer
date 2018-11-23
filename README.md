# zsh-oh-installer
Zsh with oh-my-zsh configurations for mac/ubuntu/centos

## Getting started
### Prerequisites (from [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh))
- Unix-like operating system (macOS or Linux)
- `wget` should be installed
- `git` should be installed

### Installation
To install just run the commands
```
wget https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/zsh-oh-installer.sh
bash zsh-oh-installer.sh
```
### Installation options
Script can install or remove zsh with oh-my-zsh. It will be asked at the first stage.  
You can use some options when calling the script:  
`-y`: installation with all defaults.  
Install zsh with oh-my-zsh AND robbyrussell theme (if `-t` is empty) TO the user who runs (only for linux).  
*Priority in the script = 3 (low).*  
`-t <theme>`: allows you to immediately specify the theme of the program.  
Only installation is performed.  
*Priority in the script = 2 (high).*  
`-r`: only deletion is performed.  
*Priority in the script = 1 (highest);*  
Example: `bash zsh-oh-installer.sh -y -t fatllama` - this command will install all with the fatllama theme.  
Example: `bash zsh-oh-installer.sh -y -t fatllama -r` - because of the priority this command will only delete.  

Also, the script will offer to install a shell for root (only in Linux).  
## Plugins info
What plugins are included?  
Simple plugins:  
`aws command-not-found debian docker encode64 fasd git history last-working-dir osx sudo tig wd`  
Plugins with download:  
[fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting)  
[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)  
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)  
They are all in ~/.oh-my-zsh/custom/plugins/  
You can delete them and clear a plugin list in ~/.zshrc    

Aliases are prepared:  
`alias zshconfig="nano ~/.zshrc"`  
`alias p8="ping 8.8.8.8"`  
`alias pya="ping ya.ru"`  
`alias ohmyzsh="nano ~/.oh-my-zsh"`  
`alias n="nano"`  
`alias v="vim"`  
`alias dps="docker ps"`  
`alias dpsa="docker ps -a"`  
`alias dpsi="docker images"`  
`alias dst="docker stats"`  
`alias drun="docker run -d"`  
`alias docoup="docker-compose up -d"`  
`alias docodown="docker-compose down"`  
`alias docostart="docker-compose start"`  
`alias docostop="docker-compose stop"`  
`alias dexec="docker exec -it"`  
`alias dstop="docker stop"`  
`alias drm="docker rm"`  
`alias drmi="docker rmi"`  
You can delete aliases from the end of ~/.zshrc file.

Also included is a theme that I am developing: `fatllama`

## Testing info
Script tested on Ubuntu 18.04.1, CentOS 7.5.1804, macOS 10.14.1
