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
      new_user = self.users.create!(name: name, workflow_state: 'pre-registered')
      new_user.accept_terms
      new_user_pseudonym = new_user.pseudonyms.create!(unique_id: pseudonym[:email], password: pseudonym[:password], password_confirmation: pseudonym[:password_confirmation])
      new_user.communication_channels.create!(:path_type => CommunicationChannel::TYPE_EMAIL, :path => pseudonym[:email], workflow_state: 'unconfirmed')
      new_user.save!
      AccountUser.create user: new_user, account: self.account, role_id: 8  #NoPermissions
      payment.update_quantity
      Course.where(auto_assigned:true).each do |course|
        StudentEnrollment.create(course:course, user: new_user, role_id: 8)
      end


      new_user_pseudonym.send_registration_notification!
    end

    def not_invoiced_users
      @not_invoiced_users ||= users.where(invoiced_at: nil)
    end

    def payment
      OnGuard::Payment.new(self)
    end

    private
    def generate_account
      create_account(root_account: ROOT_ACCOUNT, parent_account: ROOT_ACCOUNT, name: self.name)

      while self.class.where(link_code: code=[*('A'..'Z'),*('0'..'9')].shuffle[0,8].join).present?; end
      self.link_code=code
    end


  end
end
