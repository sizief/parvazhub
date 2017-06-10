FROM ruby:2.2.3-slim

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client ruby-dev

# Install SQLITE for test
RUN apt-get install libsqlite3-dev

# For a JS runtime
RUN apt-get install -y nodejs

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/flightsearch

# Define home for bundler 
ENV HOME=$RAILS_ROOT

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT


COPY Gemfile Gemfile

COPY Gemfile.lock Gemfile.lock

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Finish establishing our Ruby enviornment
RUN bundle install

EXPOSE 3000

# Copy the Rails application into place
COPY . .

# Create precomplie assets
run rake assets:precompile

ENV TZ=Asia/Tehran
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Make folder writable for pid and log for unicorn 
RUN chmod -R ug+rwx $RAILS_ROOT/tmp $RAILS_ROOT/log $RAILS_ROOT && \
   chown -R 1001:0 $RAILS_ROOT
#USER 1001

CMD [ "config/containers/app_cmd.sh" ]