# Pliny

Welcome to your new [Pliny](https://github.com/interagent/pliny) app. This is a placeholder README that describes how
to operate your shiny new app.

## Getting started

First make sure the following is installed:

* [Postgres](http://www.postgresql.org/)
    * The [uuid-ossp](http://www.postgresql.org/docs/9.3/static/uuid-ossp.html) module for Postgres

Then initialize the app:

```bash
$ bin/setup
```

Pliny bundles [some generators](#generators) to help you get started:

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
rake test             # Run tests
```

### Commands

And provides the following commands:

```bash
$ foreman start                             # Starts server
$ foreman run bin/console                   # IRB/Pry console
$ foreman run bin/run 'puts "hello world"'  # Run automated code
```

(hint: don't forget `foreman run` in development)
