module OnGuard
  class SignUpsController < ApplicationController
    include Login::Shared

    skip_before_action :verify_authenticity_token

    def show
      js_bundle :payment_signup
      render html: '<div id="root"></div>'.html_safe, layout: 'bare'
    end

    def create
      @sign_up = OnGuard::SignUp.new(params, load_account).create
      successful_login(@sign_up.user, @sign_up.pseudonym, false, false)
      render json: {status: @sign_up.success, user_id: @sign_up.user.id}
    end

    # I don't think this is called anywhere, it does nothing
    def update
      @sign_up = OnGuard::SignUp.new(params).update
      if @sign_up.complete
        redirect_to @sign_up.user
      end
    end

    def complete
      @current_user.on_guard_organization.invite_users(params[:users_to_send])
      OnGuard::Payment.new(@current_user.on_guard_organization).update_quantity(params[:users_to_send].count) if params[:users_to_send] && params[:users_to_send].count > 0
      render json: {status: 'ok'}
    end

    private

  end
end
