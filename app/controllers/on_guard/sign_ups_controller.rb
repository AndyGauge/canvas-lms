module OnGuard
  class SignUpsController < ApplicationController
    include Login::Shared

    def show
      logout_current_user
      @user = User.new
      @organization = @user.build_on_guard_organization
      @supervisor = @user.build_on_guard_supervisor
      render :layout => 'bare'

    end

    def create
      @sign_up = OnGuard::SignUp.new(params).create
      successful_login(@sign_up.user, @sign_up.pseudonym, false, false)
      js_bundle :payment_signup
      render html: '', layout: true
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
