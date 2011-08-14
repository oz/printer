#require ::File.expand_path '../conf/boot',  __FILE__
require './application'
Printer::Application.initialize!

# Development middlewares
if Printer::Application.env == 'development'
  use AsyncRack::CommonLogger

  # Enable code reloading on every request
  use Rack::Reloader, 0
end

if Printer::Application.env == 'production'
  use Rack::Cache,
    :verbose     => ENV['RACK_ENV'] == 'development',
    :metastore   => "file:#{Printer::Application.root}/tmp/cache/rack/meta",
    :entitystore => "file:#{Printer::Application.root}/tmp/cache/rack/body"
end

# Serve assets from /public
# XXX not using a proxy to serve these is kinda bad y'know.
use Rack::Static,
  :urls => ['/js', '/css'],
  :root => Printer::Application.root(:public)

run Printer::Application.routes
