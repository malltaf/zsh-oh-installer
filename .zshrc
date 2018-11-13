# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
USER_ZSH='dpopov'
# Path to your oh-my-zsh installation.
export ZSH="/home/$USER_ZSH/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="malltaf1"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
#ZSH_THEME_RANDOM_CANDIDATES=( "aussiegeek" "dieter" "amuse" )

# Uncomment the following line to use case-sensitive completion.
 CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
 ZSH_CUSTOM=/home/$USER_ZSH/.oh-my-zsh/custom/

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  aws brew command-not-found debian docker encode64 fasd fast-syntax-highlighting git history history-substring-search last-working-dir osx sudo tig wd zsh-autosuggestions zsh-bash
)

source ~/.zshrc
source $ZSH/oh-my-zsh.sh
source zsh-autosuggestions.zsh
source zsh-syntax-highlighting.zsh
source zsh-history-substring-search.zsh

#mac
#source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nano ~/.zshrc"
export PATH="/usr/local/sbin:$PATH"
alias p8="ping 8.8.8.8"
alias pya="ping ya.ru"
alias ohmyzsh="nano ~/.oh-my-zsh"
alias n="nano"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dpsi="docker images"
alias dstats="docker stats"
alias drun="docker run -d"
alias docoup="docker-compose up -d"
alias docodown="docker-compose down"
alias docostart="docker-compose start"
alias docostop="docker-compose stop"
alias dexec="docker exec -it"
alias dstop="docker stop"
alias drm="docker rm"
alias drmi="docker rmi"
alias sq="echo 'ssh squirrel -l dpopov';ssh squirrel -l dpopov"
alias ra="echo 'ssh racoon -l dpopov';ssh racoon -l dpopov"
alias ttl="echo 'sudo sysctl -w net.inet.ip.ttl=65';sudo sysctl -w net.inet.ip.ttl=65"
#alias mc='. /usr/local/Cellar/midnight-commander/4.8.21/libexec/mc/mc-wrapper.sh'
