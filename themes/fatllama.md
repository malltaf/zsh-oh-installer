## Description
What it's looks like? Simple!  
Checks for ruby version, github branch and status, current time and error number in the right place. Root/user input symbol. 

CentOS example:
![centos2](https://user-images.githubusercontent.com/7456824/51802852-fc7f9280-225e-11e9-91e6-1bb40b081ab2.jpg)

MacOS (iTerm2) example:
![macos](https://user-images.githubusercontent.com/7456824/51802723-c1c92a80-225d-11e9-96f8-e5e2b672df53.jpg)

Ubuntu Server (iTerm2) example:
![ubuntu](https://user-images.githubusercontent.com/7456824/51802731-cb529280-225d-11e9-85df-76374c0bec1c.jpg)

## Installation
You can download it to your ohmyzsh by commands:  
```
mkdir -p ${ZSH_CUSTOM}/lib && wget -O ${ZSH_CUSTOM}/lib/git.zsh https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/lib/git.zsh;
wget -O ${ZSH_CUSTOM}/themes/fatllama.zsh-theme https://raw.githubusercontent.com/malltaf/zsh-oh-installer/master/themes/fatllama.zsh-theme
```

And then activate it in your .zshrc file: `fatllama`. And reload you zsh prompt.
P.S. You will need uncomment string with ZSH_CUSTOM variable in .zshrc and choose the right way to it.
