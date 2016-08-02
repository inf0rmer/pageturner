require "app/models/git_repository"
require "app/workers/builder"
require "app/routes/api_base"
require "app/routes/hooks"

class App < Sinatra::Base

  register Sinatra::Initializers

  configure do
    set :root, APP_ROOT.to_s
  end

  use Routes::Hooks

  not_found do
    halt(404, {}, { code: 404 })
  end

end
