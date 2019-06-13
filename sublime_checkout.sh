#!/bin/bash

# SETUP
# In ~/.gitconfig add these two lines
#
# [alias]
#  scheckout = !sh /full/path/to/sublime_checkout.sh


project_home="$HOME/.config/sublime-text-3/Packages/User/Projects"
if [ ! -d "$project_home" ];then
  project_home="$HOME/Library/Application Support/Sublime Text 3/Packages/User/Projects"
fi

branch="$1"
prev_branch="$(git rev-parse --abbrev-ref HEAD)"
if [ -z "$branch" ];then
  branch="$prev_branch"
fi

# Get root directory of repository
pwd="$(git rev-parse --show-toplevel)"
project="$(basename "$pwd")"

SC_checkout() {
  echo "Project Home: $project_home"

  if git checkout "$branch" || git checkout -b "$branch";then
    SC_create_project

    workspace="$project_home/$project/$branch.sublime-project"
    echo "Switching to $workspace"
    if [ -f "$workspace" ];then
      subl "$workspace" -a
      sleep 0.1
      subl "$workspace" -a
    else
      echo "Invalid workspace! $workspace"
    fi
  fi
}

SC_create_project() {
  folders="$pwd"
  cd "$project_home"
  if [ ! -f "$project.sublime-project" ];then
    cat <<EOF > "$project.sublime-project"
{
  "folders":
  [{
    "path": "$folders"
  }]
}
EOF
  fi

  mkdir -p "$(dirname "$project/$branch")" 2>/dev/null

  if [ ! -L "$project/$branch.sublime-project" ];then
    ln -s "$project_home/$project.sublime-project" "$project/$branch.sublime-project"
  fi
  cd -
}


_git_scheckout() {
  _git_checkout
}


SC_checkout
