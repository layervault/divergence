require 'divergence'
require ::File.expand_path('../config/config',  __FILE__)

use Rack::Static, :urls => ["/images"], :root => "public"

run Divergence::Application.new()