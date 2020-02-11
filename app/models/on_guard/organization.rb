module OnGuard
  class Organization < ActiveRecord::Base
    has_many :users, :foreign_key => 'on_guard_organization_id'
  end
end
