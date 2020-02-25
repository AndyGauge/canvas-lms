module OnGuard
  class SignUpsController < ApplicationController

    def show
      @user = User.new
      @organization = @user.build_on_guard_organization
      @supervisor = @user.build_on_guard_supervisor
    end

    def create
      @sign_up = OnGuard::SignUp.new(params).create
    end

    def update
      @sign_up = OnGuard::SignUp.new(params).update
      if @sign_up.complete
        redirect_to @sign_up.user
      end
    end

    private

  end
end
