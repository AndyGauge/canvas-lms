module OnGuard
  class Organization < ActiveRecord::Base
    has_many :users, :foreign_key => 'on_guard_organization_id'
    has_many :supervisors, :foreign_key => 'on_guard_organization_id'
    has_many :addresses, :foreign_key => 'on_guard_organization_id'
    belongs_to :account
    ROOT_ACCOUNT = Account.find_by_id(1)

    before_create :generate_account

    def invite_users(users_collection)
      users_collection.each do |user_attributes|
        cc_addr = user_attributes[:email]
        if EmailAddressValidator.valid?(cc_addr)
          new_user = self.users.create!(name: user_attributes[:name], workflow_state: 'pre-registered')
          new_user.accept_terms
          pseudonym = new_user.pseudonyms.create!(unique_id: user_attributes[:email])
          new_user.communication_channels.create!(:path_type => CommunicationChannel::TYPE_EMAIL, :path => cc_addr, workflow_state: 'unconfirmed')
          new_user.save!
          AccountUser.create user: new_user, account: self.account, role_id: 8  #NoPermissions
          pseudonym.send_registration_notification!
        end
      end
    end

    def not_invoiced_users
      @not_invoiced_users ||= users.where(invoiced_at: nil)
    end

    private
    def generate_account
      create_account(root_account: ROOT_ACCOUNT, parent_account: ROOT_ACCOUNT, name: self.name)
    end
  end
end
