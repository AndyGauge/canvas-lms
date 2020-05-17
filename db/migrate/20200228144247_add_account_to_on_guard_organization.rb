class AddAccountToOnGuardOrganization < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_reference :on_guard_organizations, :account, foreign_key: true
  end
end
