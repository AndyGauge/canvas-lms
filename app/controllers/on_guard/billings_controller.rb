module OnGuard
  class BillingsController < ApplicationController
    before_action :require_user
    before_action :require_registered_user
    before_action :load_organization
    skip_before_action :verify_authenticity_token


    def show
      js_bundle :payment_billing
      render html: '<div id="root"></div>'.html_safe, layout:'application'
    end

    def stripe
      customer_id = @current_user.on_guard_organization.stripe_customer_id

      customer = Stripe::Customer.retrieve({ id: customer_id })
      invoice_thread = Thread.new { Stripe::Invoice.list({customer: customer_id }) }
      card_thread = Thread.new { Stripe::PaymentMethod.retrieve({id: customer.invoice_settings.default_payment_method }) }
      render plain: {
            "subscription" => customer.subscriptions.data.max.to_json,
            "item" => customer.subscriptions.data.max.items.data.max.to_json,
            "invoices" => invoice_thread.value.data.to_json,
            "card" => card_thread.value.card.to_json,
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
    def load_organization
      @organization = @current_user.on_guard_organization
      redirect_to '/' unless @current_user.on_guard_supervisor&.on_guard_organization == @organization
    end

  end
end
