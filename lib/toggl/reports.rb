require_relative 'exceptions'
require_relative 'reports/connection'
require_relative 'reports/base'
require_relative 'reports/summary'
require_relative 'reports/daily'
require_relative 'reports/weekly'
module Toggl
  class Reports

    class << self
      attr_accessor :api_token
      def reset!
        @api_token = nil
      end

      def api_token
        raise MissingApiToken if @api_token.nil?
        @api_token
      end

      def connection
        @connection ||= Connection.new
      end
    end

    def initialize(workspace_id, from, to)
      @workspace_id = workspace_id
      @from = from
      @to = to
    end

    def summary
      Summary.new(self.class.connection, @workspace_id,@from, @to)
    end

    def weekly
      Weekly.new(self.class.connection, @workspace_id,@from, @to)
    end

    def daily
      Daily.new(self.class.connection, @workspace_id,@from, @to)
    end
  end
end
