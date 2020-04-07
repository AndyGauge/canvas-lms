require 'csv'

module OnGuard
  class Import
    def initialize(file)
      @file = file
      @contents = file.read
      @parsed = CSV.parse @contents
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
        {name: @parsed[r][name_idx], email: @parsed[r][email_idx]}
      end
    end
  end
end
