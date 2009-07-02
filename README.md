SitemapGenerator
================

This plugin enables Google Sitemaps to be easily generated for a Rails site as a rake task, using a simple 'Rails Routes'-like DSL. (and it _actually_ works the way you would expect)

> I say "it works the way you would expect" because in the process of creating this plugin I tried about 6 different plugins, none of which (IMHO) worked in a natural 'railsy' way. Your mileage may differ of course.

Raison d'être
-------

Most of the plugins out there seem to try to recreate the Sitemap links by iterating the Rails routes. In some cases this is possible, but for a great deal of cases it isn't. 

a) There are probably quite a few routes in your routes file that don't need inclusion in the Sitemap. (AJAX routes I'm looking at you.)

and

b) How would you infer the correct series of links for the following route?

    map.connect 'location/:state/:city/:zipcode', :controller => 'zipcode', :action => 'index'
    
Don't tell me it's trivial because it isn't. It just looks trivial.

So my solution is to have another file similar to 'routes.rb' called 'sitemap.rb', where you can define what goes into the Sitemap.

Here's my solution:

    Zipcode.find(:all, :include => :city).each do |z|
      sitemap.add zipcode_path(:state => z.city.state, :city => z.city, :zipcode => z)
    end

Easy hey?

Other Sitemap settings for the link, like `lastmod`, `priority`, `changefreq` and `host` are entered automatically, although you can override them if you need to.

Other "difficult" Sitemap issues, solved by this plugin:

- gzip of Sitemap files
- variable priority of links
- paging/sorting links (e.g. my_list?page=3)
- SSL host links (e.g. https:)
- Rails apps which are installed on a sub-path (e.g. example.com/blog_app/)
- hidden ajax routes
- etc.

Installation
=======

1. Install plugin as normal

    <code>./script/plugin install git://github.com/adamsalter/sitemap_generator-plugin.git</code>

2. Installation should create a 'config/sitemap.rb' file which will contain your logic for generation of the Sitemap files. (If you want to recreate this file manually run `rake sitemap:install`)

3. Run `rake sitemap:refresh` as needed to create Sitemap files. This will also ping all the major search engines.

    Sitemaps with many urls (100,000+) take quite a long time to generate, so if you need to refresh your Sitemaps regularly you can set the rake task up as a cron job.

4. Finally, and optionally, add the following to your robots.txt file.

    <code>Sitemap: &lt;hostname>/sitemap_index.xml.gz</code>
    
    The robots.txt Sitemap URL should be the complete URL to the Sitemap index, such as: `http://www.example.org/sitemap_index.xml.gz`

Example 'config/sitemap.rb'
==========

    # Set the host name for URL creation
    SitemapPlugin::Sitemap.default_host = "http://www.example.com"

    SitemapPlugin::Sitemap.add_links do |sitemap|
      # Put links creation logic here.
      #
      # The root path '/' and sitemap index file are added automatically.
      # Links are added to the Sitemap in the order they are specified.
      #
      # Usage: sitemap.add path, options
      #        (default options are used if you don't specify)
      #
      # Defaults: :priority => 0.5, :changefreq => 'weekly', 
      #           :lastmod => Time.now, :host => default_host

  
      # Examples:
  
      # add '/articles'
      sitemap.add articles_path, :priority => 0.7, :changefreq => 'daily'

      # add all individual articles
      Article.find(:all).each do |a|
        sitemap.add article_path(a), :lastmod => a.updated_at
      end

      # add merchant path
      sitemap.add '/purchase', :priority => 0.7, :host => "https://www.example.com"
  
    end

Notes
=======

- only tested/working on Rails 2.3.2, no guarantees made for any other versions of Rails.

Known Bugs
========

- Sitemaps.org [states][sitemaps_org] that no Sitemap XML file should be more than 10Mb uncompressed. The plugin does not check this.
- currently only supports one Sitemap index file, which can contain 50,000 Sitemap files which can each contain 50,000 urls, so it _only_ supports up to 2,500,000,000 (2.5 billion) urls. I personally have no need of support for more urls, but plugin could be improved to support this.

Copyright (c) 2009 Adam @ [Codebright.net][cb], released under the MIT license

[cb]:http://codebright.net
[sitemaps_org]:http://www.sitemaps.org/protocol.php