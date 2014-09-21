# Changelog

## 0.4.0 (2014-09-20)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.3.0...v0.4.0)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.3.0...v0.4.0)

## 0.3.0 (2014-09-09)

[Compare changes in gem](https://github.com/interagent/pliny/compare/0.2.1...v0.3.0)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/0.2.1...v0.3.0)

* Add `encode` helper.
  [#69](https://github.com/interagent/pliny/pull/69) and [pliny-template#132](https://github.com/interagent/pliny-template/pull/132)

  * Add `helpers Pliny::Helpers::Encode` to your `Endpoints::Base`
  * Replace calls to `MultiJson.encode` with `encode` in all your endpoints.
* `Serializers::Base#serialize` will now serialize Arrays and others `Enumberable` objects by itself.
  [pliny-template#125](https://github.com/interagent/pliny-template/pull/125)

  Replace in your Endpoints the call to
  
  ```ruby
  MultiJson.encode User.all.map { |x| serialize(x) }
  ```
  
  with 
  
  ```ruby
  encode serialize(User.all)
  ```
* New `CastingConfigHelpers` pre casts env vars, so you don't have to at all the call sites.
  
  See [pliny-template#131](https://github.com/interagent/pliny-template/pull/131) for how to use it.
* Introduce `lib/application.rb`.
  [pliny-template#133](https://github.com/interagent/pliny-template/pull/133)

  Useful when using gems, like [Sidekiq](http://sidekiq.org/).
  This allows you to require your pliny application in one call.  
  For example in the `Procfile`.
  
  ```
  worker: bundle exec sidekiq --require ./lib/application.rb
  ```

## 0.2.1 (2014-07-21)

[Compare changes in gem](https://github.com/interagent/pliny/compare/0.1.0...0.2.1)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/0.1.0...0.2.1)

## 0.1.0 (2014-06-19)

[Compare changes in gem](https://github.com/interagent/pliny/compare/0.0.4...0.1.0)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/0.0.4...0.1.0)

## 0.0.4 (2014-06-13)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.0.3...0.0.4)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.0.3...0.0.4)

## 0.0.3 (2014-06-04)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.0.1...v0.0.3)
|
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.0.1...v0.0.3)
