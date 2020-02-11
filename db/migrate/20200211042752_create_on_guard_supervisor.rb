class CreateOnGuardSupervisors < ActiveRecord::Migration[5.2]
  def change
    create_table :on_guard_supervisors do |t|
      t.references :user, foreign_key: true, null: false, limit: 8
      t.timestamps
    end
  end
end
