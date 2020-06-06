module Users
  module OnGuard
    # Returns the date of most recent completion unless curses are still pending.
    # Has the benefit of treating no enrollment/completions the same as having unfinished course.
    def completion
      on_guard_course_completions.maximum(:created_at)&.to_date if (enrollments.pluck(:course_id) - on_guard_course_completions.pluck(:course_id)).empty?
    end
  end
end
