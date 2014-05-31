module Pliny
  module Log
    def log(data, &block)
      data = log_context.merge(data)
      log_to_stream(stdout || $stdout, data, &block)
    end

    def log_context
      RequestStore.store[:log_context] || {}
    end

    def stdout=(stream)
      @stdout = stream
    end

    def stdout
      @stdout
    end

    private

    def log_to_stream(stream, data, &block)
      unless block
        str = unparse(data)
        if RUBY_PLATFORM == "java"
          stream.puts str
        else
          mtx.synchronize { stream.puts str }
        end
      else
        data = data.dup
        start = Time.now
        log_to_stream(stream, data.merge(at: "start"))
        begin
          res = yield
          log_to_stream(stream, data.merge(
            at: "finish", elapsed: (Time.now - start).to_f))
          res
        rescue
          log_to_stream(stream, data.merge(
            at: "exception", elapsed: (Time.now - start).to_f))
          raise
        end
      end
    end

    def mtx
      @mtx ||= Mutex.new
    end

    def quote_string(k, v)
      # try to find a quote style that fits
      if !v.include?('"')
        %{#{k}="#{v}"}
      elsif !v.include?("'")
        %{#{k}='#{v}'}
      else
        %{#{k}="#{v.gsub(/"/, '\\"')}"}
      end
    end

    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.compact.join(" ")
    end

    def unparse_pair(k, v)
      v = v.call if v.is_a?(Proc)
      # only quote strings if they include whitespace
      if v == nil
        nil
      elsif v == true
        k
      elsif v.is_a?(Float)
        "#{k}=#{format("%.3f", v)}"
      elsif v.is_a?(String) && v =~ /\s/
        quote_string(k, v)
      elsif v.is_a?(Time)
        "#{k}=#{v.iso8601}"
      else
        "#{k}=#{v}"
      end
    end
  end
end
