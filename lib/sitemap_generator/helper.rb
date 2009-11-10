require 'action_controller'
require 'action_controller/test_process'
begin
  require 'application_controller'
rescue LoadError
  # Rails < 2.3
  require 'application'
end

module SitemapGenerator
  module Helper
    def load_sitemap_rb
      controller = ApplicationController.new
      controller.request = ActionController::TestRequest.new
      controller.params = {}
      controller.send(:initialize_current_url)  
      b = controller.instance_eval{binding}
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
      require 'open-uri'
      index_location = CGI.escape(url_with_hostname(sitemap_index))
      # engines list from http://en.wikipedia.org/wiki/Sitemap_index
      yahoo_app_id = SitemapGenerator::Sitemap.yahoo_app_id
      {:google => "http://www.google.com/webmasters/sitemaps/ping?sitemap=#{index_location}",
        :yahoo => "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=#{index_location}&appid=#{yahoo_app_id}",
        :ask => "http://submissions.ask.com/ping?sitemap=#{index_location}",
        :bing => "http://www.bing.com/webmaster/ping.aspx?siteMap=#{index_location}",
        :sitemap_writer => "http://www.sitemapwriter.com/notify.php?crawler=all&url=#{index_location}"}.each do |engine, link|
        begin
          unless SitemapGenerator::Sitemap.yahoo_app_id == false
            open(link)
            puts "Successful ping of #{engine.to_s.titleize}" if verbose
          end
        rescue Timeout::Error, StandardError => e
          puts "Ping failed for #{engine.to_s.titleize}: #{e.inspect}" if verbose
          puts <<-END if engine == :yahoo && verbose
Yahoo requires an 'AppID' for more than one ping per "timeframe", you can either:
  - remove yahoo from the ping list (config/sitemap.rb):
    SitemapGenerator::Sitemap.yahoo_app_id = false
  - or add your Yahoo AppID to the generator (config/sitemap.rb):
    SitemapGenerator::Sitemap.yahoo_app_id = "my_app_id"
For more information: http://developer.yahoo.com/search/siteexplorer/V1/updateNotification.html
          END
        end
      end
    end
  end
end
