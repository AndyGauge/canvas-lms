module OnGuard
  class SignUp
    attr_reader :user, :complete, :pseudonym, :success
    def initialize(params, domain_user_account = nil )
      @params = params
      @domain_user_account = domain_user_account
    end
    def create
      cc_addr =@params[:user][:email]
      if EmailAddressValidator.valid?(cc_addr)
        @user = User.create!(@params.require( :user ).permit( :name ))
        organization = @user.create_on_guard_organization! name: @params[:organization]
        @user.create_on_guard_supervisor! on_guard_organization: organization
        @user.workflow_state='registered'
        @pseudonym = @user.create_pseudonym(unique_id: cc_addr, password: @params[:password], password_confirmation: @params[:passwordConfirmation], workflow_state: 'active')
        @user.accept_terms
        cc = @user.communication_channels.build(:path_type => CommunicationChannel::TYPE_EMAIL, :path => cc_addr)
        @user.save!
        cc.send_confirmation!(@domain_user_account)
        PseudonymSession.new(@pseudonym).save unless @pseudonym.new_record?
        AccountUser.create user: @user, account: organization.account, role_id: 3  #StudentEnrollment role
        @success = OnGuard::Payment.new(organization).create_customer(@params[:paymentMethod])
        return self
      else
        raise 'Invalid Email'
      end
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
