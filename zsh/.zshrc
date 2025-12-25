# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Prompt theme
autoload -Uz promptinit
promptinit

prompt_lyktheme_setup(){
	PROMPT="%F{green}%n%f@%F{magenta}%m%f:%F{cyan}%~%f%# "	
	RPROMPT="%F{yellow}[%T]%f"	
}
prompt_themes+=( lyktheme )
prompt lyktheme
# End Prompt theme

# Alias
alias ll="ls --color -al"
alias grep="grep --color=auto"
# End Alias

# Proxy
function setproxy(){
	export http_proxy=socks5://127.0.0.1:10808
	export https_proxy=socks5://127.0.0.1:10808
	export ftp_proxy=socks5://127.0.0.1:10808
}

function unsetproxy(){
	unset http_proxy https_proxy ftp_proxy
}
# End proxy

# COPT optimizer
export COPT_HOME=$HOME/opt/copt72
export COPT_LICENSE_DIR=$HOME/opt/copt72
export PATH=$COPT_HOME/bin:$PATH
export LD_LIBRARY_PATH=$COPT_HOME/lib:$LD_LIBRARY_PATH
# End COPT

### IME ###
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_IM_MODULE=fcitx
