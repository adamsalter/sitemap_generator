SitemapGenerator
================

SitemapGenerator generates Sitemaps for your Rails application.  The Sitemaps adhere to the [Sitemap 0.9 protocol][sitemap_protocol] specification.  You specify the contents of your Sitemap using a configuration file, à la Rails Routes.  A set of rake tasks is included to help you manage your Sitemaps.

Features
-------

- Supports [Video sitemaps][sitemap_video] and [Image sitemaps][sitemap_images]
- Rails3 compatible (beta)
- Adheres to the [Sitemap 0.9 protocol][sitemap_protocol]
- Handles millions of links
- Compresses Sitemaps using GZip
- Notifies Search Engines (Google, Yahoo, Bing, Ask, SitemapWriter) of new sitemaps
- Ensures your old Sitemaps stay in place if the new Sitemap fails to generate
- You set the hostname (and protocol) of the links in your Sitemap

Changelog
-------

- v1.1.0: [Video sitemap][sitemap_video] support
- v0.2.6: [Image Sitemap][sitemap_images] support
- v0.2.5: Rails 3 support (beta)

Foreword
-------

Adam Salter first created SitemapGenerator while we were working together in Sydney, Australia.  Unfortunately, he passed away in 2009.  Since then I have taken over development of SitemapGenerator.

Those who knew him know what an amazing guy he was, and what an excellent Rails programmer he was.  His passing is a great loss to the Rails community.

The canonical repository is now: [http://github.com/kjvarga/sitemap_generator][canonical_repo]

Install
=======

**Rails 3:**

1. Add the gem to your <tt>Gemspec</tt>

    <code>gem 'sitemap_generator'</code>

2. `$ rake sitemap:install`

**Rails 2.x: As a gem**

1. Add the gem as a dependency in your <tt>config/environment.rb</tt>

    <code>config.gem 'sitemap_generator', :lib => false</code>

2. `$ rake gems:install`

3. Add the following to your <tt>RAILS_ROOT/Rakefile</tt>

    <pre>begin
      require 'sitemap_generator/tasks'
    rescue Exception => e
      puts "Warning, couldn't load gem tasks: #{e.message}! Skipping..."
    end</pre>

4. `$ rake sitemap:install`

**Rails 2.x: As a plugin**

1. <code>$ ./script/plugin install git://github.com/kjvarga/sitemap_generator.git</code>

Usage
======

<code>rake sitemap:install</code> creates a <tt>config/sitemap.rb</tt> file which will contain your logic for generating the Sitemap files.

Once you have configured your sitemap in <tt>config/sitemap.rb</tt> run <code>rake sitemap:refresh</code> as needed to create/rebuild your Sitemap files.  Sitemaps are generated into the <tt>public/</tt> folder and are named <tt>sitemap_index.xml.gz</tt>, <tt>sitemap1.xml.gz</tt>, <tt>sitemap2.xml.gz</tt>, etc.

Using <code>rake sitemap:refresh</code> will notify major search engines to let them know that a new Sitemap is available (Google, Yahoo, Bing, Ask, SitemapWriter).  To generate new Sitemaps without notifying search engines (for example when running in a local environment) use <code>rake sitemap:refresh:no_ping</code>.

To ping Yahoo you will need to set your Yahoo AppID in <tt>config/sitemap.rb</tt>.  For example: <code>SitemapGenerator::Sitemap.yahoo_app_id = "my_app_id"</code>

To disable all non-essential output (only errors will be displayed) run the rake tasks with the <code>-s</code> option.  For example <code>rake -s sitemap:refresh</code>.

Cron
-----

To keep your Sitemaps up-to-date, setup a cron job.  Make sure to pass the <code>-s</code> option to silence rake.  That way you will only get email when the sitemap build fails.

If you're using Whenever, your schedule would look something like the following:

    # config/schedule.rb
    every 1.day, :at => '5:00 am' do
      rake "-s sitemap:refresh"
    end

Robots.txt
----------

You should add the Sitemap index file to <code>public/robots.txt</code> to help search engines find your Sitemaps.  The URL should be the complete URL to the Sitemap index file.  For example:

    Sitemap: http://www.example.org/sitemap_index.xml.gz

Image and Video Sitemaps
-----------

Images can be added to a sitemap URL by passing an <tt>:images</tt> array to <tt>add()</tt>.  Each item in the array must be a Hash containing tags defined by the [Image Sitemap][image_tags] specification.  For example:

    sitemap.add('/index.html', :images => [{ :loc => 'http://www.example.com/image.png', :title => 'Image' }])

A video can be added to a sitemap URL by passing a <tt>:video</tt> Hash to <tt>add()</tt>.  The Hash can contain tags defined by the [Video Sitemap specification][video_tags].  To associate more than one <tt>tag</tt> with a video, pass the tags as an array with the key <tt>:tags</tt>.

    sitemap.add('/index.html', :video => { :thumbnail_loc => 'http://www.example.com/video1_thumbnail.png', :title => 'Title', :description => 'Description', :content_loc => 'http://www.example.com/cool_video.mpg', :tags => %w[one two three], :category => 'Category' })

Example <code>config/sitemap.rb</code>
---------

    # Set the host name for URL creation
    SitemapGenerator::Sitemap.default_host = "http://www.example.com"
    SitemapGenerator::Sitemap.yahoo_app_id = nil # Set to your Yahoo AppID to ping Yahoo

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

      # add '/articles'
      sitemap.add articles_path, :priority => 0.7, :changefreq => 'daily'

      # add all articles
      Article.all.each do |a|
        sitemap.add article_path(a), :lastmod => a.updated_at
      end

      # add news page with images
      News.all.each do |news|
        images = news.images.collect do |image|
          { :loc => image.url, :title => image.name }
        end
        sitemap.add news_path(news), :images => images
      end
    end

    # Including Sitemaps from Rails Engines.
    #
    # These Sitemaps should be almost identical to a regular Sitemap file except
    # they needn't define their own SitemapGenerator::Sitemap.default_host since
    # they will undoubtedly share the host name of the application they belong to.
    #
    # As an example, say we have a Rails Engine in vendor/plugins/cadability_client
    # We can include its Sitemap here as follows:
    #
    file = File.join(Rails.root, 'vendor/plugins/cadability_client/config/sitemap.rb')
    eval(open(file).read, binding, file)

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

Compatibility
=======

Tested and working on:

- **Rails** 3.0.0
- **Rails** 1.x - 2.3.8
- **Ruby** 1.8.6, 1.8.7, 1.8.7 Enterprise Edition, 1.9.1

Notes
=======

1) For large sitemaps it may be useful to split your generation into batches to avoid running out of memory. E.g.:

    # add movies
    Movie.find_in_batches(:batch_size => 1000) do |movies|
      movies.each do |movie|
        sitemap.add "/movies/show/#{movie.to_param}", :lastmod => movie.updated_at, :changefreq => 'weekly'
      end
    end

