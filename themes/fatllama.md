## Description
What it's looks like? Simple!  
Shows the current git branch name (no `git status` — fast even in huge repos), ruby version, current time and error code on the right. Root/user input symbol on the left. 

CentOS example:
![centos2](https://user-images.githubusercontent.com/7456824/51802852-fc7f9280-225e-11e9-91e6-1bb40b081ab2.jpg)

MacOS (iTerm2) example:
![macos](https://user-images.githubusercontent.com/7456824/51802723-c1c92a80-225d-11e9-96f8-e5e2b672df53.jpg)

Ubuntu Server (iTerm2) example:
![ubuntu](https://user-images.githubusercontent.com/7456824/51802731-cb529280-225d-11e9-85df-76374c0bec1c.jpg)

## Installation
Download it into your oh-my-zsh custom themes:
```
curl -fsSL https://raw.githubusercontent.com/malltaf/zsh-oh-installer/main/themes/fatllama.zsh-theme \
  -o "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/fatllama.zsh-theme"
```

Then set `ZSH_THEME="fatllama"` in your `.zshrc` and reload the shell.  
The theme relies only on `git_current_branch`, a core oh-my-zsh function, so no extra `lib/git.zsh` is needed.
