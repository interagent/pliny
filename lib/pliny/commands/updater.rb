require 'fileutils'
require 'pathname'
require 'pliny/version'
require 'uri'

module Pliny::Commands
  class Updater
    attr_accessor :stream

    def self.run(stream = $stdout)
      new(stream).run!
    end

    def initialize(stream = $stdout)
      @stream = stream
    end

    def run!
      unless File.exist?("Gemfile.lock")
        abort("Pliny app not found - looking for Gemfile.lock")
      end

      version_current = get_current_version
      version_target  = Gem::Version.new(Pliny::VERSION)

      if version_current == version_target
        display "Version #{version_current} is current, nothing to update."
      elsif version_current > version_target
        display "pliny-update is outdated. Please update it with `gem install pliny` or similar."
      else
        display "Updating from #{version_current} to #{version_target}..."
        ensure_repo_available
        save_patch(version_current, version_target)
        exec_patch
      end
    end

    # we need a local copy of the pliny repo to produce a diff
    def ensure_repo_available
      unless File.exists?(repo_dir)
        system("git clone https://github.com/interagent/pliny.git #{repo_dir}")
      else
        system("cd #{repo_dir} && git fetch --tags")
      end
    end

    def get_current_version
      File.read("./Gemfile.lock").split("\n").each do |line|
        next unless pliny_version = line.match(/pliny \(([\d+\.]+)\)/)
        return Gem::Version.new(pliny_version[1])
      end
    end

    def save_patch(curr, target)
      # take a diff from the template folder from diff
      diff = `cd #{repo_dir} && git diff v#{curr}..v#{target} lib/template/`

      # take lib/template away from the path name so we can apply
      diff.gsub!(/^(\-\-\-|\+\+\+) (\w)\/lib\/template/, '\1 \2')

      # save it
      File.open(patch_file, "w") { |f| f.puts diff }
    end

    def exec_patch
      exec "patch --prefix=/tmp/ --reject-file=/tmp/pliny-reject -p1 < #{patch_file}"
    end

    def display(msg)
      stream.puts msg
    end

    def repo_dir
      File.join(Dir.home, ".tmp/pliny-repo")
    end

    def patch_file
      File.join(repo_dir, "pliny-update.patch")
    end
  end
end
