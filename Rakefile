require 'rubygems'
require "rake/gempackagetask"
require "rake/clean"
require "spec/rake/spectask"
require './lib/oink/base.rb'

spec = Gem::Specification.new do |s|
  s.name         = "oink"
  s.version      = Oink::Base::VERSION
  s.author       = "Noah Davis"
  s.email        = "noahd1" + "@" + "yahoo.com"
  s.homepage     = "http://github.com/noahd1/oink"
  s.summary      = "Log parser to identify actions which significantly increase VM heap size"
  s.description  = s.summary
  s.executables  = "oink"
  s.files        = %w[History.txt MIT-LICENSE README.rdoc Rakefile] + Dir["bin/*"] + Dir["lib/**/*"]
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts == ["--color"]
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run the specs"
task :default => ["spec"]

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
