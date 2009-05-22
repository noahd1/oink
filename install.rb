#!/usr/bin/env ruby
require 'ftools'

template_executable_file = File.join(File.dirname(__FILE__), "application_files", "script", "oink")
executable_file = File.expand_path("#{File.dirname(__FILE__)}/../../../script/oink")

File.copy template_executable_file, executable_file
File.chmod 0755, executable_file
