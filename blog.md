---
layout: page # home
title: Blog
---

<!-- Include intro blurb text here -->

{% assign my_notes = site.posts | where: "layout","note" %}
{% assign my_posts = site.posts | where: "layout","post" %}

{% for post in my_posts %}
{{ post.date | date_to_string }}
<h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
<br>
{% endfor %}
