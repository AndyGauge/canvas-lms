module OnGuard
  class Payment
    def initialize(organization)
      @organization = organization
    end
    def create_customer
      #TODO: organization address should be linked to subscription, supervisor email address through subscription
      address = @organization.addresses.last
      supervisor = @organization.supervisors.last
      if address.is_a? OnGuard::Address
        address = address.slice(:line1, :city, :country, :line2, :postal_code, :state)
      end
      stripe_update = Stripe::Customer.create({
                                  name: @organization.name,
                                  metadata: {
                                      organization_id: @organization.id
                                  },
                                  address: address,
                                  email: supervisor.user.email
      })
      if stripe_update.id
        @organization.update(stripe_customer_id: stripe_update.id)
      end
    end
  end
end
