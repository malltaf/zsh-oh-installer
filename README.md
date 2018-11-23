# zsh-oh-installer
zsh with oh-my-zsh configurations for mac/ubuntu/centos

## Installation
To install just run the command
```
Still in work
```

### Miscellaneous info
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
`alias zshconfig="nano ~/.zshrc"
alias p8="ping 8.8.8.8"
alias pya="ping ya.ru"
alias ohmyzsh="nano ~/.oh-my-zsh"
alias n="nano"
alias v="vim"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dpsi="docker images"
alias dst="docker stats"
alias drun="docker run -d"
alias docoup="docker-compose up -d"
alias docodown="docker-compose down"
alias docostart="docker-compose start"
alias docostop="docker-compose stop"
alias dexec="docker exec -it"
alias dstop="docker stop"
alias drm="docker rm"
alias drmi="docker rmi"`
You can delete aliases from the end of ~/.zshrc file.

### Testing info
Script tested on Ubuntu 18.04.1, CentOS 7.5.1804, macOS 10.14.1
