module OnGuard
  class Supervisor < ActiveRecord::Base
    belongs_to :user
  end
end
