#!/bin/bash -l
myenv() { . ~/my_projects/bash-functions/main.sh; }

gitc() {
  # Don't push to these branches
  declare -A safe_branches=([develop]=1 [dev]=1 [master]=1)

  if [ "$1" == '-u' ] || [ "$1" == '-A' ];then
    git add "$1"
    commit="${@:2}"
  else
    commit="${@:1}"
  fi
  if ! $(git diff-index --quiet HEAD --);then
    git commit -m "$commit"
    current="$(git rev-parse --abbrev-ref HEAD)"
    if [ "$current" == 'rails-base' ];then
      git push -u rails-base rails-base:master
    elif [[ -n "${allowed_branches[$current]}" ]];then
      echo "Must manually push to dev and master"
    else
      git push
    fi
  fi
}
