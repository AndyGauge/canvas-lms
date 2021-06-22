module OnGuard
  class RegistrationValidator
    def initialize(user, pseudonym, organization)
      @user = user
      @pseudonym = pseudonym
      @organization = organization
    end

    def errors
      if @organization.trusted?
        errors_trusted
      else
        errors_untrusted
      end
    end

    def errors_trusted
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

    def errors_untrusted
      @errors = []
      if @user[:name].blank?
        @errors << {input_name: 'user[name]', message: 'Cannot be blank'}
      end
      @errors
    end
  end
end
