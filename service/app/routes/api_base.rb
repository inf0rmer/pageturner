module Routes

  class ApiBase < Sinatra::Base

    before do
      content_type :json
    end

    # register JSON parser
    use Rack::Parser, parsers: {
      "application/json" => -> (body) { JSON.parse(body) }
    }

  end

end
