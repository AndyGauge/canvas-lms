module OnGuard
  class Organization < ActiveRecord::Base
    has_many :users, :foreign_key => 'on_guard_organization_id'
    has_many :supervisors, :foreign_key => 'on_guard_organization_id'
    has_many :addresses, :foreign_key => 'on_guard_organization_id'
    belongs_to :account
    ROOT_ACCOUNT = Account.find_by_id(1)

    before_create :generate_account

    def self.find_by_link_code(code)
      where(link_code:code).first
    end

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

    def register_user(name, pseudonym)
      raise "OnGuardImplementationDetail"
    end

    def not_invoiced_users
      @not_invoiced_users ||= users.where(invoiced_at: nil)
    end

    def payment
      OnGuard::Payment.new(self)
    end

    def set_trust(trust_level)
      if created_at > 1.hour.ago  # We must sanitize the data manually if a user wants a different trust level
        return update(type: 'OnGuard::Organization::Trusted') if trust_level=='trusted'
        return update(type: 'OnGuard::Organization::Untrusted') if trust_level=='untrusted'
      end
    end

    def trusted?
      true
    end

    private
    def generate_account
      create_account(root_account: ROOT_ACCOUNT, parent_account: ROOT_ACCOUNT, name: self.name)

      while self.class.where(link_code: code=[*('A'..'Z'),*('0'..'9')].shuffle[0,8].join).present?; end
      self.link_code=code
    end


  end
end
