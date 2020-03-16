class CreateOnGuardAddress < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    create_table :on_guard_addresses do |t|
      t.string :line1
      t.string :city
      t.string :country, limit: 2
      t.string :line2
      t.string :postal_code
      t.string :state
      t.references :on_guard_organization, foreign_key: true
    end
  end
end
