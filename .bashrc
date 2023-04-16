source /etc/profile.d/bash_completion.sh
source $HOME/.bash_completion
alias update='apk update && apk upgrade'
export HISTTIMEFORMAT="%d/%m/%y %T "
export PS1='\u@\h:\W \$ '
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias kubectl="kubecolor"
alias k="kubecolor"
alias tf="terraform"
alias h="helm"
export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "
export HISTCONTROL=ignorespace:ignoredups:erasedups
export PATH=$HOME/go/bin:$PATH
