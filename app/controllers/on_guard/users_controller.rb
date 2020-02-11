module OnGuard
  class UsersController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization
    before_action :load_users

    def index
    end

    private
    def load_organization
      @organization = @current_user.on_guard_organization
    end
    def load_users
      @users = @organization.users
    end
  end
end
