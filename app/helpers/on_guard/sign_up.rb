module OnGuard
  class SignUp
    attr_reader :user, :complete
    def initialize(params)
      @params = params
    end
    def create
      begin
        @user = User.create!
        @user.update!(@params.require(:user).permit(
            :name,
            :email
        ))
        @user.create_on_guard_organization! name: @params[:user][:organization][:name]
        @user.save!
      rescue
        @user.destroy
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
