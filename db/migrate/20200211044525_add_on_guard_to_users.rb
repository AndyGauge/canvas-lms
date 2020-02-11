class AddOnGuardToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :on_guard_supervisor, foreign_key: true
    add_reference :users, :on_guard_organization, foreign_key: true
  end
end
