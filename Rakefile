require "rubygems/package_task"
require "rake/clean"
require "rspec/core/rake_task"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name         = "oink"
    s.version      = "0.10.1"
    s.author       = "Noah Davis"
    s.email        = "noahd1" + "@" + "yahoo.com"
    s.homepage     = "http://github.com/noahd1/oink"
    s.summary      = "Log parser to identify actions which significantly increase VM heap size"
    s.description  = s.summary
    s.executables  = "oink"
    s.files        = %w[History.txt MIT-LICENSE README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts == ["--color"]
end

desc "Run the specs"
task :default => ["spec"]

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]
