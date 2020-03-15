class AddOrgToOnGuardSupervisior < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_reference :on_guard_supervisors, :on_guard_organization, foreign_key: true
  end
end
