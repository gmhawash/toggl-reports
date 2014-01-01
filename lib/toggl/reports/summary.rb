module Toggl
  class Reports
    class Summary < Base
      class << self
        def path
          'summary'
        end
      end
    end
  end
end
