module OnGuard
  class Organization < ActiveRecord::Base
    has_many :users, :foreign_key => 'on_guard_organization_id'
    has_many :supervisors, :foreign_key => 'on_guard_organization_id'
    has_many :addresses, :foreign_key => 'on_guard_organization_id'
    belongs_to :account
    ROOT_ACCOUNT = Account.find(1)

    before_create :generate_account

    private
    def generate_account
      create_account(root_account: ROOT_ACCOUNT, parent_account: ROOT_ACCOUNT, name: self.name)
    end
  end
end
