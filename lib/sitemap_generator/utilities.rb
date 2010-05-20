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

    # Returns whether this environment is using ActionPack
    # version 3.0.0 or greater.
    #
    # @return [Boolean]
    def self.rails3?
      # The ActionPack module is always loaded automatically in Rails >= 3
      return false unless defined?(ActionPack) && defined?(ActionPack::VERSION)

      version =
        if defined?(ActionPack::VERSION::MAJOR)
          ActionPack::VERSION::MAJOR
        else
          # Rails 1.2
          ActionPack::VERSION::Major
        end

      # 3.0.0.beta1 acts more like ActionPack 2
      # for purposes of this method
      # (checking whether block helpers require = or -).
      # This extra check can be removed when beta2 is out.
      version >= 3 &&
        !(defined?(ActionPack::VERSION::TINY) &&
          ActionPack::VERSION::TINY == "0.beta")
    end
  end
end