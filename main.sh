#!/bin/bash -l
myenv() { . ~/my_projects/bash-functions/main.sh; }

gitc() {
  if [ "$1" == '-u' ] || [ "$1" == '-A' ];then
    git add "$1"
  fi
  if ! $(git diff-index --quiet HEAD --);then
    git commit -m "${@:2}"
    if [ "$(git rev-parse --abbrev-ref HEAD)" == 'rails-base' ];then
      git push -u rails-base rails-base:master
    else
      git push
    fi
  fi
}
