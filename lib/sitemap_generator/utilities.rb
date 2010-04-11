module SitemapGenerator
  module Utilities

    # Copy templates/sitemap.rb to config if not there yet.
    def install_sitemap_rb
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "already exists: config/sitemap.rb, file not copied"
      else
        FileUtils.cp(
          SitemapGenerator.templates.template_path(:sitemap_sample), 
          File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "created: config/sitemap.rb"
      end
    end

    # Remove config/sitemap.rb if exists.
    def uninstall_sitemap_rb
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        File.rm(File.join(RAILS_ROOT, 'config/sitemap.rb'))
      end
    end      
  end
end