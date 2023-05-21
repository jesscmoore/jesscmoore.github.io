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

`baseurl: "/jekylldemo"`

It is good practice, we need to also set the url. Change the url line to

`url: "localhost:4000"`



# Create repo from project folder

Open the GitHub desktop app. 

Create a repo from jekylldemo project folder 

Click `File` then `New Repository`

The repo name must match the folder name of your jekyll site, and the baseurl set in the _config.yml file, i.e. enter `jekylldemo` as the repo name

`Name`: `jekylldemo`

The Local Path should be set as below

`Local Path`: `~/Documents/GitHub`

This will create the GitHub folder in your Documents directory. This folder is where your repos managed with the GitHub Desktop app are cloned to by default.

For best practice, also tick the box to initialise with a README. Then click `Create Repository`

Then click `Publish` to publish site to GitHub Pages

Here you will also need to fix the yml file to point to the github.io webpage, by setting

`url: "jesscmoore.github.io"`

where the first part of the url is your github username.



# Configure GitHub Page source

Go to the online github repo

Click `Settings` and scroll down to `GitHub Pages` section of the page. Ensure that the GitHub Pages source is set to the main branch. This way pull merges into the main branch will be published to GitHub Pages.

You should see it show the url of your site as below where the first part of the url is your github username

[https://jesscmoore.github.io/jekylldemo/](https://jesscmoore.github.io/jekylldemo/)



# Personalise our site

Before we make changes to the site, we must create a new git branch. In the Branch tab of GitHUb Desktop:

Click the down arrow
Then click `New Branch`
Set the branch name to "personalise-repo"

In text editor, open `_config.yml` file_, and change the website title, description, and contact details

```
title: [YOUR PREFERRED WEBSITE TITLE]
email: [EMAIL]
description: >- # this means to ignore newlines until "baseurl:"
  Data nerd, hiker, outdoor lover, and once an astronomer.
baseurl: "/jekylldemo" # the subpath of your site, e.g. /blog
url: "[GITHUB_USERNAME].github.io" # the base hostname & protocol for your site, e.g. http://example.com
twitter_username: [TWITTER_USERNAME]
github_username:  [GITHUB_USERNAME]
```

To commit these changes, go to `GitHub Desktop` app, then

Enter a commit comment
Click `Commit to personalise-repo` where that is the name of your current branch
Click `Push Origin` to push local changes to origin
Click `Create Pull Request` which opens a create pull request in your repo on github.com.

Look for any conflicts, then 

Click `Merge Pull Request`
Click `Confirm Merge`



# Deploy html to github-pages

After merging a change to main branch, it should deploy automatically quite quickly to github pages. To check, go to your github repo on github.com i.e. [https://github.com/jesscmoore/jekylldemo](https://github.com/jesscmoore/jekylldemo). On right hand side of the page, scroll down to `Environments`, and click `github-pages` environment to show all code deployments to github.io. It should show that a change has just been deployed to the https://github.com/jesscmoore/jekylldemo.

Note: It can take up to 20 minutes for changes to your site to publish after you push the changes to GitHub. If your don't see your changes reflected in your browser after an hour, see [About Jekyll build errors for GitHub Pages sites](https://docs.github.com/en/github/working-with-github-pages/about-jekyll-build-errors-for-github-pages-sites).


## Local hosting

Or if localhosting only, after updating page text, serve the webpage by typing

`jekyll serve`


# Useful references

- YML syntax [https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml](https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml)
- More YML syntax [https://learnxinyminutes.com/docs/yaml/](https://learnxinyminutes.com/docs/yaml/)
- Sangsoo Nam's article [Writing Upcoming Posts in GitHub Pages](http://sangsoonam.github.io/2018/12/27/writing-upcoming-posts-in-github-pages.html)
- Sangsoo Nam's article [Syntax Highlighting in Jekyll](http://sangsoonam.github.io/2019/01/20/syntax-highlighting-in-jekyll.html)
