class CreateOnGuardBillingPlans < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    create_table :on_guard_billing_plans do |t|
      t.string :name
      t.string :plan
      t.string :price
      t.string :description
      t.string :display_price
      t.boolean :default
      t.boolean :test, default: false
      t.timestamps
    end
    OnGuard::BillingPlan.create(
        name: 'Business Security Awareness',
        plan: 'prod_Jk7jvqZWCE0N18',
        price: 'price_1J6dUMHeTrfEtVDd5v7Wg7IA',
        description: 'Security training for businesses with up to 100 employees.',
        display_price: '$25/mo',
        default: true,
        test: true,
    )
  end
end
