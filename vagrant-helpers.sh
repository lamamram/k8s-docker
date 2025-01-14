#!/bin/bash

v_list(){
  vagrant box list
}

v_box(){
  box_version = ""
  if [[ "$#" -ge 3 ]]; then
    box_version = "--box-version $3"
  fi
  vagrant box $1 $2 $3
}

v_add(){
  if [[ "$#" -ge 2 ]]; then
    v_box add $1 $2
  else
    v_box add $1
  fi
}

v_remove(){
  if [[ "$#" -ge 2 ]]; then
    v_box add $1 $2
  else
    v_box add $1
  fi
}

v_destroy() {
  if [[ -f ./Vagrantfile  ]]; then
    vagrant destroy -f && rm -rf .vagrant
  else
    echo "no Vagrantfile !"
  fi
}

v_prune() {
  if [[ -f ./Vagrantfile ]]; then
    vagrant halt && v_destroy
  else
    echo "no Vagrantfile !"
  fi
}

v_ssh_jenkins() {
  if [[ -f ~/.vagrant.d/boxes/ml-registry-VAGRANTSLASH-jenkins/1.1/amd64/virtualbox/vagrant_private_key ]]; then
    if [[ -f ./Vagrantfile ]]; then
      ssh -i "~\.vagrant.d\boxes\ml-registry-VAGRANTSLASH-jenkins\1.1\amd64\virtualbox\vagrant_private_key" -p 2202 vagrant@127.0.0.1
    else
      echo "no Vagrantfile !"
    fi
  else
    echo "no image jenkins !!!"
  fi
}