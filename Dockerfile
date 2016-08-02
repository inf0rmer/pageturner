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

# Prepare folders
RUN mkdir /home/app/builder

# Run Bundle in a cache efficient way
WORKDIR /tmp
COPY service/Gemfile /tmp/
COPY service/Gemfile.lock /tmp/
RUN bundle install

# Add our app
COPY app /home/app/builder
RUN chown -R app:app /home/app

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
