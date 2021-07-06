# U.S. Go Congress

A maintainable web app for the U.S. Go Congress.
Copyright (c) 2010-2021 American Go Association

[![Maintainability](https://api.codeclimate.com/v1/badges/7cd3a1aa0823c9d00c0c/maintainability)](https://codeclimate.com/github/usgo/gocongress/maintainability)

## Support

[Nate Eagle](mailto:nate.eagle@usgo.org) is the current U.S. Go
Congress webmaster. You can email him or create an issue here with any
questions, concerns, or feedback. Contributions to the site are welcome and
encouraged: if you know some Ruby, JavaScript, or even just HTML/CSS, creating
a pull request is a great way to become part of the team.

## Contribute

1. Prerequisites
   1. Linux (eg. [Ubuntu][15] 16.04+) or Mac OS 10.8+
   1. Docker and Docker Compose Installed (see [Getting Started with Docker][23] for detailed instructions)
   1. Proficiency with [git][13] and [sql][14]
   1. Read [Getting Started with Rails][16]
   1. [Fork and clone][8] this github repo
1. App configuration
   1. [Configure rails to talk to your database][6]
      1. `cp config/database.example.yml config/database.yml`
   1. `cp .env.example .env` (see Configuration below)
   1. If all is well, `docker-compose run test rake -T` should list rake tasks
1. Run the App locally
   1. Run the script and answer the prompts: `./script/admin_tasks/create_user_with_docker.rb`
   1. Run the app: `docker-compose up app`
   1. Open the app in your browser: `http://localhost:3000`
   1. Sign in using the email and password you provided for your new user
   1. Do some developing!
1. Run the tests
   1. `docker-compose run test rake` will run the tests. If they all pass, you're good to go.
1. Submit your contribution
   1. Write a [spec][7] that describes your contribution
   1. Push your changes to your [fork][8] on github
   1. Submit a pull request

## Debugging the Application with `byebug`

First, include `byebug` at a point where you would like the execution to stop. For example,

```ruby

class HomeController < ApplicationController
  rescue_from ActionView::MissingTemplate, :with => :missing_template
  rescue_from ActionController::UnknownFormat, :with => :missing_template

  def index
    byebug
    @bodyClassList = "homepage"
    @slides = SlideSet.new(@year.year).slides_as_arrays
    @contents = Content.yr(@year).homepage.unexpired.newest_first
    @years = 2011..LATEST_YEAR
    @upcoming = CONGRESS_START_DATE[@year.year] >= Date.current
  end

...

```

Once that is done, `byebug` [ByeBug][24] can be used to debug the Go Congress application
from within the `gocongress_app` container, (The container should be created with
`docker-compose up app -d`). To do debug with `byebug` from termnal you can run `docker attach [container_id]`.
**Note: There may be nothing displayed in the ternimal until a `byebug` breakpoint is hit.**

## Configuration

`ENV` variables are stored in a `.env` file, which is git-ignored.
Most of these variables don't belong in source control because they
are secret. Others vary by deployment level. This file will be
loaded by the `dotenv` gem.

For local development, `cp .env.example .env` to get started.
For `stage` and `production` use [heroku config][2].

## Email

### Sent by Rails

See doc/smtp.md

### Received by gocongress.org staff

Email for accounts in the gocongress.org domain is managed through
Google Apps. steve.colburn@usgo.org has access to manage these accounts.

## Thanks

Special thanks to Lisa Scott, who helped invent, and tirelessly tested, the
first year's site in 2011. Special thanks to Jared Beck, who provided
mentoring and assistance for the 2014 site. Special thanks to Tim Hoel and
Jared Beck who both provided mentoring and assistance for the 2015 site.
Special thanks to Rex Cristal, for taking over maintenance of the site from
2015 – 2019!

- 2021: Jared Beck, Michael Hiiva, Nate Eagle, Steve Colburn
- 2020: Rex Cristal, Lisa Scott
- 2019: Gregory Steltenpohl, Nate Eagle, Steve Colburn, Lisa Scott, Dave Weimer
- 2018: Nate Eagle, Joel Cahalan, Steve Colburn, Andrew Jackson
- 2017: Andrew Jackson, Jared Beck, Steve Colburn, Lisa Scott, Ted Terpstra, Les Lanphear
- 2016: Rex Cristal, Walther Chen, Sun Chun
- 2015: Tim Hoel, Jared Beck, Andrew Jackson, Josh Larson, Steve Colburn, Rex Cristal
- 2014: Jared Beck, Andrew Jackson, Matthew Hershberger, Chris Kirschner, Steve
  Colburn, Rex Cristal
- 2013: Chris Kirschner, Judy Debel
- 2012: Arlene Bridges, Bob Bacon, Steve Colburn
- 2011: Lisa Scott, Alf Mikula, Brian David, Andrew Jackson, Steve Colburn

[1]: http://blog.daviddollar.org/2011/05/06/introducing-foreman.html
[2]: https://devcenter.heroku.com/articles/config-vars
[3]: http://bit.ly/YJFlPQ
[4]: http://www.postgresql.org/docs/9.4/interactive/server-start.html#CLIENT-CONNECTION-PROBLEMS
[5]: http://www.postgresql.org/docs/9.4/interactive/index.html
[6]: http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database
[7]: https://www.relishapp.com/rspec
[8]: https://help.github.com/articles/fork-a-repo
[9]: https://github.com/sstephenson/rbenv
[10]: https://www.ruby-lang.org/en/downloads/
[11]: http://nodejs.org/
[12]: http://bundler.io/
[13]: http://git-scm.com/
[14]: http://www.postgresql.org/docs/9.4/static/sql.html
[15]: http://www.ubuntu.com/
[16]: http://guides.rubyonrails.org/
[17]: http://nokogiri.org/tutorials/installing_nokogiri.html
[18]: https://bitbucket.org/ged/ruby-pg/wiki/Home
[19]: http://www.postgresql.org/docs/9.4/interactive/user-manag.html
[20]: http://trac.webkit.org/wiki/JavaScriptCore
[21]: http://guides.rubygems.org/
[22]: https://imagemagick.org/
[23]: https://docs.docker.com/get-docker/
[24]: https://github.com/deivid-rodriguez/byebug
