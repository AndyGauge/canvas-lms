module OnGuard
  class SignUp
    attr_reader :user, :complete, :pseudonym, :success
    def initialize(params, domain_user_account = nil )
      @params = params
      @domain_user_account = domain_user_account
    end
    def create
      cc_addr =@params[:user][:email]
      raise 'Invalid Email' unless EmailAddressValidator.valid?(cc_addr)

      @user = User.create!(@params.require( :user ).permit( :name ))
      @organization  = OnGuard::Organization::Untrusted.create! name: @params[:organization], billing_plan: OnGuard::BillingPlan.default
      @user.on_guard_organization = @organization
      @user.create_on_guard_supervisor! on_guard_organization: @organization
      @user.workflow_state='registered'
      @pseudonym = @user.create_pseudonym(unique_id: cc_addr, password: @params[:password], password_confirmation: @params[:passwordConfirmation], workflow_state: 'active')
      @user.accept_terms
      @user.invoiced_at = Time.now

      cc = @user.communication_channels.build(:path_type => CommunicationChannel::TYPE_EMAIL, :path => cc_addr)
      @user.save!
      @pseudonym.send_registration_done_notification!
      cc.send_confirmation!(@domain_user_account)
      PseudonymSession.new(@pseudonym).save unless @pseudonym.new_record?
      AccountUser.create user: @user, account: @organization.account, role_id: 3  #StudentEnrollment role
      AuthenticationProvider.create(account: @organization.account, auth_type: 'canvas')

      # Course.published.where(auto_assigned: true).each do |c|
      #   StudentEnrollment.create(course: c, user: @user)
      # end

      @success = @organization.payment.create_customer(@params[:paymentMethod])
      return self

    end
    def update
      if @params[:trust]
        organization = User.find(@params[:userId])&.on_guard_supervisor&.on_guard_organization
        if organization && organization.link_code == @params[:authCode]
          return organization.set_trust(@params[:trust])
        end
      elsif @params[:billing]
        update_billing
      elsif @params[:users]
        update_members
      else
        raise "OnGuardSignUpInvalidUpdate"
      end
    end

    def auth_code
      @organization&.link_code
    end

    private
    def update_billing

    end
    def update_members
      @complete = true
    end
  end
end
