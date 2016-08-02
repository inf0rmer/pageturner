class App < Sinatra::Base

  register Sinatra::Initializers

  configure do
    set :root, APP_ROOT.to_s
  end

  #use Routes::V1_0_0::LearningActivityFinishes

  get "/" do
    [200, {}, "it works!"]
  end

  not_found do
    halt(404, {}, { code: 404 })
  end

end
