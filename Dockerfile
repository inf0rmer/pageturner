FROM phusion/passenger-ruby23:0.9.19

MAINTAINER Bruno Abrantes <bruno@brunoabrantes.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Enable nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Create virtual host
ADD docker/vhost.conf /etc/nginx/sites-enabled/builder.conf
ADD docker/env.conf /etc/nginx/main.d/app-env.conf

# Prepare folders
RUN mkdir /home/app/builder
RUN mkdir /etc/service/sidekiq

# Run Bundle in a cache efficient way
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install

# Add our app
ADD . /home/app/builder
RUN chown -R app:app /home/app

# Add runit daemons
ADD docker/sidekiq.sh /etc/service/sidekiq/run

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
