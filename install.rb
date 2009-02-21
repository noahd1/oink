#!/usr/bin/env ruby

template_executable_file = File.join("application_files", "script", "oink")
executable_file = File.expand_path("#{File.dirname(__FILE__)}/../../../script/oink")

File.copy template_executable_file, executable_file