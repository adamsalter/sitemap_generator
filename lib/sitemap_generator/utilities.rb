module SitemapGenerator
  module Utilities
    extend self

    # Copy templates/sitemap.rb to config if not there yet.
    def install_sitemap_rb(verbose=false)
      if File.exist?(SitemapGenerator.app.root + 'config/sitemap.rb')
        puts "already exists: config/sitemap.rb, file not copied" if verbose
      else
        FileUtils.cp(
          SitemapGenerator.templates.template_path(:sitemap_sample),
          SitemapGenerator.app.root + 'config/sitemap.rb')
        puts "created: config/sitemap.rb" if verbose
      end
    end

    # Remove config/sitemap.rb if exists.
    def uninstall_sitemap_rb
      if File.exist?(SitemapGenerator.app.root + 'config/sitemap.rb')
        File.rm(SitemapGenerator.app.root + 'config/sitemap.rb')
      end
    end

    # Clean sitemap files in output directory.
    def clean_files
      FileUtils.rm(Dir[SitemapGenerator.app.root + 'public/sitemap*.xml.gz'])
    end

    # Validate all keys in a hash match *valid keys, raising ArgumentError on a
    # mismatch. Note that keys are NOT treated indifferently, meaning if you use
    # strings for keys but assert symbols as keys, this will fail.
    def assert_valid_keys(hash, *valid_keys)
      unknown_keys = hash.keys - [valid_keys].flatten
      raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
    end
  end
end