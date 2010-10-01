require 'rubygems'
require "rake/gempackagetask"
require "rake/clean"
require "spec/rake/spectask"
require './lib/oink/base.rb'

require 'jeweler'
Jeweler::Tasks.new do |s|
  s.name         = "oink"
  s.version      = Oink::Base::VERSION
  s.author       = "Noah Davis"
  s.email        = "noahd1" + "@" + "yahoo.com"
  s.homepage     = "http://github.com/noahd1/oink"
  s.summary      = "Log parser to identify actions which significantly increase VM heap size"
  s.description  = s.summary
  s.executables  = "oink"
  s.files        = %w[History.txt MIT-LICENSE README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"]
  s.add_dependency 'hodel_3000_compliant_logger'
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts == ["--color"]
end

desc "Run the specs"
task :default => ["spec"]

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]
