#require ::File.expand_path '../conf/boot',  __FILE__
require './application'
Printer::Application.initialize!

# Development middlewares
if Printer::Application.env == 'development'
  use AsyncRack::CommonLogger

  # Enable code reloading on every request
  use Rack::Reloader, 0

  # Serve assets from /public
  use Rack::Static,
      :urls => ["/js", "/css"],
      :root => Printer::Application.root(:public)
end

#require 'rack/cache'
#use Rack::Cache,
#  :verbose     => ENV['RACK_ENV'] == 'development',
#  :metastore   => "file:#{PRINTER_ROOT}/tmp/cache/rack/meta",
#  :entitystore => "file:#{PRINTER_ROOT}/tmp/cache/rack/body"

run Printer::Application.routes
