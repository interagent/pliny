require "pliny/config_helpers"

# Access all config keys like the following:
#
#     Config.database_url
#
# Each accessor corresponds directly to an ENV key, which has the same name
# except upcased, i.e. `DATABASE_URL`.
module Config
  extend Pliny::CastingConfigHelpers

  # Mandatory -- exception is raised for these variables when missing.
  mandatory :database_url, string

  # Optional -- value is returned or `nil` if it wasn't present.
  optional :placeholder,         string
  optional :versioning_default,  string
  optional :versioning_app_name, string

  # Override -- value is returned or the set default.
  override :db_pool,          5,    int
  override :deployment,       'production', string
  override :port,             5000, int
  override :puma_max_threads, 16,   int
  override :puma_min_threads, 1,    int
  override :puma_workers,     3,    int
  override :rack_env,         'development', string
  override :raise_errors,     false,         bool
  override :root,             File.expand_path("../../", __FILE__), string
  override :timeout,          45,    int
  override :force_ssl,        true,  bool
  override :versioning,       false, bool
  override :pretty_json,      false, bool
end
