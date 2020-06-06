module Users
  module OnGuard
    # Returns the date of most recent completion unless curses are still pending.
    # Has the benefit of treating no enrollment/completions the same as having unfinished course.
    def completion
      enrollments.maximum(:created_at)&.to_date if enrollments.where(completed_at: nil).empty?
    end
  end
end
