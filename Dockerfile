ARG RUBY_VERSION

FROM ruby:"${RUBY_VERSION}"

ARG BUNDLER_VERSION

WORKDIR /app

RUN apt-get update -qq && \
  apt-get install -y nodejs

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem update --system && \ 
  gem install bundler -v "${BUNDER_VERSION}"
RUN bundle install

COPY script/docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD rails server -b 0.0.0.0
