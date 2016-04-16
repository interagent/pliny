module Pliny
  class RollbarLogger
    def debug(message)
      log('debug', message)
    end

    def info(message)
      log('info', message)
    end

    def warn(message)
      log('warn', message)
    end

    def error(message)
      log('error', message)
    end

    def log(level, message)
      Pliny.log(rollbar: true, level: level, message: message)
    end
  end
end
