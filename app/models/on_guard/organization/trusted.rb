class OnGuard::Organization::Trusted < OnGuard::Organization
  def trusted?
    true
  end

  def register_user(name, pseudonym)
    new_user = self.users.create!(name: name, workflow_state: 'pre-registered')
    new_user.accept_terms
    new_user_pseudonym = new_user.pseudonyms.create!(unique_id: pseudonym[:email], password: pseudonym[:password], password_confirmation: pseudonym[:password_confirmation])
    new_user.communication_channels.create!(:path_type => CommunicationChannel::TYPE_EMAIL, :path => pseudonym[:email], workflow_state: 'unconfirmed')
    new_user.save!
    AccountUser.create user: new_user, account: self.account, role_id: 8  #NoPermissions
    new_user.user_account_associations.create(account: account)
    payment.update_quantity
    Course.where(auto_assigned:true).each do |course|
      StudentEnrollment.create(course:course, user: new_user, role_id: 8)
    end
    new_user_pseudonym.send_registration_notification!
  end
end
