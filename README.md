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
- [Log helper](spec/log_spec.rb) that logs in [data format](https://www.youtube.com/watch?v=rpmc-wHFUBs) [to stdout](https://adam.heroku.com/past/2011/4/1/logs_are_streams_not_files)
- [Mediators](http://brandur.org/mediator) to help encapsulate more complex interactions
- [Rspec](https://github.com/rspec/rspec) for lean and fast testing
- [Puma](http://puma.io/) as the web server, [configured for optimal performance on Heroku](lib/template/config/puma.rb)
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

Pliny also bundles [some generators](#generators) to help you get started:

```bash
$ bundle exec pliny-generate model artist
created model file ./lib/models/artist.rb
created migration ./db/migrate/1408995997_create_artists.rb
created test ./spec/models/artist_spec.rb

$ bundle exec pliny-generate mediator artists/creator
created mediator file ./lib/mediators/artists/creator.rb
created test ./spec/mediators/artists/creator_spec.rb

$ bundle exec pliny-generate endpoint artists
created endpoint file ./lib/endpoints/artists.rb
add the following to lib/routes.rb:
  mount Endpoints::Artists
created test ./spec/endpoints/artists_spec.rb
created test ./spec/acceptance/artists_spec.rb

$ bundle exec pliny-generate migration fix_something
created migration ./db/migrate/1395873228_fix_something.rb

$ bundle exec pliny-generate schema artists
created schema file ./docs/schema/schemata/artist.yaml
rebuilt ./docs/schema.json
```

To test your application:

```bash
$ bundle exec rake
```

Or to run a single test suite:

```bash
$ bundle exec rspec spec/acceptance/artists_spec.rb
```

### Generators

```bash
$ bin/pliny-generate
```

```
Commands:
  pliny-generate endpoint NAME    # Generates an endpoint
  pliny-generate help [COMMAND]   # Describe available commands or one specific command
  pliny-generate mediator NAME    # Generates a mediator
  pliny-generate migration NAME   # Generates a migration
  pliny-generate model NAME       # Generates a model
  pliny-generate scaffold NAME    # Generates a scaffold of endpoint, model, schema and serializer
  pliny-generate schema NAME      # Generates a schema
  pliny-generate serializer NAME  # Generates a serializer
```

### Rake tasks

Pliny comes with several rake tasks:

```bash
rake db:create        # Create the database
rake db:drop          # Drop the database
rake db:migrate       # Run database migrations
rake db:nuke          # Nuke the database (drop all tables)
rake db:reset         # Reset the database
rake db:rollback      # Rollback the database
rake db:schema:dump   # Dump the database schema
rake db:schema:load   # Load the database schema
rake db:schema:merge  # Merges migrations into schema and removes them
rake db:seed          # Seed the database with data
rake db:setup         # Setup the database
rake schema           # Rebuild schema.json
```

### Commands

And provides the following commands:

```bash
$ foreman start                             # Starts server
$ foreman run bin/console                   # IRB/Pry console
$ foreman run bin/run 'puts "hello world"'  # Run automated code
```

(hint: don't forget `foreman run` in development)

## Development

Run tests:

```
$ bundle install
$ rake
```

## Meta

Created by Brandur Leach and Pedro Belo.
