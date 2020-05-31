module OnGuard
  class CourseCompletion < ActiveRecord::Base
    belongs_to :user
    belongs_to :course

  end
end
