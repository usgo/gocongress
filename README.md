Gocongress
==========

A maintainable web app for the US Go Congress.

Contribute
---------

1. Set up your local development environment
    1. fork the repo in github
    1. clone your fork locally
    1. install ruby
        - use the version specified in the `.rvmrc` (currently 1.9.3)
    1. install postgres 9.1+
        - get the dev libs too (in apt-get that would be libpq-dev).
          you'll want the dev libs to compile the `pg` gem
    1. install a js runtime, like node (apt-get nodejs)
        - macs come with a js runtime already installed
    1. `gem install bundler`
    1. `bundle install`
    1. if all's well, `bundle exec rake -T` should give you a nice
       list of rake tasks
    1. `bundle exec rake db:setup db:test:prepare`
    1. create a `config/usgc_env.rb`, according to the
       instructions in `config/application.rb`
    1. `bundle exec rake` will run all specs and tests.  if they
       all pass, you're good to go
1. Submit your contribution
    1. Check that all the tests pass
    1. Push your changes to your fork on github
    1. Submit a pull request

Email
------

Email is managed through google apps.  jared.beck@usgo.org has
access to manage accounts.

Thanks
------

Special thanks to Lisa Scott, who helped invent, and tirelessly
tested, the first year's site in 2011.

* 2013: Chris Kirschner
* 2012: Arlene Bridges, Bob Bacon, Steve Colburn
* 2011: Lisa Scott, Alf Mikula, Brian David, Andrew Jackson, Steve Colburn
