# Changelog

* `Serializers::Base#serialize` will now serialize Arrays and others Enumberable objects by itself.
  [pliny-template#125](https://github.com/interagent/pliny-template/pull/125)

  Replace in your Endpoints the call to `MultiJson.encode User.all.map { |x| serialize(x) }` with `MultiJson.encode serialize(User.all)`
* New CastingConfigHelper pre casts env vars, so you don't have to at all the
* call sites. See [pliny-template#131](https://github.com/interagent/pliny-template/pull/131)
* for how to use it.

## 0.1.0 (2014-06-19)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.0.4...v0.1.0)
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.0.4...v0.1.0)

## 0.0.4 (2014-06-13)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.0.3...v0.0.4)
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.0.3...v0.0.4)

## 0.0.3 (2014-06-04)

[Compare changes in gem](https://github.com/interagent/pliny/compare/v0.0.1...v0.0.3)
[Compare changes in template](https://github.com/interagent/pliny-template/compare/v0.0.1...v0.0.3)
