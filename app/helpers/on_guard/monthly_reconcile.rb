module OnGuard
  class MonthlyReconcile
    def initialize(organization)
      @organization = organization
    end

    def non_invoiced_users
      @organization.users.where(invoiced_at: nil)
    end
  end
end
