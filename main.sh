# Load the profile
if [ -z ${PROFILE_LOADED+defined} ];then
  export PROFILE_LOADED=1
  sleep 0.1
  /bin/bash -l
  return 0
fi

clean_branches(){
  git checkout develop
  for b in `git branch --merged|sed "/^\*/d"|sed "/develop/d"`;do
    git branch -d $b
  done
}

# Reload env
gitenv() { . <(curl -sS https://raw.githubusercontent.com/jeffreydvp/bash-functions/master/functions.sh); }
myenv() { . ~/my_projects/bash-functions/main.sh; }

gitc() {
  # Don't push to these branches
  declare -A safe_branches=(
    [develop]=1, [dev]=1, [master]=1
  )

  all="${@:1}"
  if [ -z "$all" ] || [ "$1" == '-h' ];then
    gitc_help
    return 0
  fi

  if [ "$1" == '-u' ] || [ "$1" == '-A' ];then
    git add "$1"
    commit="${@:2}"
  else
    commit="$all"
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

PATH=$(ruby -e "puts '$PATH'.split(':').uniq.join(':')")
