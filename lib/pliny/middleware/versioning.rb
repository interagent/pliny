require 'http_accept'

module Pliny::Middleware
  class Versioning
    def initialize(app, options={})
      @app = app
      @default = options[:default] || raise("missing=default")
      @app_name = options[:app_name] || raise("missing=app_name")
    end

    def call(env)
      Pliny.log middleware: :versioning, id: env["REQUEST_ID"] do
        detect_api_version(env)
      end
    end

    private

    def detect_api_version(env)
      media_types = HTTPAccept.parse(env["HTTP_ACCEPT"])

      version, variant = nil
      media_types.map! do |media_type|
        if accept_headers.include?(media_type.format)
          unless media_type.params['version']
            error = { id: :bad_version, message: <<-eos }
Please specify a version along with the MIME type. For example, `Accept: application/vnd.#{@app_name}+json; version=1`.
            eos
            return [400, { "Content-Type" => "application/json; charset=utf-8" },
              [MultiJson.encode(error)]]
          end

          unless version
            version, variant = media_type.params["version"].split(".")
          end

          # replace the MIME with a simplified version for easier
          # parsing down the stack
          media_type.format = "application/json"
          media_type.params.delete("version")
        end
        media_type.to_s
      end
      env['HTTP_ACCEPT'] = media_types.join(', ')

      version ||= @default
      set_api_version(env, version, variant)
      set_log_context(version, variant)
      @app.call(env)
    end

    def set_api_version(env, version, variant)
      # API modules will look for the version in env
      env["api.version"] = version
      env["api.variant"] = variant
    end

    def set_log_context(version, variant)
      Pliny.default_context[:api_version] = [version, variant].join(".")
    end

    def accept_headers
      [
        "application/vnd.#{@app_name}",
        "application/vnd.#{@app_name}+json",
        "application/*+json",
      ]
    end
  end
end
