require "rubygems"
require "bundler"

module Printer
  class Application
    def self.root(path = nil)
      @_root ||= File.expand_path(File.dirname(__FILE__))
      path ? File.join(@_root, path.to_s) : @_root
    end

    def self.views
      self.root 'app/views'
    end

    def self.env
      @_env ||= ENV['RACK_ENV'] || 'development'
    end

    def self.routes
      @_routes ||= eval(File.read('./conf/routes.rb'))
    end

    # Initialize the application
    def self.initialize!
      Mongoid.load! "#{self.root}/conf/mongoid.yml"
      Mongoid.logger = nil if self.env == 'production'
    end
  end
end

Bundler.require(:default, Printer::Application.env)

# Preload application classes
Dir['./app/**/*.rb'].each {|f| require f}
Dir['./lib/**/*.rb'].each {|f| require f}
