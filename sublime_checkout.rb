#!/usr/bin/ruby

# frozen_string_literal: true

require 'English'

module SublimeCheckout
  @project ||= File.basename(Dir.pwd)
end

class Workspace
  HOME = "#{ENV['HOME']}/.config/sublime-text-3/Packages/User/Projects"
  attr_accessor :branch
  def initialize(project, path, branch)
    @project = project
    @path = path
    @branch = branch
  end

  def checkout(branch)
    GitCmd.checkout(branch) || GitCmd.checkout_new(branch)
  end
end

module GitCmd
  def self.checkout(branch)
    cmd("git checkout #{branch}")
  end

  def self.checkout_new(branch)
    cmd("git checkout -b #{branch}")
  end

  def self.cmd(command)
    `#{command}`
    return false if $CHILD_STATUS.nil?

    $CHILD_STATUS.to_i.zero? ? true : false
  end
end
