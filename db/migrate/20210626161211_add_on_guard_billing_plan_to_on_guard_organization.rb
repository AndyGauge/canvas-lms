class AddOnGuardBillingPlanToOnGuardOrganization < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_reference :on_guard_organizations, :on_guard_billing_plan, foreign_key: true
  end
  OnGuard::Organization.update_all(on_guard_billing_plan_id: OnGuard::BillingPlan.default)
end
