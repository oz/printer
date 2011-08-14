Printer Readme
==============

Printer is a simple Ruby application I started on a boring week-end to import
our local printer's log files into a MongoDB server... to eventually display
“pretty” graphs with an extended history.

Getting started
---------------

### Installation

Printer uses the Bundler gem: `bundle install` should take care of installing
all the dependencies. Printer is written with ruby 1.9 in mind, and won't work
with 1.8.

### Configuration

Update the `conf/mongoid.yml` file to connect to your MongoDB server
configuration.

### Running

The application is based on [cramp](http://cramp.in/).

With Thin, issue: `bundle exec thin --timeout 0 -R config.ru start` to get the
party started on [localhost:3000](http://localhost:3000/).

Printer behaves according to the `RACK_ENV` environment variable, which
defaults to "development". To run Printer in production, do not forget
to export `RACK_ENV=production`.

Importing printer log files
---------------------------

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
 * Oooh a shiny new gem called `cramp` appeared!
