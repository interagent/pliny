require "fileutils"

module Pliny::Commands
  class Creator
    attr_accessor :args, :stream

    def self.run(args, stream=$stdout)
      new(args, stream).run!
    end

    def initialize(args={}, stream=$stdout)
      @args = args
      @stream = stream
    end

    def run!
      if File.exists?(app_dir)
        abort("#{name} already exists")
      end

      FileUtils.copy_entry template_dir, app_dir
      FileUtils.rm_rf("#{app_dir}/.git")
      setup_database_urls
      display "Pliny app created. To start, run:"
      display "cd #{app_dir} && bin/setup"
    end

    protected

    def setup_database_urls
      db = URI.parse("postgres:///#{name}")
      {
        ".env.sample" => "development",
        ".env.test"   => "test"
      }.each do |env_file, db_env_suffix|
        env_path = "#{app_dir}/#{env_file}"
        db.path  = "/#{name}-#{db_env_suffix}"
        env      = File.read(env_path)
        File.open(env_path, "w") do |f|
          f.puts env.sub(/DATABASE_URL=.*/, "DATABASE_URL=#{db}")
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
      File.expand_path('../../../template', File.dirname(__FILE__))
    end

    def app_dir
      "./#{name}"
    end
  end
end
