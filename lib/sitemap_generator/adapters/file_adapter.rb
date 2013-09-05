module SitemapGenerator
  class FileAdapter
    def write(location, raw_data, gzip_file = false)
      # Ensure that the directory exists
      dir = location.directory
      if !File.exists?(dir)
        FileUtils.mkdir_p(dir)
      elsif !File.directory?(dir)
        raise SitemapError.new("#{dir} should be a directory!")
      end

      stream = open(location.path, 'wb')
      if gzip_file
        gzip(stream, raw_data)
      else
        stream.write raw_data
        stream.close
      end
    end

    def gzip(stream, data)
      gz = Zlib::GzipWriter.new(stream)
      gz.write data
      gz.close
    end
  end
end
