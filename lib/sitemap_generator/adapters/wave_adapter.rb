require 'carrierwave'

module SitemapGenerator
  class WaveAdapter < ::CarrierWave::Uploader::Base
    attr_accessor :store_dir
    
    def write(location, raw_data)
      SitemapGenerator::FileAdapter.new.write(location, raw_data)
      self.store_dir = File.dirname(location.path_in_public)
      store!(open(location.path, 'rb'))
    end
  end
end
