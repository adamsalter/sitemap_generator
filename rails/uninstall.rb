# Uninstall hook code here

new_sitemap = File.join(RAILS_ROOT, 'config/sitemap.rb')
File.rm(new_sitemap) if File.exist?(new_sitemap)