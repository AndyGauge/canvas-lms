module OnGuard
  class Supervisor < ActiveRecord::Base
    belongs_to :user
    belongs_to :on_guard_organization, :class_name => 'OnGuard::Organization'
  end
end
