require 'awesome_print'
require 'bigdecimal'
module Toggl
  class Reports
    class Base
      class << self
        def path
          raise 'Subclass Responsibility'
        end
      end

      def initialize(connection, workspace_id, from, to)
        @connection = connection
        @workspace_id = workspace_id
        @from = from
        @to = to
      end

      def get
        @response ||= @connection.get(
          self.class.path,
          :workspace_id => @workspace_id,
          :user_agent => 'toggl-reports',
          :since => @from,
          :until => @to
        )
      end

      def projects
        get['data'].map do |item|
          OpenStruct.new(
            name: item['title']['project'],
            total_time: seconds(item['time']),
            total_time_display: hours(item['time']),
            entries: time_entries(item['items'])
          )
        end
      end

      def hours(time)
        whole, fraction = (time/3600000.0).divmod(1)
        "%s:%s" % [whole, (fraction * 60).to_i]
      end

      def seconds(time)
        (BigDecimal.new(time) / 1000).to_i
      end

      def time_entries(items)
        items.map do |item|
          OpenStruct.new(
            title: item['title']['time_entry'],
            time: seconds(item['time']),
            time_display: hours(item['time']),
          )
        end
      end

      def inspect
        ap projects
      end
    end
  end
end
