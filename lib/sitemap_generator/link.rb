module SitemapGenerator
  class Link
    class << self
      def generate(path, options = {})
        options.assert_valid_keys(:priority, :changefreq, :lastmod, :host, :images)
        prepare_images options[:images]
        options.reverse_merge!(:priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => Sitemap.default_host)
        {
          :path => path,
          :priority => options[:priority],
          :changefreq => options[:changefreq],
          :lastmod => options[:lastmod],
          :host => options[:host],
          :loc => URI.join(options[:host], path).to_s,
          :images => options[:images]
        }
      end

      def prepare_images(images)
        unless images.blank?
          images.delete_if{|key,value| key[:loc]==nil}
          images.each do |r|
            r.assert_valid_keys(:loc, :caption, :geo_location, :title, :license)
            r[:loc] = URI.join(Sitemap.default_host, r[:loc]).to_s
          end
        end
        images = images[0..1000] rescue []
      end

    end
  end
end

