alias gst='git status'
__git_complete gst _git_status
alias gci='git commit'
__git_complete gci _git_commit
alias gco='git checkout'
__git_complete gco _git_checkout
alias gadd='git add .'
alias push='git push'
__git_complete push _git_push
alias pull='git pull'
__git_complete pull _git_pull
alias fetch='git fetch'
__git_complete fetch _git_fetch
alias gbr='git branch'
__git_complete gbr _git_branch

# eval `ssh-agent -s`
# ssh-add ~/.ssh/jenkins

function mkcd {
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d $last ]; then
    echo "\`$last' already exists"
  else
    mkdir $@ && cd $last
  fi
}

function acp {
	if [ 1 -ne $# ]; then
	  echo "bad message !"
	else
	  gadd && gci -m "$1" && push
	fi
}
