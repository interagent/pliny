# Pliny

Opinionated template Sinatra app for writing excellent APIs in Ruby.

[![Build Status](https://travis-ci.org/interagent/pliny.svg?branch=master)](https://travis-ci.org/interagent/pliny)

It bundles some of the patterns we like to develop these apps:

- Config: `ENV` wrapper for explicit defining what config vars are mandatory and optional
- Endpoints: the Sinatra equivalent of a Rails Controller
- Initializers: tiny files to configure libraries/etc (equivalent of Rails)
- Mediators: plain ruby classes to manipulate models
- Models: very thin wrappers around the database

And gems/helpers to tie these together and support operations:

- [CORS middleware](lib/pliny/middleware/cors.rb) to allow JS developers to consume your API
- [Rollbar](https://www.rollbar.com/) for tracking exceptions
- [Log helper](test/log_test.rb) that logs in [data format](https://www.youtube.com/watch?v=rpmc-wHFUBs) [to stdout](https://adam.heroku.com/past/2011/4/1/logs_are_streams_not_files)
- [Mediators](http://brandur.org/mediator) to help encapsulate more complex interactions
- [Rspec](https://github.com/rspec/rspec) for lean and fast testing
- [Puma](http://puma.io/) as the web server, [configured for optimal performance on Heroku](https://github.com/interagent/pliny-template/blob/master/config/puma.rb)
- [Rack-test](https://github.com/brynary/rack-test) to test the API endpoints
- [Request IDs](lib/pliny/middleware/request_id.rb)
- [RequestStore](http://brandur.org/antipatterns), thread safe option to store data with the current request
- [Sequel](http://sequel.jeremyevans.net/) for ORM
- [Sequel-PG](https://github.com/jeremyevans/sequel_pg) because we don't like mysql
- [Versioning](lib/pliny/middleware/versioning.rb) to allow versioning your API in the HTTP Accept header

## Getting started

First make sure the following is installed:

* [Postgres](http://www.postgresql.org/)
    * The [uuid-ossp](http://www.postgresql.org/docs/9.3/static/uuid-ossp.html) module for Postgres

Then install the gem:

```bash
$ gem install pliny
```

And initialize a new app:

```bash
$ pliny-new myapp
$ cd myapp && bin/setup
```

## Working with the app

To learn more about using your new Pliny app, take a look at the README.md in
your new app's directory, or the
[README template](https://github.com/interagent/pliny/README_TEMPLATE.md).

## Development

Run tests:

```
$ bundle install
$ git submodule update --init
$ rake
```

## Meta

Created by Brandur Leach and Pedro Belo.
