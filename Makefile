SHELL=bash

modules: .init

.init:
	test ! -d .git || git config -f .gitmodules --get-regexp '^submodule\..*\.path$$' | \
	  while read key value; do \
	    url_key=$$(echo $$key | sed 's/\.path/.url/'); \
	    url=$$(git config -f .gitmodules --get "$$url_key"); \
	    git submodule add $$url $$value || true; \
	    git submodule update --init --recursive $$value; \
	  done
	touch .init

.PHONY: modules
