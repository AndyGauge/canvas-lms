module OnGuard
  class SignUpsController < ApplicationController

    def show
      @user = User.new
      @organization = @user.build_on_guard_organization
      @supervisor = @user.build_on_guard_supervisor
    end

    def create
      @signup = OnGuard::SignUp.create(params)
    end

    def update
      @signup = OnGuard::SignUp.update(params)
      if @signup.complete
        redirect_to @signup.user
      end
    end

    private

  end
end
