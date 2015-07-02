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
      if File.exists?(repo_dir)
        unless system("cd #{repo_dir} && git fetch --tags")
          abort("Could not update Pliny repo at #{repo_dir}")
        end
      else
        unless system("git clone https://github.com/interagent/pliny.git #{repo_dir}")
          abort("Could not git clone the Pliny repo")
        end
      end
    end

    def get_current_version
      File.read("./Gemfile.lock").split("\n").each do |line|
        next unless pliny_version = line.match(/pliny \(([\d+\.]+)\)/)
        return Gem::Version.new(pliny_version[1])
      end
    end

    def save_patch(curr, target)
      # take a diff of changes that happened to the template app in Pliny
      diff = `cd #{repo_dir} && git diff v#{curr}..v#{target} lib/template/`

      # remove lib/template from the path of files in the patch so that we can
      # apply these to the current folder
      diff.gsub!(/^(\-\-\-|\+\+\+) (\w)\/lib\/template/, '\1 \2')

      File.open(patch_file, "w") { |f| f.puts diff }
    end

    def exec_patch
      # throw .orig and .rej files in /tmp, they're useless with source control
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
