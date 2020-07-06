require 'csv'

module OnGuard
  class Import
    def initialize(file, organization = nil)
      @contents = file.read
      @emails = organization ? organization.users.map(&:email) : []
      parse
    end
    def parse
      @parsed = CSV.parse(@contents, skip_lines: /^#/)
      # Google
      first = @parsed[0].index {|header| header =~ /First\s?Name/}
      last = @parsed[0].index {|header| header =~ /Last\s?Name/}
      if first && last
        @parsed = @parsed.map.with_index do |entry, index|
          (index == 0) ? entry + ["Name"] : entry + ["#{entry[first]} #{entry[last]}"]
        end
        @name_idx = @parsed[0].length - 1
      end
      if status=@parsed[0].index {|header| header =~ /Status/}
        @blocked = -> (row) {row[status] == 'Suspended'}
      end
      # Microsoft
      if proxy=@parsed[0].index {|header| header =~ /ProxyAddress/}
        @parsed = @parsed.map.with_index do |entry, index|
          (index == 0) ? entry + ["Email"] : entry + [entry[proxy].split('+').detect {|ad| ad =~ /SMTP:/}.gsub('SMTP:', '')]
        end
        @email_idx = @parsed[0].length - 1
      end
      if display_name=@parsed[0].index {|header| header =~ /DisplayName/}
        @name_idx = display_name
      end
      if blocked_credential=@parsed[0].index {|header| header =~ /BlockCredential/}
        @blocked = -> (row) {row[blocked_credential] == 'TRUE'}
      end
      # Exchange
      if is_valid_security_principal=@parsed[0].index {|header| header =~ /IsValidSecurityPrincipal/}
        @blocked = -> (row) {row[is_valid_security_principal] == 'False' || !!(row[email_idx] =~ /SystemMailbox\{/)}
      end

      @blocked ||= -> (row) {false}
    end
    def email_idx
      @email_idx ||= @parsed[0].index{|e| e=~ /\S+\@\S+\.\S/ } || @parsed[1].index{|e| e=~ /\S+\@\S+\.\S/ } || raise('NoEmailAddressGiven')
    end
    def name_idx
      @name_idx ||= (0..@parsed[0].length-1).to_a.reject {|f| f==email_idx}.first
    end
    def to_json
      i =  @parsed[0][email_idx] =~ /\S+\@\S+\.\S/ ? 0 : 1
      (i..@parsed.length-1).map do |r|
        email = @parsed[r][email_idx]
        duplicate = @emails.include? email
        @emails.push email
        {name: @parsed[r][name_idx], email: email, duplicate: duplicate, blocked: @blocked.call(@parsed[r])}
      end.to_json
    end
  end
end
