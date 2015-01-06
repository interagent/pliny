require 'fileutils'
require 'pathname'
require 'pliny/version'
require 'uri'

module Pliny::Commands
  class Creator
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
      display "cd #{app_dir} && bin/setup"
    end

    protected

    def setup_database_urls
      db = URI.parse("postgres:///#{name}")
      {
        '.env.sample' => 'development',
        '.env.test'   => 'test'
      }.each do |env_file, db_env_suffix|
        env_path = "#{app_dir}/#{env_file}"
        db.path  = "/#{name}-#{db_env_suffix}"
        env      = File.read(env_path)
        File.open(env_path, 'w') do |f|
          # ruby's URI#to_s renders foo:/bar when there's no host
          # we want foo:///bar instead!
          db_url = db.to_s.sub(':/', ':///')
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
