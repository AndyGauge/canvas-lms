module OnGuard
  class RegistrationValidator
    def initialize(user, pseudonym)
      @user = user
      @pseudonym = pseudonym
    end

    def errors
      @errors = []
      if @user[:name].blank?
        @errors << {input_name: 'user[name]', message: 'Cannot be blank'}
      end
      if !EmailAddressValidator.valid? @pseudonym[:email]
        @errors << {input_name: 'pseudonym[email]', message: 'Invalid address'}
      elsif Pseudonym.where(unique_id: @pseudonym[:email]).present?
        @errors << {input_name: 'pseudonym[email]', message: 'E-mail taken'}
      end
      if @pseudonym[:password].length < 8
        @errors << {input_name: 'pseudonym[password]', message: 'Minimum 8 letters'}
      end
      unless @pseudonym[:password] == @pseudonym[:password_confirmation]
        @errors << {input_name: 'pseudonym[password_confirmation]', message: 'Must match'}
      end
      @errors
    end
  end
end
