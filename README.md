SitemapGenerator
================

This plugin enables ['enterprise-class'][enterprise_class] Google Sitemaps to be easily generated for a Rails site as a rake task, using a simple 'Rails Routes'-like DSL.

Raison d'être
-------

Most of the Sitemap plugins out there seem to try to recreate the Sitemap links by iterating the Rails routes. In some cases this is possible, but for a great deal of cases it isn't. 

a) There are probably quite a few routes in your routes file that don't need inclusion in the Sitemap. (AJAX routes I'm looking at you.)

and

b) How would you infer the correct series of links for the following route?

    map.zipcode 'location/:state/:city/:zipcode', :controller => 'zipcode', :action => 'index'
    
Don't tell me it's trivial, because it isn't. It just looks trivial.

So my idea is to have another file similar to 'routes.rb' called 'sitemap.rb', where you can define what goes into the Sitemap.

Here's my solution:

    Zipcode.find(:all, :include => :city).each do |z|
      sitemap.add zipcode_path(:state => z.city.state, :city => z.city, :zipcode => z)
    end

Easy hey?

Other Sitemap settings for the link, like `lastmod`, `priority`, `changefreq` and `host` are entered automatically, although you can override them if you need to.

Other "difficult" Sitemap issues, solved by this plugin:

- Support for more than 50,000 urls (using a Sitemap Index file)
- Gzip of Sitemap files
- Variable priority of links
- Paging/sorting links (e.g. my_list?page=3)
- SSL host links (e.g. https:)
- Rails apps which are installed on a sub-path (e.g. example.com/blog_app/)

Installation
=======

**As a gem**

1. Add the gem as a dependency in your config/environment.rb

    <code>config.gem 'sitemap_generator', :lib => false, :source => 'http://gemcutter.org'</code>

2. `$ rake gems:install`

3. Add the following line to your RAILS_ROOT/Rakefile

    <code>require 'sitemap_generator/tasks' rescue LoadError</code>

4. `$ rake sitemap:install`

**As a plugin**

1. Install plugin as normal

    <code>$ ./script/plugin install git://github.com/adamsalter/sitemap_generator.git</code>

----

Installation should create a 'config/sitemap.rb' file which will contain your logic for generation of the Sitemap files. (If you want to recreate this file manually run `rake sitemap:install`)

You can run `rake sitemap:refresh` as needed to create Sitemap files. This will also ping all the ['major'][sitemap_engines] search engines. (if you want to disable all non-essential output run the rake task thusly `rake -s sitemap:refresh`)

Sitemaps with many urls (100,000+) take quite a long time to generate, so if you need to refresh your Sitemaps regularly you can set the rake task up as a cron job. Most cron agents will only send you an email if there is output from the cron task.

Optionally, you can add the following to your robots.txt file, so that robots can find the sitemap file.

    Sitemap: <hostname>/sitemap_index.xml.gz
    
The robots.txt Sitemap URL should be the complete URL to the Sitemap Index, such as: `http://www.example.org/sitemap_index.xml.gz`


Example 'config/sitemap.rb'
==========

    # Set the host name for URL creation
    SitemapGenerator::Sitemap.default_host = "http://www.example.com"

    SitemapGenerator::Sitemap.add_links do |sitemap|
      # Put links creation logic here.
      #
      # The Root Path ('/') and Sitemap Index file are added automatically.
      # Links are added to the Sitemap output in the order they are specified.
      #
      # Usage: sitemap.add path, options
      #        (default options are used if you don't specify them)
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

1) Tested/working on Rails 1.x.x <=> 2.x.x, no guarantees made for Rails 3.0.

2) For large sitemaps it may be useful to split your generation into batches to avoid running out of memory. E.g.:

    # add movies
    Movie.find_in_batches(:batch_size => 1000) do |movies|
      movies.each do |movie|
        sitemap.add "/movies/show/#{movie.to_param}", :lastmod => movie.updated_at, :changefreq => 'weekly'
      end
    end

3) New Capistrano deploys will remove your Sitemap files, unless you run `rake sitemap:refresh`. The way around this is to create a cap task:

    after "deploy:update_code", "deploy:copy_old_sitemap"

    namespace :deploy do
      task :copy_old_sitemap do
          run "if [ -e #{previous_release}/public/sitemap_index.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
      end
    end

Known Bugs
========

- Sitemaps.org [states][sitemaps_org] that no Sitemap XML file should be more than 10Mb uncompressed. The plugin will warn you about this, but does nothing to avoid it (like move some URLs into a later file).
- There's no check on the size of a URL which [isn't supposed to exceed 2,048 bytes][sitemaps_xml].
- Currently only supports one Sitemap Index file, which can contain 50,000 Sitemap files which can each contain 50,000 urls, so it _only_ supports up to 2,500,000,000 (2.5 billion) urls. I personally have no need of support for more urls, but plugin could be improved to support this.

Thanks (in no particular order)
========

- [Karl Varga (aka Bear Grylls)](http://github.com/kjvarga)
- [Dan Pickett](http://github.com/dpickett)
- [Rob Biedenharn](http://github.com/rab)
- [Richie Vos](http://github.com/jerryvos)


Follow me on:
---------

>  Twitter: [twitter.com/adamsalter](http://twitter.com/adamsalter)  
>  Github: [github.com/adamsalter](http://github.com/adamsalter)

Copyright (c) 2009 Adam @ [Codebright.net][cb], released under the MIT license

[enterprise_class]:https://twitter.com/dhh/status/1631034662 "I use enterprise in the same sense the Phusion guys do - i.e. Enterprise Ruby. Please don't look down on my use of the word 'enterprise' to represent being a cut above. It doesn't mean you ever have to work for a company the size of IBM. Or constantly fight inertia, writing crappy software, adhering to change management practices and spending hours in meetings... Not that there's anything wrong with that - Wait, what?"
[sitemap_engines]:http://en.wikipedia.org/wiki/Sitemap_index "http://en.wikipedia.org/wiki/Sitemap_index"
[sitemaps_org]:http://www.sitemaps.org/protocol.php "http://www.sitemaps.org/protocol.php"
[sitemaps_xml]:http://www.sitemaps.org/protocol.php#xmlTagDefinitions "XML Tag Definitions"
[sitemap_generator_usage]:http://wiki.github.com/adamsalter/sitemap_generator/sitemapgenerator-usage "http://wiki.github.com/adamsalter/sitemap_generator/sitemapgenerator-usage"
[boost_juice]:http://www.boostjuice.com.au/ "Mmmm, sweet, sweet Boost Juice."
[cb]:http://codebright.net "http://codebright.net"
