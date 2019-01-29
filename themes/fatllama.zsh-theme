# Personalized!
# OLD BIRA THEME
local return_code="%(?..%{$FG[088]%}-%?-%{$reset_color%})"

if [[ $UID -eq 0 ]]; then
    local user_symbol='%{$terminfo[bold]$FG[131]%}#%{$reset_color%}'
else
    local user_symbol='%{$terminfo[bold]$FG[186]%}$%{$reset_color%}'
fi

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH2_CLIENT" ]; then
    local user_host='%{$FG[242]%}ssh-%{$reset_color%}%{$terminfo[bold]$FG[065]%}%n@%m:%{$reset_color%}'
elif [[ $(ps -o comm= -p $PPID) == "sshd" ]] || [[ $(ps -o comm= -p $PPID) == "*/sshd" ]]; then
    local user_host='%{$FG[242]%}ssh-%{$reset_color%}%{$terminfo[bold]$FG[065]%}%n@%m:%{$reset_color%}'
else
    local user_host='%{$terminfo[bold]$FG[065]%}%n@%m:%{$reset_color%}'
fi

local git_branch='$(git_prompt_info)%{$reset_color%}'
local current_time="%{$FG[240]%}%D{%H:%M:%S}%{$reset_color%}"
local current_dir='%{$terminfo[bold]$FG[074]%}%~%{$reset_color%}'

local rvm_ruby=''
if which rvm-prompt &> /dev/null; then
  rvm_ruby='%{$FG[125]%}<$(rvm-prompt i v g)>%{$reset_color%}'
else
  if which rbenv &> /dev/null; then
    rvm_ruby='%{$FG[125]%}<$(rbenv version | sed -e "s/ (set.*$//")>%{$reset_color%}'
  fi
fi

PROMPT="${user_host}${current_dir} %B${user_symbol}%b "
RPROMPT="%B${return_code}%b ${rvm_ruby} ${git_branch} ${current_time}"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[167]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[022]%}"
