#!/bin/bash

# SETUP
# In ~/.gitconfig add these two lines
#
# [alias]
#  scheckout = !sh /full/path/to/sublime_checkout.sh


projects_home="$HOME/.config/sublime-text-3/Packages/User/Projects"
if [ ! -d "$projects_home" ];then
  projects_home="$HOME/Library/Application Support/Sublime Text 3/Packages/User/Projects"
fi

branch="$1"
prev_branch="$(git rev-parse --abbrev-ref HEAD)"
if [ -z "$branch" ];then
  branch="$prev_branch"
fi

# Get root directory of repository
pwd="$(git rev-parse --show-toplevel)"
project="$(basename "$(dirname "$pwd")")_$(basename "$pwd")"

SC_checkout() {
  echo "Projects Home: $projects_home"

  if git checkout "$branch" || git checkout -b "$branch";then
    SC_create_project

    workspace="$projects_home/$project/$branch.sublime-project"
    echo "Switching to $workspace"
    if [ -f "$workspace" ];then
      subl --project "$workspace" -a
      # sleep 0.1
      # subl --project "$workspace" -a
    else
      echo "Invalid Project! $workspace"
    fi
  fi
}

SC_create_project() {

  folders="$pwd"
  cd "$projects_home"
  mkdir -p "$project" 2>/dev/null

  if [ ! -f "$project/master.sublime-project" ];then
    cat <<EOF > "$project/master.sublime-project"
{
  "folders":
  [{
    "path": "$folders"
  }]
}
EOF
  fi

  if [ ! -L "$project/$branch.sublime-project" ];then
    cp "$projects_home/$project/master.sublime-project" "$project/$branch.sublime-project"
  fi
  cd -
}


_git_scheckout() {
  _git_checkout
}


SC_checkout
