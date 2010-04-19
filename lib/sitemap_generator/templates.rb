module SitemapGenerator
  # Provide convenient access to template files.  E.g.
  #
  #   SitemapGenerator.templates.sitemap_index
  #
  # Lazy-load and cache for efficient access.
  # Define an accessor method for each template file.
  class Templates
    FILES = {
      :sitemap_index  =>  'sitemap_index.builder',
      :sitemap_xml    =>  'xml_sitemap.builder',
      :sitemap_sample =>  'sitemap.rb',
    }
    
    attr_accessor *FILES.keys
    FILES.keys.each do |name|
      eval <<-END
        define_method(:#{name}) do
          @#{name} ||= read_template(:#{name})
        end
      END
    end
    
    def initialize(root = SitemapGenerator.root)
      @root = root
    end
    
    def template_path(file)
      File.join(@root, 'templates', file)
    end
    
    protected
        
    def read_template(template)
      File.read(template_path(self.class::FILES[template]))
    end
  end
end