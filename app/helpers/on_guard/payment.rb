###
# Convert into AR object
# ##
# "paymentMethod"=>{"id"=>"pm_1GRrl4HeTrfEtVDdsPn1Ffry", "object"=>"payment_method", "billing_details"=>{"address"=>{"city"=>nil, "country"=>nil, "line1"=>nil, "line2"=>nil, "postal_code"=>"97302", "state"=>nil}, "email"=>nil, "name"=>"me", "phone"=>nil}, "card"=>{"brand"=>"visa", "checks"=>{"address_line1_check"=>nil, "address_postal_code_check"=>nil, "cvc_check"=>nil}, "country"=>"US", "exp_month"=>10, "exp_year"=>2020, "funding"=>"credit", "generated_from"=>nil, "last4"=>"4242", "three_d_secure_usage"=>{"supported"=>true}, "wallet"=>nil}, "created"=>1585452263, "customer"=>nil, "livemode"=>false, "metadata"=>{}, "type"=>"card"}}
module OnGuard
  class Payment
    def initialize(organization)
      @organization = organization
    end
    def create_customer(paymentMethod)
      #TODO: organization address should be linked to subscription, supervisor email address through subscription
      supervisor = @organization.supervisors.last

      stripe_customer = Stripe::Customer.create({
                                  name: @organization.name,
                                  payment_method: paymentMethod[:id],
                                  invoice_settings: {
                                      default_payment_method: paymentMethod[:id]
                                  },
                                  metadata: {
                                      organization_id: @organization.id
                                  },
                                  email: supervisor.user.email
      })
      if stripe_customer.id
        @organization.update(stripe_customer_id: stripe_customer.id)
        stripe_subscription = Stripe::Subscription.create({
                                        customer: stripe_customer.id,
                                        items: [
                                            {
                                                plan: ENV.fetch('STRIPE_PLAN')
                                            }
                                        ],
                                        expand: ['latest_invoice.payment_intent'],
                                    })
        return stripe_subscription[:status]
      else
        return "failed"
      end
    end
  end
end
