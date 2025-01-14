#### VAGRANT
## à ajouter au profile.ps1 => echo $PROFILE

function v_list {
  vagrant box list
}

function v_box {
  param (
    [string]$Verb,
    [string]$Name,
    [string]$Version
  )
  $box_version = "--box-version $Version"
  if ([string]::IsNullOrEmpty($Version)) {
    $box_version = ""
  }
  vagrant box $Verb $Name $box_version
}

function v_add {
  param (
    [string]$Name,
    [string]$Version
  )
  v_box add $Name $box_version
}

function v_remove {
  param (
    [string]$Name,
    [string]$Version
  )
  v_box remove $Name $box_version
}
function v_destroy {
  if (Test-Path .\Vagrantfile -PathType Leaf){
    vagrant destroy -f; Remove-Item -Recurse .vagrant
  }
  else {
    wo "no Vagrantfile !"
  }
}
function v_prune {
  if (Test-Path .\Vagrantfile -PathType Leaf){
    vagrant halt; v_destroy
  }
  else {
    wo "no Vagrantfile !"
  }  
}

function v_ssh_jenkins {
  if (Test-Path ~\.vagrant.d\boxes\ml-registry-VAGRANTSLASH-jenkins\1.1\amd64\virtualbox\vagrant_private_key -PathType Leaf){
    if (Test-Path .\Vagrantfile -PathType Leaf){  
      ssh -i "~\.vagrant.d\boxes\ml-registry-VAGRANTSLASH-jenkins\1.1\amd64\virtualbox\vagrant_private_key" -p 2202 vagrant@127.0.0.1
    }
    else {
      wo "no Vagrantfile !"
    }
  }
  else {
    "no image jenkins !!!"
  }
}