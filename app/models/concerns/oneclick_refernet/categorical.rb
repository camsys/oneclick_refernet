module OneclickRefernet
  module Categorical
    extend ActiveSupport::Concern

    def service_count
      services.count
    end

  end
end
