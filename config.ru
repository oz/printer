require ::File.expand_path '../conf/boot',  __FILE__
require 'rack/cache'

use Rack::Cache,
  :verbose     => ENV['RACK_ENV'] == 'development',
  :metastore   => "file:#{PRINTER_ROOT}/tmp/cache/rack/meta",
  :entitystore => "file:#{PRINTER_ROOT}/tmp/cache/rack/body"

run Printer
