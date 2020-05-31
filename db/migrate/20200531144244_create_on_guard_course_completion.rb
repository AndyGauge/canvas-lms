class CreateOnGuardCourseCompletion < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    create_table :on_guard_course_completions do |t|
      t.references :user, foreign_key: true
      t.references :course, foreign_key: true
      t.timestamps
    end
  end
end
