class AddInvoicedToUsers < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_column :users, :invoiced_at, :datetime
  end
end
