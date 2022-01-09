require 'bundler/setup'
Bundler.require
# Setting load_schema: false results in "uninitialized constant ActiveRecord::MigrationContext" error
Combustion.initialize! :active_record, :action_view, database_reset: false
Combustion::Application.load_tasks
require 'sitemap_generator/tasks' # Combusition fails to load these tasks
SitemapGenerator.verbose = false

require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.include(FileMacros)
  config.include(XmlMacros)
  config.include(SitemapMacros)

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.after(:all) do
    clean_sitemap_files_from_rails_app
    copy_sitemap_file_to_rails_app(:create)
  end
end

module Helpers
  extend self

  # Invoke and then re-enable the task so it can be called multiple times.
  # KJV: Tasks are only being run once despite being re-enabled.
  #
  # <tt>task</tt> task symbol/string
  def invoke_task(task)
    Rake.send(:verbose, false)
    Rake::Task[task.to_s].invoke
    Rake::Task[task.to_s].reenable
  end
end
