module OnGuard
  class SignUp
    attr_reader :user, :complete, :pseudonym
    def initialize(params)
      @params = params
    end
    def create
        @user = User.create!
        @user.update!(@params.require(:user).permit(
            :name,
            :email
        ))
        organization = @user.create_on_guard_organization! name: @params[:user][:organization][:name]
        @user.create_on_guard_supervisor! on_guard_organization: organization
        @user.workflow_state='registered'
        @pseudonym = @user.create_pseudonym(unique_id: @user.email, password: @params[:user][:pseudonym][:password], password_confirmation: @params[:user][:pseudonym][:password_confirmation], workflow_state: 'active')
        @user.accept_terms
        @user.save!
        PseudonymSession.new(@pseudonym).save unless @pseudonym.new_record?
        AccountUser.create user: @user, account: organization.account, role_id: 3  #StudentEnrollment role
        return self
    end
    def update
      if @params[:billing]
        update_billing
      elsif @params[:users]
        update_members
      else
        raise "OnGuardSignUpInvalidUpdate"
      end
    end

    private
    def update_billing

    end
    def update_members
      @complete = true
    end
  end
end
