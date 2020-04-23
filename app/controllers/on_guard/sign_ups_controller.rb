module OnGuard
  class SignUpsController < ApplicationController
    include Login::Shared

    skip_before_action :verify_authenticity_token

    def show_bak
      logout_current_user
      @user = User.new
      @organization = @user.build_on_guard_organization
      @supervisor = @user.build_on_guard_supervisor
      render :layout => 'bare'

    end

    def show
      js_bundle :payment_signup
      render html: '<div id="root"></div>'.html_safe, layout: 'bare'
    end

    def create
      @sign_up = OnGuard::SignUp.new(params).create
      successful_login(@sign_up.user, @sign_up.pseudonym, false, false)
      render json: {status: @sign_up.success, user_id: @sign_up.user.id}
    end

    def update
      @sign_up = OnGuard::SignUp.new(params).update
      if @sign_up.complete
        redirect_to @sign_up.user
      end
    end

    def complete
      @current_user.on_guard_organization.invite_users(params[:users])
      render json: {status: 'ok'}
    end

    private

  end
end
