# Install hook code here

# Copy sitemap_template.rb to config/sitemap.rb
require 'fileutils'
current_dir = File.dirname(__FILE__)
sitemap_template = File.join(current_dir, 'templates/sitemap.rb')
new_sitemap = File.join(RAILS_ROOT, 'config/sitemap.rb')
if File.exist?(new_sitemap)
  puts "already exists: config/sitemap.rb, file not copied"
else
  puts "created: config/sitemap.rb"
  FileUtils.cp(sitemap_template, new_sitemap)
end