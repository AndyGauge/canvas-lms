module OnGuard
  class BillingsController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization
    before_action :load_active_subscription

    def index
    end

    private
    def load_organization
      @organization = @current_user.on_guard_organization
    end
    def load_subscriptions
      #TODO @users = @organization.on_guard_subscriptions.find_or_create(active: true)
    end
  end
end
