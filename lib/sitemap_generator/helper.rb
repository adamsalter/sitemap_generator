require 'action_controller'
require 'action_controller/test_process'

module SitemapGenerator
  module Helper
    def load_sitemap_rb
      controller = ApplicationController.new
      controller.request = ActionController::TestRequest.new
      controller.params = {}
      controller.send(:initialize_current_url)  
      b = controller.send(:binding)
      sitemap_mapper_file = File.join(RAILS_ROOT, 'config/sitemap.rb')
      eval(open(sitemap_mapper_file).read, b)
    end
    
    def url_with_hostname(path)
      URI.join(Sitemap.default_host, path).to_s
    end
    
    def w3c_date(date)
       date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    end
    
    def ping_search_engines(sitemap_index)
      index_location = CGI.escape(url_with_hostname(sitemap_index))
      # engines list from http://en.wikipedia.org/wiki/Sitemap_index
      {:google => "http://www.google.com/webmasters/sitemaps/ping?sitemap=#{index_location}",
        :yahoo => "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=#{index_location}",
        :ask => "http://submissions.ask.com/ping?sitemap=#{index_location}",
        :msn => "http://webmaster.live.com/ping.aspx?siteMap=#{index_location}",
        :sitemap_writer => "http://www.sitemapwriter.com/notify.php?crawler=all&url=#{index_location}"}.each do |engine, link|
        begin
          open(link)
          puts "Successful ping of #{engine.to_s.titleize}"
        rescue StandardError => e
          puts "Ping failed for #{engine.to_s.titleize}: #{e.inspect}"
        end
      end
    end
  end
end