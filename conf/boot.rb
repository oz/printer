# encoding: utf-8

# Setup load paths
PRINTER_ROOT = File.expand_path '../..', __FILE__
$:.unshift "#{PRINTER_ROOT}/lib"
$:.unshift "#{PRINTER_ROOT}/app"
$:.unshift "#{PRINTER_ROOT}/app/models"

require 'sinatra'
#require 'sinatra/synchrony'
require 'haml'
require 'mongoid'
require 'will_paginate'

ENV['RACK_ENV'] ||= 'development'

# Mongoid config
Mongoid.load! "#{PRINTER_ROOT}/conf/mongoid.yml"
Mongoid.logger = nil if ENV['RACK_ENV'] == 'production'

# Application stuff... autoload anyone?
require 'printer_log'
require 'job'
require 'printer'
