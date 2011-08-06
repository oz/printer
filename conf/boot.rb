# encoding: utf-8

# Setup load paths
PRINTER_ROOT = File.expand_path '../..', __FILE__
$:.unshift "#{PRINTER_ROOT}/lib"
$:.unshift "#{PRINTER_ROOT}/app"
$:.unshift "#{PRINTER_ROOT}/app/models"

require 'will_paginate'
require 'sinatra/async'
require 'haml'

require 'mongo'
require 'em-synchrony'
require 'mongoid' # meh... this takes like forever. :(

# Mongoid config
ENV['RACK_ENV'] ||= 'development'
Mongoid.load! "#{PRINTER_ROOT}/conf/mongoid.yml"
Mongoid.logger = nil if ENV['RACK_ENV'] == 'production'

# Application stuff... autoload anyone?
require 'printer_log'
require 'job'
require 'printer'
