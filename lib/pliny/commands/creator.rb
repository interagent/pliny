require 'fileutils'
require 'pathname'
require 'pliny/version'
require 'uri'

module Pliny::Commands
  class Creator
    DEFAULT_DB_URI_PREFIX = 'postgres:///'.freeze
    DOCKER_DB_URI_PREFIX = 'postgres://postgres@postgres/'.freeze
    # ruby's URI#to_s renders foo:/bar when there's no host
    # we want foo:///bar instead when there's a single '/'
    DB_URI_FIX_REGEX = /:\/(?=[^\/])/

    attr_accessor :args, :opts, :stream

    def self.run(args, opts = {}, stream = $stdout)
      new(args, opts, stream).run!
    end

    def initialize(args = {}, opts = {}, stream = $stdout)
      @args = args
      @opts = opts
      @stream = stream
    end

    def run!
      abort("#{name} already exists") if File.exist?(app_dir)

      FileUtils.copy_entry template_dir, app_dir
      FileUtils.rm_rf("#{app_dir}/.git")
      setup_database_urls
      display 'Pliny app created. To start, run:'
      if opts[:docker]
        display "cd #{app_dir} && docker-compose run web bin/setup"
      else
        display "cd #{app_dir} && bin/setup"
      end
    end

    protected

    def setup_database_urls
      if opts[:docker]
        db = URI.parse(DOCKER_DB_URI_PREFIX + name)
      else
        db = URI.parse(DEFAULT_DB_URI_PREFIX + name)
      end
      {
        '.env.sample' => 'development',
        '.env.test'   => 'test'
      }.each do |env_file, db_env_suffix|
        env_path = "#{app_dir}/#{env_file}"
        db.path  = "/#{name}-#{db_env_suffix}"
        env      = File.read(env_path)
        File.open(env_path, 'w') do |f|
          db_url = db.to_s.sub DB_URI_FIX_REGEX, ':///'
          f.puts env.sub(/DATABASE_URL=.*/, "DATABASE_URL=#{db_url}")
        end
      end
    end

    def display(msg)
      stream.puts msg
    end

    def name
      args.first
    end

    def template_dir
      File.expand_path('../../template', File.dirname(__FILE__))
    end

    def app_dir
      Pathname.new(name).expand_path
    end
  end
end
