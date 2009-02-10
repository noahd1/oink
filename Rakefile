require 'rubygems'
require "rake/gempackagetask"
require "rake/clean"
require './lib/oink.rb'

spec = Gem::Specification.new do |s|
  s.name         = "oink"
  s.version      = Oink::VERSION
  s.author       = "Noah Davis"
  s.email        = "noahd1" + "@" + "yahoo.com"
  s.homepage     = "http://github.com/noahd1/oink"
  s.summary      = "Parse through logs to identify ruby on rails actions which increase memory usage"
  s.description  = s.summary
  s.executables  = "oink"
  s.files        = %w[History.txt MIT-LICENSE.txt README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"]
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Show information about the gem.'
task :write_gemspec do
  File.open("oink.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
  puts "Generated: oink.gemspec"
end

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end
