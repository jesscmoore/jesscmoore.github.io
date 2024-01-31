########################################################################
#
# Makefile for travelco2e app
#
# Time-stamp: <Thursday 2023-06-29 08:41:55 +1000 Jess Moore>
#
# Copyright (c) jessclaremoore@gmail.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

APP=jesscmoore.io
SITE=https://jesscmoore.github.io/
VER=0.1.0
DATE=$(shell date +%Y-%m-%d)

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP) cli:

  build                            Build the $(APP) website
  serve                            Build and locally serve the $(APP) website

  Note:
  commit and push to update remote and publish website $(SITE)

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS
#

build:
	bundle exec jekyll build

serve:
	bundle exec jekyll serve
