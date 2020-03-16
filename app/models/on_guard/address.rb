module OnGuard
  class Address < ActiveRecord::Base
    belongs_to :on_guard_organization, :class_name => 'OnGuard::Organization'
  end
end
