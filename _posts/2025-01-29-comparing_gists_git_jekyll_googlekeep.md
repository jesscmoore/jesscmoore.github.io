---
layout: post
title:  "Which tool for how-to notes: comparing gists, git, jekyll, and keep"
date:   2025-01-29 15:06:52 +1100
published: true
toc: true
---

I am always on the lookout for the note keeping solution that ensures my notes are managed, accessible, searchable, shareable, but not by default published to the world. These are often my how-to notes invaluable to me for future reference, which may be updated as tools change. Each of these options supports offline use. Here I compare gists, github, jekyll, and Google Keep.


## Gists

Great for sharing code chunks, however these days usually we do this using messaging apps. Renders code and markdown nicely. Gists can be cloned and edited. They can also be set to public or secret. However they don't support ongoing management and search of the information, apart from version management. Each gist must be cloned separately and is given an unreadable hash as the gist folder name. A public gist is link a google dock that is accessible to anyone with the link. As for practical purposes it can't be found unless you know the link or github user and filename.

All my gists can be listed with

`gh gists list`

however this displays the unreadable gist name and last comment, which are not sufficient for me to find where I documented X. There are ways to query one's gists, however this is not easy.

### Github repo

A full repo has the full suite of information management, search and code support options. However it is useful where all the files where we want all the how to documents to have the same access level (either public or private). We can't refine and publish a document without publishing the full repo. I use a repo where I want to research a topic that will be kept private or for coding projects. For non tech collaborators, I can render the markdown to doc or pdf.


### Jekyll

Jekyll is a static website generator enabling content to be easily written in markdown, edited in my favourite editro, and managed on command line.  A jekyll site managed in a github repo provides the right balance of information management and publication support. I can publish a article when it has been drafted and checked, by simply changing the `published: true` in the article yaml header and pushing changes. The repository is public, ie unpublished or work in progress articles can be shared with a url to the file in github, while published articles are online accessible with readable url and indexable.

<!-- Can I render jekyll markdown to doc or pdf? -->


### Google Keep

Google Keep is one of the popular note keeping apps supporting accessibility across devices: mobile, web on different devices. Formatting is limited to one font without any markdown support. Useful for short notes of a non technical nature. Not suited for technical, long form or complex information. I use Google Keep for jotting short notes.


**References**

- https://cli.github.com/manual/gh_gist
- https://jekyllrb.com/docs/usage/
