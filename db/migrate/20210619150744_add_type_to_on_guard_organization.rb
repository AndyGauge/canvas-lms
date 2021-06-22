class AddTypeToOnGuardOrganization < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_column :on_guard_organizations, :type, :string

  end
end
