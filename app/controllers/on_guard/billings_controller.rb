module OnGuard
  class BillingsController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization

    def show
      js_bundle :payment_billing
      render html: '<div id="root"></div>'.html_safe, layout:'application'
    end

    private
    def load_organization
      @organization = @current_user.on_guard_organization
      redirect_to '/' unless @current_user.on_guard_supervisor&.on_guard_organization == @organization
    end

  end
end
