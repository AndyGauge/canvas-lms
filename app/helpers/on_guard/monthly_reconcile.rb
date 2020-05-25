module OnGuard
  class MonthlyReconcile
    def initialize(organization)
      @organization = organization
    end

    def process
      quantity = @organization.not_invoiced_users.count
      return false if quantity == 0

      Stripe::InvoiceItem.create({
                                     customer: @organization.stripe_customer_id,
                                     price: ENV.fetch('STRIPE_PRICE'),
                                     quantity: quantity
                                 })
      Stripe::Invoice.create({
                                 customer: @organization.stripe_customer_id,
                                 collection_method: :charge_automatically,
                                 description: "New users added in #{Date.today.prev_month.strftime("%B")}"
                             })

      @organization.not_invoiced_users.each { |user| user.update(invoiced_at: Date.today) }

    end
  end
end
