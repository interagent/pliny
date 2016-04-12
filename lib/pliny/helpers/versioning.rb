module Pliny::Helpers
  module Versioning

    # A variant is a specially tagged version where new API endpoints can be
    # experimented with. If a user passes a version into the `Accept` header
    # like "3.env-vars", the `api_version` will be "3" and the `api_variant`
    # will be "env-vars".
    #
    # By design, only a single variant can be specified at a time.
    def api_variant
      # set by Versioning middleware
      env["HTTP_X_API_VARIANT"]
    end

    # version like: "1", "2", ...
    def api_version
      # set by Versioning middleware
      env["HTTP_X_API_VERSION"]
    end
  end
end
