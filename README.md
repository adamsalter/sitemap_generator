SitemapGenerator
================

This plugin enables Google Sitemaps to be easily generated for a Rails site as a rake task, using a simple 'Rails Routes'-like DSL. (and it _actually_ works)

> I say "it actually works" because in the process of creating this plugin I tried about 6 different plugins, none of which (IMHO) worked in a natural 'railsy' way. Your mileage may differ of course.

Raison d'être
-------

I was dissatisfied with any of the current Rails sitemap plugins that I found. So I decided I would write my own. ;) Most of the plugins out there seem to try to recreate the sitemap links by iterating the Rails routes. In some cases this is possible, but for a great deal of cases it isn't. 

a) There are probably quite a few routes in your routes file that don't need inclusion in the sitemap. (AJAX routes I'm looking at you.)

and

b) How would you infer the correct series of links for the following route?

    map.connect 'location/:state/:city/:zipcode', :controller => 'zipcode', :action => 'index'
    
Don't tell me it's trivial because it isn't. It just looks trivial.

So my solution is to have another file similar to 'routes.rb' called 'sitemap.rb', where you can define what goes into the sitemap.

Here's my solution:

    Zipcode.find(:all, :include => :city).each do |z|
      sitemap.add zipcode_path(:state => z.city.state, :city => z.city, :zipcode => z)
    end

Easy hey?

Other Sitemap settings for the link, like `lastmod`, `priority` and `changefreq` are entered automatically, although you can override them if you need to.

Other "difficult" examples, solved by my plugin:

- gzip of Sitemap files
- variable priority of links
- paging/sorting links (e.g. my_list?page=3)
- SSL host links (e.g. https:)
- hidden ajax routes
- etc.

Installation
=======

1. Install plugin as normal

    <code>./script/plugin install git://github.com/adamsalter/sitemap_generator-plugin.git</code>

2. Installation should create a 'config/sitemap.rb' file which will contain your logic for generation of the Sitemap files. (If you want to recreate this file manually run `rake sitemap:install`)

3. Run `rake sitemap:refresh` as needed to create sitemap files. This will also ping all the major search engines.

    SiteMaps with many urls (100,000+) take quite a long time to generate and are therefore generally not required to be dynamic, so if you need to refresh your Sitemaps regularly you can set the rake task up as a cron job.

4. Finally, and optionally, add the following to your robots.txt file. The &lt;sitemap_index_location> should be the complete URL to the Sitemap index, such as: http://www.example.org/sitemap_index.xml.gz

    <code>Sitemap: &lt;sitemap_index_location></code>

Example 'config/sitemap.rb'
==========

    # Set the host name for URL creation
    
    SitemapPlugin::Sitemap.default_host = "http://www.example.com"

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
    
    SitemapPlugin::Sitemap.add_links do |sitemap|
    
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
- currently only supports one sitemap index file, which can contain 50,000 sitemap files which can each contain 50,000 urls, so plugin only supports up to 2,500,000,000 urls. I personally have no need of support for more urls, but plugin could be improved to support this.

Copyright (c) 2009 Adam @ [Codebright.net][cb], released under the MIT license

[cb]:http://codebright.net