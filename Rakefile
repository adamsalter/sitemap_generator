require 'rake/testtask'
require 'find'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test ActiveScaffold.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

