Printer Readme
==============

Printer is a simple Sinatra application I hacked this week-end to import
our local printer log files into a MongoDB server to eventually display
nice-looking usage graphs with an extended history.

Getting started
---------------

### Installation

Printer uses the Bundler gem: `bundle install` should take care of
installing all the dependencies. Printer is written with ruby 1.9, and
won't work with 1.8.

### Configuration

Update the `conf/mongoid.yml` file to connect to your MongoDB server
configuration.

### Running

The application is based on Sinatra, and should run on any
Rack-compatible server.  With Thin, issue: `bundle exec thin -R
config.ru start` to get the party started on `http://localhost:3000/`.

Printer behaves according to the `RACK_ENV` environment variable, which
defaults to "development". To run Printer in production, do not forget
to export `RACK_ENV=production`.

Importing printer log files
---------------------------

Write me!

Run `bundle exec bin/sync /path/to/logfile.xml` to import a printer log
file in the system.

Hacking
-------

Run `bundle exec bin/console` to start an IRB shell with the application
loaded.

Rationale
=========

 * I'm bored in a train.
 * Oh what's this XML file I backed-up last week?
 * Ok let's hack stuff, with the few gems installed on this machine.
