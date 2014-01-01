module Toggl
  class Reports
    class Weekly < Base
      class << self
        def path
          'weekly'
        end
      end
    end
  end
end
