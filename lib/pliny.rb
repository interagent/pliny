require "multi_json"
require "sinatra/base"

module Pliny ; end

require "pliny/commands/generator"
require "pliny/errors"
require "pliny/extensions/instruments"
require "pliny/log"
require "pliny/request_store"
require "pliny/router"
require "pliny/utils"
require "pliny/middleware/cors"
require "pliny/middleware/request_id"
require "pliny/middleware/request_store"
require "pliny/middleware/rescue_errors"
require "pliny/middleware/timeout"
require "pliny/middleware/versioning"

module Pliny
  extend Log
end
