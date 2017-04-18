#!/bin/bash -l
# Reload env
gitenv() { . <(curl -sS https://raw.githubusercontent.com/jeffreydvp/bash-functions/master/functions.sh); }
myenv() { . ~/my_projects/bash-functions/main.sh; }

gitc() {
  declare -A safe_branches=(
    [develop]=1, [dev]=1, [master]=1
  )

  if [ -z "$@" ] || [ "$1" == '-h' ];then
    gitc_help
    return 0
  fi
  # Don't push to these branches

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
    elif [[ -n "${safe_branches[$current]}" ]];then
      echo "Must manually push to dev and master"
    else
      git push
    fi
  fi
}

gitc_help() {
cat <<'EOF'

Commit tracked
gitc -u <commit message>

Commit all
gitc -A <commit message>

Commit only
gitc <commit message>
EOF
}
