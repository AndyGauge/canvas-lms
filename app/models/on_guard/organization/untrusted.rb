class OnGuard::Organization::Untrusted < OnGuard::Organization
  def trusted?
    false
  end
  def register_user(name, pseudonym)
    new_user = self.users.create!(name: name, workflow_state: 'pre-registered')
    new_user.accept_terms
    new_user.save!
    new_user.pseudonym = Pseudonym.create(unique_id: SecureRandom.uuid)
    new_user.user_account_associations.create(account: account)
    Course.where(auto_assigned:true).each do |course|
      StudentEnrollment.create(course:course, user: new_user, role_id: 8)
    end

  end
end
