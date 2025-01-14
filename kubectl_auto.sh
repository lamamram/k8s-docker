#!/bin/bash

grep "alias k=kubectl" "$HOME/.bashrc" > /dev/null
if [[ "$?" -ne 0 ]]; then

  echo "" >> "$HOME/.bashrc"

  cat <<EOF >> "$HOME/.bashrc"
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
source <(helm completion bash)

export LS_OPTIONS='--color=auto'
EOF
  source "$HOME/.bashrc"
fi

