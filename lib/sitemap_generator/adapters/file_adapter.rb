module SitemapGenerator
  class FileAdapter
    def write(location, raw_data)
      # Ensure that the directory exists
      dir = location.directory
      if !File.exists?(dir)
        FileUtils.mkdir_p(dir)
      elsif !File.directory?(dir)
        raise SitemapError.new("#{dir} should be a directory!")
      end

      gzip(open(location.path, 'wb'), raw_data)
    end

    def gzip(stream, data)
      gz = Zlib::GzipWriter.new(stream)
      gz.write data
      gz.close
    end
  end
end
