module Pliny
  module Utils
    def self.parse_env(file)
      env = {}
      File.open(file).each do |line|
        line = line.gsub(/#.*$/, '').strip
        next if line.empty?
        var, value = line.split("=", 2)
        value.gsub!(/^['"](.*)['"]$/, '\1')
        env[var] = value
      end
      env
    end

    # Requires an entire directory of source files in a stable way so that file
    # hierarchy is respected for load order.
    def self.require_glob(path)
      files = Dir[path].sort_by do |file|
        [file.count("/"), file]
      end

      files.each do |file|
        require file
      end
    end

    class << self
      alias :require_relative_glob :require_glob
    end
  end
end
