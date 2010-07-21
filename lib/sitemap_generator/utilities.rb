module SitemapGenerator
  module Utilities
    extend self

    # Copy templates/sitemap.rb to config if not there yet.
    def install_sitemap_rb(verbose=false)
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "already exists: config/sitemap.rb, file not copied" if verbose
      else
        FileUtils.cp(
          SitemapGenerator.templates.template_path(:sitemap_sample),
          File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "created: config/sitemap.rb" if verbose
      end
    end

    # Remove config/sitemap.rb if exists.
    def uninstall_sitemap_rb
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        File.rm(File.join(RAILS_ROOT, 'config/sitemap.rb'))
      end
    end

    # Clean sitemap files in output directory.
    def clean_files
      FileUtils.rm(Dir[File.join(RAILS_ROOT, 'public/sitemap*.xml.gz')])
    end

    # Returns a boolean indicating whether this environment is Rails 3
    #
    # @return [Boolean]
    def self.rails3?
      Rails.version.to_f >= 3
    end
  end
end