# encoding: utf-8

# Setup load paths
PRINTER_ROOT = File.expand_path '../..', __FILE__
$:.unshift "#{PRINTER_ROOT}/lib"
$:.unshift "#{PRINTER_ROOT}/app"
$:.unshift "#{PRINTER_ROOT}/app/models"

# Mongoid
require 'mongoid' # meh... this takes like forever. :(
ENV['RACK_ENV'] ||= 'development'
Mongoid.load! "#{PRINTER_ROOT}/conf/mongoid.yml"

require 'will_paginate'
require 'sinatra/async'
require 'haml'

# Application stuff... autoload anyone?
require 'printer_log'
require 'job'
require 'printer'
