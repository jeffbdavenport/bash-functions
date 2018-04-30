# Ensure profile is loaded
bash_root=~/my_projects/bash-functions

compare_develop() {
    git branch -D compare_develop
    git checkout -b compare_develop && git merge origin/develop --squash -s recursive && git add -A && git commit -m "merge"
}

delete_compare_develop() {
  git reset --hard && git checkout "$1"  && git branch -D compare_develop
}

develop_diff() {
  branch=$(git branch --merged|grep \*|sed "s/^* //")
  compare_develop >/dev/null 2>&1 && git diff origin/develop --name-status | grep -v ^D && delete_compare_develop "$branch" >/dev/null 2>&1
}

changed_files() {
  diff=$(develop_diff)
  echo "$diff"
  if [ ! -z "$diff" ];then
    atom $(echo "$diff"|sed 's/^.\s*//'|tr '\n', ' ')
  fi
}

gitenv() { . <(curl -sS https://raw.githubusercontent.com/jeffreydvp/bash-functions/master/functions.sh); }
myenv() { . $bash_root/main.sh; }
xmod() { xmodmap ~/.Xmodmap; }
if [ "$0" != 'bash' ];then
  bash -l
  return 0
fi
. ~/git_prompt.bash
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
clean_branches(){
  git checkout develop
  for b in `git branch --merged|sed "/^\*/d"|sed "/develop/d"`;do
    git branch -d $b
  done
}
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

  if ! $(git diff-index --quiet HEAD --);then
    git commit -am "$all"
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

duse(){
  dir='.'
  lines='20'
  if [ -e "$1" ];then
    dir="$1"
  else
    if [[ $1 =~ ^[0-9]+$ ]];then
      lines="$1"
    fi
  fi
  if [ -e "$2" ];then
    dir="$2"
  else
    if [[ $2 =~ ^[0-9]+$ ]];then
      lines="$2"
    fi
  fi
  du -axh "$dir"|sort -hr|head -n "$lines"|sort -k 2,2|sed "s/^\([0-9]*\)\([MKG]\)/\1.0\2/;s/^\([0-9]\.[0-9][MK]\)/0\1/"
}

ext()
# Handy Extract Program
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xvjf $1     ;;
      *.tar.gz)  tar xvzf $1     ;;
      *.bz2)     bunzip2 $1      ;;
      *.rar)     unrar x $1      ;;
      *.gz)      gunzip $1       ;;
      *.tar)     tar xvf $1      ;;
      *.tbz2)    tar xvjf $1     ;;
      *.xz)      tar xvJf $1     ;;
      *.tgz)     tar xvzf $1     ;;
      *.zip)     unzip $1        ;;
      *.Z)       uncompress $1   ;;
      *.7z)      7z x $1         ;;
      *)         echo "'$1' cannot be extracted via >extract<" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

ssh()
{
  guake -e "guake -r $1"
  guake -e "/usr/bin/ssh ${@:1}"
}

rails()
{
  if [ "$1" == "c" ];then
    guake -r "local-console"
  elif [ "$1" == "s" ];then
    guake -r "local-server"
  fi
  $GEM_HOME/bin/rails ${@:1}
}

ruby $bash_root/main.rb
guake -r 'local'
echo 'Loaded environment'
