class User < ActiveRecord::Base
  validates :address, presence: true
  # attr_accessor :zip5, :zip4
  # def initialize
  #   puts "new user"
  # end
end
