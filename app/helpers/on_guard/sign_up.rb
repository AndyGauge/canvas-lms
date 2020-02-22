module OnGuard
  class SignUp
    attr_reader :user, :complete
    def create(params)
      begin
        @user = User.create!
        @user.update!(params.require(:user).permit(
            :name,
            :email
        ))
        @user.create_on_guard_organization! name: params[:user][:organization][:name]
        @user.save!
      rescue
        @user.destroy
      end

    end
    def update(params)
      if params[:billing]
        update_billing(params)
      elsif params[:users]
        update_members(params)
      else
        raise "OnGuardSignUpInvalidUpdate"
      end
    end

    private
    def update_billing(params)

    end
    def update_members(params)
      @complete = true
    end
  end
end
