---
layout: post
title:  "How to setup a static website on Github Pages with Jekyll"
date:   2021-03-02 13:23:03 +1100
categories: jekyll update
---
Jekyll is a static site generator for making websites. Here are the steps I took to create a website with Jekyll on github pages on Mac Mojave 10.14.6. Thanks to Amanda Visconti's lesson [Building a static stie with Jekyll and Github Pages](https://programminghistorian.org/en/lessons/building-static-sites-with-jekyll-github-pages) and the documentation at [Jekyll](https://jekyllrb.com/docs/installation/macos/)

Whilst dynamic websites are great for complex web sites where a database is needed for content management system (eg Drupal or Wordpress), in many cases a static website is sufficient and are less complex to manage. The Jekyll static site generator provides a simple solution.

## Installation

Jekyll dependencies:

- Ruby and Ruby Gems
- NodeJS

We also install the rbenv ruby environment manager

For website hosting we use Github Pages, however this could also be our own domain.


### Ruby and Ruby Gems

We install both Ruby and Ruby Gems. Gems is the package manager for Ruby.

`brew install ruby`

Ruby is on Mac by default, however to use the brew version we add this new ruby binary to our `$PATH` and source the new path.

`echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile`

`source ~/.bash_profile`

Check it is pointing to our new ruby setup

`which ruby`

`ruby -v`

This is the current stable version of Ruby.

The Ruby build installs a non-Homebrew OpenSSL for each Ruby version installed and these are never upgraded. To link Rubies to Homebrew's OpenSSL 1.1 (which is upgraded) we set the ruby openssl option

`echo 'export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"' >> ~/.bash_profile`

Now update ruby gems with

`gem install rubygems-update`

This gives an install warning that `~/.gem/ruby/3.0.0/bin` is needed in our PATH, to allow gem executables to run.

`echo 'export PATH="/Users/u9904893/.gem/ruby/3.0.0/bin:$PATH"' >> ~/.bash_profile`


Check that jekyll points to our home directory with

`gem env`



### rbenv 

We also install `rbenv` to manage environments with different ruby versions.

`brew install rbenv`

And set up rbenv integration with our shell

`rbenv init`

We can check our rbenv installation with

`curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash`

Setup rbenv to load rbenv automatically 

`echo 'eval "$(rbenv init -)"' >> ~/.bash_profile`


### NodeJS

`brew install node`


### Jekyll

Install the bundler and jekyll gems

`gem install jekyll bundler`

If this doesn't work, do `gem install --user-install bundler jekyll`


On github, create a repo with name [github_name].github.io.  cd into the repo.

```
jekyll new . --force.
```

## Configuration

Next, we must set the baseurl, by

Open `_config.yml` file in a text editor. I use BBEdit. Change the baseurl line to be

```
baseurl: ""
```

It is good practice, we need to also set the url. Change the url line to

```
url: "[github_name].github.io"
```

Perform an initial site build with:

```
bundle exec jekyll build
```


## Publish to [github_name].github.io

In your repo settings, set to public. Then in the Pages settings, set the publication branch to `main`

On push to that branch it will publish your site.

[https://jesscmoore.github.io/](https://jesscmoore.github.io/)



# Personalise your site

In text editor, open `_config.yml` file_, and change the website title, description, and contact details

```
title: [YOUR PREFERRED WEBSITE TITLE]
email: [EMAIL]
description: >- # this means to ignore newlines until "baseurl:"
  Data analyst, hiker, lover of the outdoors, and once was an astronomer.
twitter_username: [TWITTER_USERNAME]
github_username:  [GITHUB_USERNAME]
```



## Local hosting

Or if localhosting only, after updating page text, serve the webpage by typing

```
bundle exec jekyll serve --trace --livereload
```

# Useful references

- YML syntax [https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml](https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml)
- More YML syntax [https://learnxinyminutes.com/docs/yaml/](https://learnxinyminutes.com/docs/yaml/)
- Sangsoo Nam's article [Writing Upcoming Posts in GitHub Pages](http://sangsoonam.github.io/2018/12/27/writing-upcoming-posts-in-github-pages.html)
- Sangsoo Nam's article [Syntax Highlighting in Jekyll](http://sangsoonam.github.io/2019/01/20/syntax-highlighting-in-jekyll.html)
