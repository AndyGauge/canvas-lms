class OnGuard::BillingPlan < ApplicationRecord
  has_many :on_guard_organizations, :class_name => 'OnGuard::Organization'

  def self.default
    self.where(default:true).order(:test).last
  end
end
