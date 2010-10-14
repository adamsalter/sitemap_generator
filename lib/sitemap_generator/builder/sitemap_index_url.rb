require 'builder'

module SitemapGenerator
  module Builder
    class SitemapIndexUrl < SitemapUrl

      def initialize(path, options={})
        if path.is_a?(SitemapGenerator::Builder::SitemapIndexFile)
          options.reverse_merge!(:host => path.hostname, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
          path = path.sitemap_path
          super(path, options)
        else
          super
        end
      end

      # Return the URL as XML
      def to_xml(builder=nil)
        builder = ::Builder::XmlMarkup.new if builder.nil?
        builder.sitemap do
          builder.loc        self[:loc]
          builder.lastmod    w3c_date(self[:lastmod])   if self[:lastmod]
        end
        builder << '' # force to string
      end
    end
  end
end