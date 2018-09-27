#!/bin/bash
project_home="$HOME/.config/sublime-text-3/Packages/User/Projects"
if [ ! -d "$project_home" ];then
  project_home="$HOME/Library/Application Support/Sublime Text 3/Packages/User/Projects"
fi
echo $project_home
sublime_checkout() {
  prev_branch=$(git rev-parse --abbrev-ref HEAD)
  branch=$1
  if [ -z "$branch" ];then
    branch="$prev_branch"
  fi
  project="${PWD##*/}"
  link="$project_home/$project.sublime-workspace"
  if [ ! -f "$project_home/$project.sublime-project" ];then
    echo "No project!"
    return
  fi
  if git checkout "$branch" || git checkout -b "$branch";then
    cd "$project_home"
    if mkdir "$project" 2>/dev/null;then
      mv "$link" "$project" &&
      ln -s "$project/$project.sublime-workspace" "$link"
    fi
    if [ ! -f "$project/$branch.sublime-workspace" ];then
      if [ -f "$project/$project/$prev_branch.sublime-workspace" ];then
        cp "$project/$project/$prev_branch.sublime-workspace" "$project/$branch.sublime-workspace"
      else
        cp "$project/$project.sublime-workspace" "$project/$branch.sublime-workspace"
      fi
    fi
    if [ -L "$project.sublime-workspace" ];then
      if [ "$(readlink -f $link)" != "$project_home/$project/$branch.sublime-workspace" ];then
        if rm "$project.sublime-workspace";then
          ln -s "$project/$branch.sublime-workspace" "$project.sublime-workspace"
        fi
      fi
    else
      ln -s "$project/$branch.sublime-workspace" "$project.sublime-workspace"
    fi
    cd -

    workspace="$project_home/$project/$branch.sublime-workspace"
    if [ -f "$workspace" ];then
      subl -a "$workspace"
    else
      puts "Invalid workspace! $workspace"
    fi
  fi
}


_git_scheckout() {
  _git_checkout
}
