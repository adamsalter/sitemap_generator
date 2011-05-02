require 'zlib'
begin
  require 'aws/s3'
  include AWS::S3
rescue LoadError
  raise RequiredLibraryNotFoundError.new('AWS::S3 could not be loaded')
end


namespace :sitemap do

  desc "Install a default config/sitemap.rb file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "../rails/install.rb"))
  end

  desc "Delete all Sitemap files in public/ and tmp/ directories"
  task :clean do
    sitemap_files = Dir[File.join(RAILS_ROOT, "/public/sitemap*.xml.gz")]
    FileUtils.rm sitemap_files
    sitemap_files = Dir[File.join(RAILS_ROOT, "/tmp/sitemap*.xml.gz")]
    FileUtils.rm sitemap_files
  end

  desc "Create Sitemap XML files in public/ directory"
  desc "Create Sitemap XML files in public/ directory (rake -s for no output)"
  task :refresh => ['sitemap:create'] do
    ping_search_engines("sitemap_index.xml.gz")
  end

  desc "Create Sitemap XML files (don't ping search engines)"
    task 'refresh:no_ping' => ['sitemap:create'] do
  end

  task :create => [:environment] do
    include SitemapGenerator::Helper
    include ActionView::Helpers::NumberHelper

    start_time = Time.now

    # update links from config/sitemap.rb
    load_sitemap_rb

    raise(ArgumentError, "Default hostname not defined") if SitemapGenerator::Sitemap.default_host.blank?

    links_grps = SitemapGenerator::Sitemap.links.in_groups_of(50000, false)
    raise(ArgumentError, "TOO MANY LINKS!! I really thought 2,500,000,000 links would be enough for anybody!") if links_grps.length > 50000

    Rake::Task['sitemap:clean'].invoke

    s3_enabled = (!SitemapGenerator::Sitemap.s3_access_key_id.blank? && !SitemapGenerator::Sitemap.s3_secret_access_key.blank? && !SitemapGenerator::Sitemap.s3_bucket_name.blank?)
    local_storage = (s3_enabled ? 'tmp' : 'public')
    if s3_enabled
      AWS::S3::Base.establish_connection!(
        :access_key_id => SitemapGenerator::Sitemap.s3_access_key_id, 
        :secret_access_key => SitemapGenerator::Sitemap.s3_secret_access_key
      )
    end

    # render individual sitemaps
    sitemap_files = []
    links_grps.each_with_index do |links, index|
      buffer = ''
      xml = Builder::XmlMarkup.new(:target=>buffer)
      eval(open(SitemapGenerator.templates[:sitemap_xml]).read, binding)
      filename = File.join(RAILS_ROOT, "#{local_storage}/sitemap#{index+1}.xml.gz")
      Zlib::GzipWriter.open(filename) do |gz|
        gz.write buffer
      end
      puts "+ #{filename}" if verbose
      puts "** Sitemap too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose
      sitemap_files << filename
      if s3_enabled
        AWS::S3::S3Object.store(File.basename(filename), open(filename), SitemapGenerator::Sitemap.s3_bucket_name, :access => :public_read)
        puts " [uploaded to S3:#{SitemapGenerator::Sitemap.s3_bucket_name}]" if verbose
      end
    end

    # render index
    buffer = ''
    xml = Builder::XmlMarkup.new(:target=>buffer)
    eval(open(SitemapGenerator.templates[:sitemap_index]).read, binding)
    filename = File.join(RAILS_ROOT, "#{local_storage}/sitemap_index.xml.gz")
    Zlib::GzipWriter.open(filename) do |gz|
      gz.write buffer
    end
    puts "+ #{filename}" if verbose
    puts "** Sitemap Index too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose

    if s3_enabled
      AWS::S3::S3Object.store(File.basename(filename), open(filename), SitemapGenerator::Sitemap.s3_bucket_name, :access => :public_read)
      puts " [uploaded to S3:#{SitemapGenerator::Sitemap.s3_bucket_name}]" if verbose
    end

    stop_time = Time.now
    puts "Sitemap stats: #{number_with_delimiter(SitemapGenerator::Sitemap.links.length)} links, " + ("%dm%02ds" % (stop_time - start_time).divmod(60)) if verbose
  end
  
end
