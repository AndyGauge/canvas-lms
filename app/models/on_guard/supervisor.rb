module OnGuard
  class Supervisor < ActiveRecord::Base
    belongs_to :user
    has_one :on_guard_organization, :through => :user
  end
end
