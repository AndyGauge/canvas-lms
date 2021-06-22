module OnGuard
  class SignUpsController < ApplicationController
    include Login::Shared
    layout 'bare'

    skip_before_action :verify_authenticity_token

    def show
      js_bundle :payment_signup
    end

    def create
      @sign_up = OnGuard::SignUp.new(params, load_account).create
      successful_login(@sign_up.user, @sign_up.pseudonym, false, false)
      render json: { status:    @sign_up.success,
                     user_id:   @sign_up.user.id,
                     auth_code: @sign_up.auth_code,
                     link:      register_url(join: @sign_up.auth_code) }
    end

    # Currently responsible for setting Trust
    def update
      if OnGuard::SignUp.new(params).update
        render json: {status: 'addusers'}
      else
        render json: {status: 'error', error: 'unable to update'}, status: 400
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
