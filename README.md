# Pliny

[![Gem version](http://img.shields.io/gem/v/pliny.svg)](https://rubygems.org/gems/pliny)
[![Build Status](https://travis-ci.org/interagent/pliny.svg?branch=master)](https://travis-ci.org/interagent/pliny)

Pliny helps Ruby developers write and maintain excellent APIs.

It bundles the best patterns, libraries and practices we've seen after writing a lot of APIs.


## Resources

- [Documentation](https://github.com/interagent/pliny/wiki)
- [Mailing list](https://groups.google.com/group/pliny-talk)


## Getting started

Install gem:

```bash
$ gem install pliny
```

And initialize your new API app:

```bash
$ pliny-new myapp
$ cd myapp && bin/setup
```

Pliny bundles [generators](#generators) to help you get started:

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
created schema file ./schema/schemata/artist.yaml
rebuilt ./schema/schema.json
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
$ bundle exec pliny-generate
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

Pliny adds common Rake tasks to help maintain your app:

```bash
rake db:create        # Create the database
rake db:drop          # Drop the database
rake db:migrate       # Run database migrations
rake db:rollback      # Rollback last database migration
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

### Updating

Use `pliny-update` to update the Pliny app in the current directory.

This not only bumps the version dependency, but also applies any changes that happened in the template app (for instance: new initializer, tweaks in the base endpoint, etc).


## Development

Run tests:

```
$ bundle install
$ createdb pliny-gem-test
$ rake
```

## Deployment

Before a Pliny app can use the database, the schema must be loaded & then migrated.

Generally after your initial deployment, execute `rake db:schema:load db:migrate` in the environment's console.

On Heroku specifically:
```
$ git push heroku master
$ heroku run rake db:schema:load db:migrate
```

## Meta

Created by Brandur Leach and Pedro Belo.

MIT licensed.
