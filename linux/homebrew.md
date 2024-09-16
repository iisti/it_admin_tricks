# Homebrew

## Install Homebrew

Tested with Debian 12 WSL2.
  
1. Install <https://brew.sh/>
1. Configurations <https://docs.brew.sh/Homebrew-on-Linux>

* If there's an error `-bash: /bin/brew: No such file or directory`, when opening a new Debian Terminal, check content of `~/.bashrc`

  ~~~shell
  #eval "$(/bin/brew shellenv)" # This line needed to be commented out.
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ~~~
