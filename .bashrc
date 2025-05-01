export PATH=$HOME/.krew/bin:$PATH

# Enable bash completion if available
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [ -f "$HOME/.bash_completion" ]; then
    . "$HOME/.bash_completion"
fi

# Aliases
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias kubectl="kubecolor"
alias k="kubecolor"
alias tf="terraform"
alias h="helm"

# History settings
export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTCONTROL=ignorespace:ignoredups:erasedups

# Prompt
export PS1="\[\e[0;32m\]\u@\h\[\e[m\]:\[\e[0;34m\]\w\[\e[m\]\$ "

# Terminal settings
export TERM=xterm-256color
