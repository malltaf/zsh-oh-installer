# Personalized!
# OLD DALLAS THEME
# Grab the current date (%D) and time (%T) wrapped in {}: {%D %T}
MALLTAF_CURRENT_TIME_="%{$fg[white]%}[%{$fg[green]%}%D%{$reset_color%}/%{$fg[green]%}%T%{$fg[white]%}]%{$reset_color%}"
# Grab the current version of ruby in use (via RVM): [ruby-1.8.7]
if [ -e ~/.rvm/bin/rvm-prompt ]; then
  MALLTAF_CURRENT_RUBY_="%{$fg[white]%}[%{$fg[magenta]%}\$(~/.rvm/bin/rvm-prompt i v)%{$fg[white]%}]%{$reset_color%}"
else
  if which rbenv &> /dev/null; then
    MALLTAF_CURRENT_RUBY_="%{$fg[white]%}[%{$fg[magenta]%}\$(rbenv version | sed -e 's/ (set.*$//')%{$fg[white]%}]%{$reset_color%}"
  fi
fi
# Grab the current machine name: muscato
MALLTAF_CURRENT_MACH_="%{$fg[cyan]%}%m%{$fg[white]%}:%{$reset_color%}"
# Grab the current filepath, use shortcuts: ~/Desktop
# Append the current git branch, if in a git repository: ~aw@master
MALLTAF_CURRENT_LOCA_="%{$fg[white]%}%~"
# Grab the current username: MALLTAF
MALLTAF_CURRENT_USER_="%{$fg[cyan]%}%n@%{$reset_color%}"
# Use a % for normal users and a # for privelaged (root) users.
MALLTAF_PROMPT_CHAR_="%{$fg[yellow]%}%(!.#.$) >%{$reset_color%}"
# For the git prompt, use a white @ and blue text for the branch name
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[white]%}@%{$fg[blue]%}"
# Close it all off by resetting the color and styles.
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
# Do nothing if the branch is clean (no changes).
ZSH_THEME_GIT_PROMPT_CLEAN=""
# Add 3 cyan ✗s if this branch is diiirrrty! Dirty branch!
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[cyan]%}"

# Put it all together!
PROMPT="$MALLTAF_CURRENT_TIME_ $MALLTAF_CURRENT_RUBY_$MALLTAF_CURRENT_USER_$MALLTAF_CURRENT_MACH_$MALLTAF_CURRENT_LOCA_ $MALLTAF_PROMPT_CHAR_ "
