class AddStripeIdToOnGuardOrganization < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_column :on_guard_organizations, :stripe_customer_id, :string
  end
end
