FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential
RUN apt-get install -y ruby-dev

# for postgres
RUN apt-get install -y libpq-dev

# for a JS runtime
RUN apt-get install -y nodejs

ENV APP_HOME /flight-search
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME