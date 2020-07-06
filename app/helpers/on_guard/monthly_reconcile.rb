module OnGuard
  class MonthlyReconcile
    def initialize(organization)
      @organization = organization
    end

    def process
      quantity = @organization.not_invoiced_users.count
      return false if ( quantity == 0 || @organization.stripe_customer_id.blank? )

      Stripe::InvoiceItem.create({
                                     customer: @organization.stripe_customer_id,
                                     price: ENV.fetch('STRIPE_PRICE'),
                                     quantity: quantity
                                 })
      invoice = Stripe::Invoice.create({
                                 customer: @organization.stripe_customer_id,
                                 collection_method: :charge_automatically,
                                 auto_advance: true,
                                 description: "New users added in #{Date.today.prev_month.strftime("%B")}"
                             })
      Stripe::Invoice.finalize_invoice(invoice.id)

      @organization.not_invoiced_users.each do |user|
        user.update(invoiced_at: Date.today)
      end
      (@organization.users - @organization.account.users).each do |user|
        user.update(on_guard_organization: nil)
      end

    end

    def self.process_all
      User.where(invoiced_at:nil).pluck(:on_guard_organization_id).uniq.reject(&:blank?).each do |organization_id|
        self.new(Organization.find(organization_id)).process     # TODO: .delay
      end
    end

  end
end
