# zsh-oh-installer
Zsh with oh-my-zsh configurations for macOS/Ubuntu/CentOS

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
The script will ask for your sudo password. The password will need to be entered only once. This is required for correct installation.  
Also it will clarify: remove or install; whether to install in the root; which theme to install.  

### Installation options
The script can install or remove zsh with oh-my-zsh. It will be asked at the first stage.  
You can use some options when calling the script:  
`-y`: installation with all defaults.  
Install zsh with oh-my-zsh AND robbyrussell theme (if `-t` is empty) TO the user who runs (only for Linux).  
*Script priority = 3 (low).*  
`-t <theme>`: allows you to immediately specify the theme of the program.  
Only installation is performed.  
*Script priority = 2 (high).*  
`-r`: only deletion is performed.  
*Script priority = 1 (highest);*  
Example: `bash zsh-oh-installer.sh -y -t fatllama` - this command will install all with the fatllama theme.  
Example: `bash zsh-oh-installer.sh -y -t fatllama -r` - because of the priority this command will only delete.  

Also, the script will offer to install a shell for root (only in Linux).  

## Included plugins 
Simple plugins:  
`aws command-not-found debian docker encode64 fasd git history last-working-dir osx sudo tig wd`  

Downloadable plugins:  
[fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting)  
[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)  
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)  
They are all in ~/.oh-my-zsh/custom/plugins/  
You can delete them and clean them from the list of plugins in the ~/.zshrc    

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
You can delete aliases from the end of the ~/.zshrc file.

Also included a theme that I use: `fatllama`

## Testing info
Script tested on Ubuntu 18.04.1, CentOS 7.5.1804, macOS 10.14.1
