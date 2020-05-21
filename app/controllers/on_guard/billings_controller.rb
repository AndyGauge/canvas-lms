module OnGuard
  class BillingsController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization

    def show
      js_bundle :payment_billing
      render html: '<div id="root"></div>'.html_safe, layout:'application'
    end

    def stripe
      customer = Stripe::Customer.retrieve({ id: @current_user.on_guard_organization.stripe_customer_id })
      render plain: {
            "subscription" => customer.subscriptions.data.max.to_json,
            "item" => customer.subscriptions.data.max.items.data.max.to_json,
            "invoices" => Stripe::Invoice.list({customer: @current_user.on_guard_organization.stripe_customer_id }).data.to_json,
            "end_of_month" => Date.today.end_of_month,
            "users_not_invoiced_count" => @organization.not_invoiced_users.count
        }.to_json
    end

    private
    def load_organization
      @organization = @current_user.on_guard_organization
      redirect_to '/' unless @current_user.on_guard_supervisor&.on_guard_organization == @organization
    end

  end
end
