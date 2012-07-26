Gocongress
==========

A maintainable web app for the US Go Congress.

Contribute
---------

1. fork the repo in github
1. clone your fork locally
1. install ruby 1.9.2+ (recommend using RVM)
1. install postgres 8.3+ (a modern postgres like 9.1 is fine)
    - get the dev libs too (in apt-get that would be libpq-dev).
      you'll want the dev libs to compile the `pg` gem
1. install a js runtime, like node (apt-get nodejs)
    - macos comes with a js runtime already installed
1. `gem install bundler`
1. `bundle install`
1. if all's well, `bundle exec rake -T` should give you a nice
   list of rake tasks
1. `bundle exec rake db:setup db:test:prepare`
1. create a `config/usgc_env.rb`, according to the
   instructions in `config/application.rb`
1. `bundle exec rake` will run all specs and tests.  if they
   all pass, you're good to go

Thanks
------

* 2012: Arlene Bridges, Bob Bacon, Steve Colburn
* 2011: Lisa Scott, Alf Mikula, Brian David, Andrew Jackson, Steve Colburn
