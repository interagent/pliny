# frozen_string_literal: true

require "fileutils"
require "pathname"
require "pliny/version"
require "uri"
require "erb"
require "ostruct"

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
      parse_erb_files
      display "Pliny app created. To start, run:"
      display "cd #{app_dir} && bin/setup"
    end

    protected

    def parse_erb_files
      Dir.glob("#{app_dir}/{*,.*}.erb").each do |file|
        static_file = file.gsub(/\.erb$/, "")

        template = ERB.new(File.read(file))
        context = OpenStruct.new(app_name: name)
        content = template.result(context.instance_eval { binding })

        File.write(static_file, content)
        FileUtils.rm(file)
      end
    end

    def display(msg)
      stream.puts msg
    end

    def name
      args.first
    end

    def template_dir
      File.expand_path("../../template", File.dirname(__FILE__))
    end

    def app_dir
      Pathname.new(name).expand_path
    end
  end
end
