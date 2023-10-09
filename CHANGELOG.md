# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - 🔜
### Changed
- Add support for Ruby 3.1 and 3.2
- Add support for Sinatra 3
- Add support for ActiveSupport 7
- Drop support for Ruby 2.5, 2.6 and 2.7
- Drop support for Sinatra 1
- Drop support for ActiveSupport 5

## [0.32.0] - 2021-09-29
### Changed
- Add `rake db:migrate:status` to report the status of database migrations ([#345](https://github.com/interagent/pliny/pull/345)).

## [0.31.0] - 2021-09-02
### Changed
- Add `rake db:version` to report the current DB schema version ([#343](https://github.com/interagent/pliny/pull/343)).
  This is useful for debugging and building more [robust Heroku Release Phase scripts](https://gist.github.com/stevenharman/98576bf49b050b9e59fb26626b7cceff).

## [0.30.1] - 2021-06-17
### Changed
- Drop Ruby 2.4, add 2.7 and 3.0 to CI runs.
- Relax Thor constraint; allow 1.0, but not 2.0. ([#340](https://github.com/interagent/pliny/pull/340))

## [0.30.0] - 2020-12-14
### Fixed
  - Return Bad Request (400) instead of Internal Server Error (500) when the JSON request payload is unable to be parsed ([#338](https://github.com/interagent/pliny/pull/338))
  - Ensure newline characters are removed from log strings. ([#333](https://github.com/interagent/pliny/pull/333))

## [0.29.0] - 2020-09-30
### Fixed
- **BREAKING**: Register `Serialize` sinatra extension correctly. This will require a change in `lib/endpoints/base.rb` - see [here](https://github.com/interagent/pliny/pull/337/files#diff-c7736e8c14f72274bc01c22fe809a6bb). ([#337](https://github.com/interagent/pliny/pull/337))

## [0.28.0] - 2020-05-06
### Changed
  - Ensure all strings with spaces are quoted in logs. ([#332](https://github.com/interagent/pliny/pull/332))
  - Allow ActiveSupport 5 or 6. ([#331](https://github.com/interagent/pliny/pull/331))

### Fixed
  - Ruby warning about `File.exists?` being deprecated. ([#330](https://github.com/interagent/pliny/pull/330))

## [0.27.1] - 2018-01-18
### Changed
- Have Travis CI build against Ruby 2.4 - 2.6. ([#329](https://github.com/interagent/pliny/pull/329))

### Fixed
- Handle a JSON Array of parameters. ([#328](https://github.com/interagent/pliny/pull/328))

## [0.27.0] - 2018-01-18
### Changed
- Upgrade Rubocop to fix a security vulnerability. ([#325](https://github.com/interagent/pliny/pull/325))
- Have Travis CI build against Ruby 2.2 - 2.5. ([#326](https://github.com/interagent/pliny/pull/326))

### Fixed
- Sort migrations by filename. ([#324](https://github.com/interagent/pliny/pull/324))

## [0.26.2] - 2017-12-15
### Added
- Add person data to Rollbar scope on error reporting. ([#323](https://github.com/interagent/pliny/pull/323))
- Add `zulu_time` serialization helper to serialize date time format consistently. ([#322](https://github.com/interagent/pliny/pull/322))

## [0.26.1] - 2017-12-04
### Added
- Enable Sinatra 1.x tests for Travis. ([#318](https://github.com/interagent/pliny/pull/318))
- Allow customizing additional CORS headers. ([#320](https://github.com/interagent/pliny/pull/320))

### Fixed
- Support using `IndifferentHash` rather than `indifferent_hash` for Sinatra 2. ([#317](https://github.com/interagent/pliny/pull/317), [#319](https://github.com/interagent/pliny/pull/319))

## [0.26.0] - 2017-09-28
### Added
- Add serializer arity and length to canonical log lines. ([#306](https://github.com/interagent/pliny/pull/306))
- Support for Sinatra 2.0 ([#310](https://github.com/interagent/pliny/pull/310))
- Reintroduce instruments middleware as a default middleware. ([#312](https://github.com/interagent/pliny/pull/312))

### Removed
- Deprecated HipChat channel notifier. ([#311](https://github.com/interagent/pliny/pull/311))

## [0.25.1] - 2017-04-11
### Added
- Allow an injectable log scrubber. ([#309](https://github.com/interagent/pliny/pull/308))

## [0.25.0] - 2017-03-24
### Changed
- Ruby 2.4 is now the default. ([#308](https://github.com/interagent/pliny/pull/308))
- Log canonical log lines with default log context. ([#307](https://github.com/interagent/pliny/pull/307))

### Fixed
- Include custom data in scope sent to Rollbar. ([#303](https://github.com/interagent/pliny/pull/303))

## [0.24.0] - 2017-02-16
### Added
- Ruby 2.4 support. Requires `activesupport` 5+ which drops support for Ruby 2.2.1 and below. ([#302](https://github.com/interagent/pliny/pull/302))
- [Canonical Log Lines](https://brandur.org/canonical-log-lines) ([#294](https://github.com/interagent/pliny/pull/294))

## [0.23.0] - 2017-01-10
### Changed
- Puma 3 is now the default. ([#297](https://github.com/interagent/pliny/pull/297))

### Fixed
- Conditionally load Rubocop rake tasks if Rubocop is present. ([#299](https://github.com/interagent/pliny/pull/299))
- Automatic Rubocop refactor missed a `File.exists?` mock. ([#300](https://github.com/interagent/pliny/pull/300))

## [0.22.0] - 2017-01-06
### Added
- Add and apply Rubocop to the template. ([#294](https://github.com/interagent/pliny/pull/294))

### Fixed
- Regression in Rollbar scope extraction. ([#295](https://github.com/interagent/pliny/pull/295))

## [0.21.0] - 2016-12-13
### Added
- Optionally specify `message` on `RescueError` middleware to override the
  default error message for `500 Internal Server Error`.
  ([#276](https://github.com/interagent/pliny/pull/276))

### Changed
- Ruby 2.3.3 is now the default, also brings in Ruby 2.3 to Travis CI matrix.
  ([#290](https://github.com/interagent/pliny/pull/290))
- Add deprecation note to `Pliny::ConfigHelpers`, `Pliny::CastingConfigHelpers`
  is the preferred way.
  ([#292](https://github.com/interagent/pliny/pull/292))

### Fixed
- Handle empty `rack_env` when passing to Rollbar reporter.
  ([#291](https://github.com/interagent/pliny/pull/291))

## [0.20.2] - 2016-12-09
### Added
- Optional `Pliny::Middleware::Metrics` middleware that reports number of
  requests, request latency and class of HTTP status codes.
  ([#289](https://github.com/interagent/pliny/pull/289))

## [0.20.1] - 2016-12-08
### Added
- `Pliny::Metrics.measure` now supports `value` as a keyword parameter as well
  as a block. If provided, it'll be the value reported.
  ([#288](https://github.com/interagent/pliny/pull/288))

### Changed
- `require!` raises `LoadError` if non-existent path is provided.
  ([#287](https://github.com/interagent/pliny/pull/287))

## [0.20.0] - 2016-12-06
### Added
- `Pliny::Metrics.backends` is a configurable list of metrics handlers that
  enable sending metrics to various providers.
  ([#286](https://github.com/interagent/pliny/pull/286))
- `Pliny::Metrics::Backends::Logger` is a a new (and default) metrics handler
  that reports metrics data to logs in l2met format.
  ([#286](https://github.com/interagent/pliny/pull/286))

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

[Unreleased]: https://github.com/interagent/pliny/compare/v0.30.2...master
[0.32.0]: https://github.com/interagent/pliny/compare/v0.31.0...v0.32.0
[0.31.0]: https://github.com/interagent/pliny/compare/v0.30.1...v0.31.0
[0.30.1]: https://github.com/interagent/pliny/compare/v0.30.0...v0.30.1
[0.30.0]: https://github.com/interagent/pliny/compare/v0.29.0...v0.30.0
[0.29.0]: https://github.com/interagent/pliny/compare/v0.28.0...v0.29.0
[0.28.0]: https://github.com/interagent/pliny/compare/v0.27.1...v0.28.0
[0.27.1]: https://github.com/interagent/pliny/compare/v0.27.0...v0.27.1
[0.27.0]: https://github.com/interagent/pliny/compare/v0.26.2...v0.27.0
[0.26.2]: https://github.com/interagent/pliny/compare/v0.26.1...v0.26.2
[0.26.1]: https://github.com/interagent/pliny/compare/v0.26.0...v0.26.1
[0.26.0]: https://github.com/interagent/pliny/compare/v0.25.1...v0.26.0
[0.25.1]: https://github.com/interagent/pliny/compare/v0.25.0...v0.25.1
[0.25.0]: https://github.com/interagent/pliny/compare/v0.24.0...v0.25.0
[0.24.0]: https://github.com/interagent/pliny/compare/v0.23.0...v0.24.0
[0.23.0]: https://github.com/interagent/pliny/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/interagent/pliny/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/interagent/pliny/compare/v0.20.2...v0.21.0
[0.20.2]: https://github.com/interagent/pliny/compare/v0.20.1...v0.20.2
[0.20.1]: https://github.com/interagent/pliny/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/interagent/pliny/compare/v0.19.0...v0.20.0
[0.19.0]: https://github.com/interagent/pliny/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/interagent/pliny/compare/v0.17.1...v0.18.0
[0.17.1]: https://github.com/interagent/pliny/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/interagent/pliny/compare/v0.16.3...v0.17.0
[0.16.3]: https://github.com/interagent/pliny/compare/v0.16.2...v0.16.3
[0.16.2]: https://github.com/interagent/pliny/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/interagent/pliny/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/interagent/pliny/compare/v0.15.1...v0.16.0
