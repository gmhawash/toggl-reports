require 'faraday'
require 'json'
require 'logger'

module Toggl
  class Connection
    class << self
      def base_url
        'https://toggl.com/reports/api/v2'
      end
    end

    def initialize(base_url=nil)
      @connection = Faraday.new(:url => base_url || self.class.base_url) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
        faraday.response :logger, Logger.new('faraday.log')
        faraday.headers = {'Content-Type' => 'application/json'}
        faraday.basic_auth Toggl::Reports.api_token, 'api_token' # this needs to be after headers
      end
    end

    def get(path, params)
      response = @connection.get path, params
      JSON.parse(response.body)
    end
  end
end
