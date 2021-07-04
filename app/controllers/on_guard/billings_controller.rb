module OnGuard
  class BillingsController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization_supervisor
    skip_before_action :verify_authenticity_token


    def show
      js_env({BILLING_PLAN: @organization.billing_plan.as_json(only: [:id, :name, :display_price, :description])})
      js_bundle :payment_billing
      render html: '<div id="root"></div>'.html_safe, layout:'application'
    end

    def stripe
      customer_id = @organization.stripe_customer_id

      customer = Stripe::Customer.retrieve({ id: customer_id })
      invoice_thread = Thread.new { Stripe::Invoice.list({customer: customer_id }) }
      card_thread = Thread.new { Stripe::PaymentMethod.retrieve({id: customer.invoice_settings.default_payment_method }) }
      render plain: {
            "subscription" => customer.subscriptions.data.max,
            "item" => customer.subscriptions.data.max.items.data.max,
            "invoices" => invoice_thread.value.data,
            "card" => card_thread.value.card,
            "end_of_month" => Date.today.end_of_month,
            "users_not_invoiced_count" => @organization.not_invoiced_users.count
        }.to_json
    end

    def update_payment
      if params[:payment_method]
        customer_id = @current_user.on_guard_organization.stripe_customer_id
        begin
          Stripe::PaymentMethod.attach(params[:payment_method], customer: customer_id)
          Stripe::Customer.update(customer_id, {invoice_settings: {default_payment_method: params[:payment_method]}})
          render json: {status: 'ok'}
        rescue Stripe::CardError => e
          render json: {status: 'error', error: e.error}
        end

      else
        render json: {status: 'error', error: 'missing payment method'}
      end

    end
    private
    def load_organization_supervisor
      @organization = @current_user.on_guard_organization
      redirect_to '/' unless @organization && @current_user.supervisor?(@organization)
    end
  end
end
