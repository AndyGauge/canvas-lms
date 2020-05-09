class AddAutoAssignedToCourse < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_column :courses, :auto_assigned, :boolean
  end
end
