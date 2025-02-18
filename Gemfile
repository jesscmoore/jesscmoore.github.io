source "https://rubygems.org"

# Source ruby version from .ruby-version file
ruby File.read(".ruby-version").strip


gem "jekyll", "~> 4.3.4"
# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.5.2"
# Jekyll sass converter to handle deprecated sass in minima theme
gem "jekyll-sass-converter"
# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins
# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# Table of contents
gem 'jekyll-toc'

# Logger
# Added to avoid "warning: logger was loaded from the standard library" in ruby
gem 'logger'

# csv
# Added to avoid "warning: csv was loaded from the standard library"
gem 'csv'

# base64
# Added to avoid "warning: base64 was loaded from the standard library"
gem 'base64'