2) New Capistrano deploys will remove your Sitemap files, unless you run `rake sitemap:refresh`. The way around this is to create a cap task:

    after "deploy:update_code", "deploy:copy_old_sitemap"

    namespace :deploy do
      task :copy_old_sitemap do
          run "if [ -e #{previous_release}/public/sitemap_index.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
      end
    end

Known Bugs
========

- There's no check on the size of a URL which [isn't supposed to exceed 2,048 bytes][sitemaps_xml].
- Currently only supports one Sitemap Index file, which can contain 50,000 Sitemap files which can each contain 50,000 urls, so it _only_ supports up to 2,500,000,000 (2.5 billion) urls. I personally have no need of support for more urls, but plugin could be improved to support this.

Wishlist & Coming Soon
========

- Ultimately I'd like to make this gem framework agnostic.  It is better suited to being run as a command-line tool as opposed to Ruby-specific Rake tasks.
- Add rake tasks/options to validate the generated sitemaps.
- Support News, Mobile, Geo and other types of sitemaps
- Support for generating sitemaps for sites with multiple domains.  Sitemaps can be generated into subdirectories and we can use Rack middleware to rewrite requests for sitemaps to the correct subdirectory based on the request host.
- Auto coverage testing.  Generate a report of broken URLs by checking the status codes of each page in the sitemap.

Thanks (in no particular order)
========

- [Alex Soto](http://github.com/apsoto) for video sitemaps
- [Alexadre Bini](http://github.com/alexandrebini) for image sitemaps
- [Dan Pickett](http://github.com/dpickett)
- [Rob Biedenharn](http://github.com/rab)
- [Richie Vos](http://github.com/jerryvos)
- [Adrian Mugnolo](http://github.com/xymbol)
- [Jason Weathered](http://github.com/jasoncodes)
- [Andy Stewart](http://github.com/airblade)

Copyright (c) 2009 Karl Varga released under the MIT license

[canonical_repo]:http://github.com/kjvarga/sitemap_generator
[enterprise_class]:https://twitter.com/dhh/status/1631034662 "I use enterprise in the same sense the Phusion guys do - i.e. Enterprise Ruby. Please don't look down on my use of the word 'enterprise' to represent being a cut above. It doesn't mean you ever have to work for a company the size of IBM. Or constantly fight inertia, writing crappy software, adhering to change management practices and spending hours in meetings... Not that there's anything wrong with that - Wait, what?"
[sitemaps_org]:http://www.sitemaps.org/protocol.php "http://www.sitemaps.org/protocol.php"
[sitemaps_xml]:http://www.sitemaps.org/protocol.php#xmlTagDefinitions "XML Tag Definitions"
[sitemap_generator_usage]:http://wiki.github.com/adamsalter/sitemap_generator/sitemapgenerator-usage "http://wiki.github.com/adamsalter/sitemap_generator/sitemapgenerator-usage"
[sitemap_images]:http://www.google.com/support/webmasters/bin/answer.py?answer=178636
[sitemap_video]:http://www.google.com/support/webmasters/bin/topic.py?topic=10079
[sitemap_protocol]:http://sitemaps.org/protocol.php
[video_tags]:http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=80472#4
[image_tags]:http://www.google.com/support/webmasters/bin/answer.py?hl=en&answer=178636