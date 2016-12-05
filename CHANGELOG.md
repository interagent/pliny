# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
- `Pliny::Metrics.backends` is a configurable list of metrics handlers that
  enable sending metrics to various providers.
- `Pliny::Metrics::Backends::Logger` is a a new (and default) metrics handler
  that reports metrics data to logs in l2met format.

## [0.19.0] - 2016-10-12
### Security
- Split `Pliny::Middleware::RequestStore` into `::Clear` and `::Seed` to avoid leaks across requests. This is a breaking change, requiring updates to `routes.rb`. Be aware that middleware ordering is important. See [here for correct ordering](https://github.com/interagent/pliny/blob/2ea455ddcfeac3be8dd6d919d1517753fcbc0fda/lib/template/lib/routes.rb#L2-L7). ([#280](https://github.com/interagent/pliny/pull/280))

## [0.18.0] - 2016-08-01
### Added
- `Pliny::Metrics#count` and `Pliny::Metrics#measure` for emitting [l2met log entries](https://r.32k.io/l2met-introduction). ([#268](https://github.com/interagent/pliny/pull/268))

### Fixed
- Rollbar is optional again ([#275](https://github.com/interagent/pliny/pull/275))

## [0.17.1] - 2016-06-20
### Changed
- Use [rspec-mocks](https://github.com/rspec/rspec-mocks) instead of [rr](https://github.com/rr/rr) ([#273](https://github.com/interagent/pliny/pull/273))

## [0.17.0] - 2016-05-25
### Changed
- Ruby 2.3.1 is now the default, also bumps in Puma and Sequel. ([#269](https://github.com/interagent/pliny/pull/269))
- Cleans up the default `config/config.rb` template. ([#267](https://github.com/interagent/pliny/pull/267))
- Revamp of how errors are reported to Rollbar. ([#265](https://github.com/interagent/pliny/pull/265))

## [0.16.3] - 2016-05-04
### Fixed
- Adds missing `Origin` to `Access-Control-Allow-Headers`, was causing Safari to be unhappy. ([#266](https://github.com/interagent/pliny/pull/266))

## [0.16.2] - 2016-05-01
### Changed
- Upgrade `rack-timeout` to `~0.4`. ([#262](https://github.com/interagent/pliny/pull/262))

### Fixed
- Heroku Button / Review apps will now automatically loads db schema and run migrations. ([#246](https://github.com/interagent/pliny/pull/246))

## [0.16.1] - 2016-04-16
### Added
- Rollbar environment configurable via `ROLLBAR_ENV`. ([#258](https://github.com/interagent/pliny/pull/258))
- Rollbar output is now passed through `Pliny.log`. ([#259](https://github.com/interagent/pliny/pull/259))

## [0.16.0] - 2016-
### Changed
- Ruby 2.3 is now the default. Thanks to @zzak for upgrading [sinatra-contrib](https://github.com/sinatra/sinatra-contrib). ([#253](https://github.com/interagent/pliny/pull/253))

### Fixed
- Useless code coverage reports. ([#255](https://github.com/interagent/pliny/pull/255))
- Cleanup of active database connections after migration runs. ([#257](https://github.com/interagent/pliny/pull/257))

[Unreleased]: https://github.com/interagent/pliny/compare/v0.19.0...HEAD
[0.19.0]: https://github.com/interagent/pliny/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/interagent/pliny/compare/v0.17.1...v0.18.0
[0.17.1]: https://github.com/interagent/pliny/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/interagent/pliny/compare/v0.16.3...v0.17.0
[0.16.3]: https://github.com/interagent/pliny/compare/v0.16.2...v0.16.3
[0.16.2]: https://github.com/interagent/pliny/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/interagent/pliny/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/interagent/pliny/compare/v0.15.1...v0.16.0
