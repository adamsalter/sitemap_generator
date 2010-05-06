module SitemapGenerator
  class Link
    class << self
      def generate(path, options = {})
        options.assert_valid_keys(:priority, :changefreq, :lastmod, :host, :images)
        options.reverse_merge!(:priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => Sitemap.default_host, :images => [])
        {
          :path => path,
          :priority => options[:priority],
          :changefreq => options[:changefreq],
          :lastmod => options[:lastmod],
          :host => options[:host],
          :loc => URI.join(options[:host], path).to_s,
          :images => prepare_images(options[:images], options[:host])
        }
      end

      # Maximum 1000 images.  <tt>loc</tt> is required.
      # ?? Does the image URL have to be on the same host?
      def prepare_images(images, host)
        images.delete_if { |key,value| key[:loc] == nil }
        images.each do |r|
          r.assert_valid_keys(:loc, :caption, :geo_location, :title, :license)
          r[:loc] = URI.join(host, r[:loc]).to_s
        end
        images[0..(SitemapGenerator::MAX_IMAGES-1)]
      end
    end
  end
end

