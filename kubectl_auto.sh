#!/bin/bash

echo '' >>~/.bashrc

cat <<EOF >> ~/.bashrc
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
# source <(helm completion bash)

export LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -la'
alias l='ls $LS_OPTIONS -lA'
EOF
source ~/.bashrc