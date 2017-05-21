# Ensure profile is loaded
bash_root=~/my_projects/bash-functions
gitenv() { . <(curl -sS https://raw.githubusercontent.com/jeffreydvp/bash-functions/master/functions.sh); }
myenv() { . $bash_root/main.sh; }

if [ "$0" != 'bash' ];then
  bash -l
  return 0
fi

alias clean_branches='for b in `git branch|sed "/^\*/d"|sed "/develop/d"`;do git branch -d $b;done'
if ! hash ruby 2>/dev/null;then
  return 0
fi


# Reload env

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

ruby $bash_root/main.rb
echo 'Loaded environment'