require 'pathname'

module SitemapGenerator
  class Application
    def rails?
      defined?(Rails)
    end

    # Returns a boolean indicating whether this environment is Rails 3
    #
    # @return [Boolean]    
    def rails3?
      rails? && Rails.version.to_f >= 3
    rescue
      false # Rails.version defined in 2.1.0
    end
   
    def root
      Pathname.new(rails? && Rails.root || Dir.getwd)
    end
  end
end