# -*- coding: utf-8 -*-
require 'rubygems'
require 'test/unit'

class TestOfGemconfPlugin < Test::Unit::TestCase
  def setup
    @dirname ||= File.expand_path(File.dirname(__FILE__))
    `rm -rf #{@dirname}/sandbox`
    `cp -r #{@dirname}/fixture #{@dirname}/sandbox`
    Dir.chdir "#{@dirname}/sandbox"
  end
  def test_install_creates_new_files
    load "#{@dirname}/../install.rb"
    assert File.exists?("#{@dirname}/sandbox/config/gemconf.rb")
    assert File.exists?("#{@dirname}/sandbox/script/install_gems")
  end
end

