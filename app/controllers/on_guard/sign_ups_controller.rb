module OnGuard
  class SignUpsController < ApplicationController
    include Login::Shared

    def show_bak
      logout_current_user
      @user = User.new
      @organization = @user.build_on_guard_organization
      @supervisor = @user.build_on_guard_supervisor
      render :layout => 'bare'

    end

    def show
      #@sign_up = OnGuard::SignUp.new(params).create
      #successful_login(@sign_up.user, @sign_up.pseudonym, false, false)
      js_bundle :payment_signup
      render html: '<div id="root"></div>'.html_safe, layout: 'bare'
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
