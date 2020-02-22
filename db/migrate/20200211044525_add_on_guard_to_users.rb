class AddOnGuardToUsers < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_reference :users, :on_guard_organization, foreign_key: true
  end
end
