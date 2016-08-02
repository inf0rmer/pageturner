require_relative 'boot'
require 'app'

# health check used by load balancers
map("/pulse") { run -> _ { [200, {}, []] } }

# run application
run App
