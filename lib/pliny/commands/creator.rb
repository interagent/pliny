require "fileutils"

module Pliny::Commands
  class Creator
    attr_accessor :args, :stream

    def self.run(args, stream=$stdout)
      new(args).run!
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
      initialize_template
    end

    def initialize_template
      exec "cd #{app_dir} && ./bin/setup"
    end

    protected

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
