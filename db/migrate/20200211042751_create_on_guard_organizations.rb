class CreateOnGuardOrganizations < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    create_table :on_guard_organizations do |t|
      t.string :name
      t.timestamps
    end
  end
end
