# frozen_string_literal: true

require "spec_helper"
require "pliny/config_helpers"

describe Pliny::CastingConfigHelpers do
  describe "#rack_env" do
    it "is development if app_env is development" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'development', string
      end

      assert_equal "development", config.rack_env
    end

    it "is development if app_env is test" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'test', string
      end

      assert_equal "development", config.rack_env
    end

    it "is deployment if app_env is production" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'production', string
      end

      assert_equal "deployment", config.rack_env
    end

    it "is deployment if app_env is nil" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, '', string
      end

      assert_equal "deployment", config.rack_env
    end

    it "is deployment if app_env is another value" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'staging', string
      end

      assert_equal "deployment", config.rack_env
    end

    context "when legacy PLINY_ENV is still defined" do
      before do
        ENV['ORIGINAL_PLINY_ENV'] = ENV['PLINY_ENV']
        ENV['PLINY_ENV'] = 'staging'
      end

      after do
        ENV['PLINY_ENV'] = ENV.delete('ORIGINAL_PLINY_ENV')
      end

      it "uses PLINY_ENV value instead of APP_ENV" do
        config = Class.new do
          extend Pliny::CastingConfigHelpers
          override :app_env, 'development', string
        end

        assert_equal "deployment", config.rack_env
      end

      it "displays deprecation warning" do
        config = Class.new do
          extend Pliny::CastingConfigHelpers
          override :app_env, 'development', string
        end

        io = StringIO.new
        $stderr = io
        config.rack_env
        $stderr = STDERR

        assert_includes io.string, "PLINY_ENV is deprecated"
      end
    end
  end

  describe "#pliny_env" do
    it "displays deprecation warning if pliny_env is used" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'development', string
      end

      io = StringIO.new
      $stderr = io
      config.pliny_env
      $stderr = STDERR

      assert_includes io.string, "Config.pliny_env is deprecated"
    end

    it "returns app_env value" do
      config = Class.new do
        extend Pliny::CastingConfigHelpers
        override :app_env, 'foo', string
      end

      assert_equal "foo", config.pliny_env
    end

    context "when legacy PLINY_ENV is still defined" do
      before do
        ENV['ORIGINAL_PLINY_ENV'] = ENV['PLINY_ENV']
        ENV['PLINY_ENV'] = 'staging'
      end

      after do
        ENV['PLINY_ENV'] = ENV.delete('ORIGINAL_PLINY_ENV')
      end

      it "returns PLINY_ENV value" do
        config = Class.new do
          extend Pliny::CastingConfigHelpers
          override :app_env, 'development', string
        end

        assert_equal "staging", config.pliny_env
      end
    end
  end
end
