module SitemapGenerator
  module LinkSet
    # The object passed to SitemapGenerator::Sitemap.add_links block in 
    # <tt>config/sitemap.rb</tt> is a SetBuilder instance.
    class Builder
      attr_accessor :host, :default_host
      
      # Add links to sitemap files.
      #
      # Pass a block which takes as its argument a LinkSet::Builder instance.
      #
      # Pass optional <tt>host</tt> list of host symbols (or a single symbol)
      # to add the links to sitemap files for those hosts.
      def add_links(host)
        @host = host.is_a?(Array) ? host : [host || default_host].compact!
        raise ArgumentError, "Default hostname not set" if @host.empty?
        
        set = LinkSet.new
        add_default_links if first_link?
        yield Mapper.new(self)
      end      
    end
  end
end