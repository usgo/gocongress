Gocongress
==========

A maintainable web app for the US Go Congress.
Copyright (c) 2013 American Go Association

[![Code Climate](https://codeclimate.com/github/usgo/gocongress.png)](https://codeclimate.com/github/usgo/gocongress)

Licence
-------

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Contribute
---------

1. Set up your local development environment
    1. fork the repo in github
    1. clone your fork locally
    1. install the ruby version specified in the `.rbenv-version`
    1. install postgres 9.1+
        - get the dev libs too (in apt-get that would be libpq-dev).
          you'll want the dev libs to compile the `pg` gem
    1. install a js runtime, like node (apt-get nodejs)
        - macs come with a js runtime already installed
    1. `gem install bundler`
    1. `bundle install`
    1. if all's well, `bundle exec rake -T` should give you a nice
       list of rake tasks
1. Run the tests
    1. `bundle exec rake db:setup db:test:prepare`
    1. `bundle exec rake` will run all specs and tests.  if they
       all pass, you're good to go
1. Submit your contribution
    1. Check that all the tests pass
    1. Push your changes to your fork on github
    1. Submit a pull request

Email
------

If you want your working copy to be able to send email, create
a `config/usgc_env.rb` like this:

    ENV['GMAIL_SMTP_USER'] = 'herpderp@gmail.com'
    ENV['GMAIL_SMTP_PASSWORD'] = 'derpyderp'

Email for accounts in the gocongress.org domain is managed through
google apps. jared.beck@usgo.org has access to manage these accounts.

Thanks
------

Special thanks to Lisa Scott, who helped invent, and tirelessly
tested, the first year's site in 2011.

* 2013: Chris Kirschner
* 2012: Arlene Bridges, Bob Bacon, Steve Colburn
* 2011: Lisa Scott, Alf Mikula, Brian David, Andrew Jackson, Steve Colburn
