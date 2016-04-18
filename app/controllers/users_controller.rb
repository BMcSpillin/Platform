class UsersController < ApplicationController
  require 'httParty'
  # require 'candidate'

  def index
    @user = User.new
    @address = ""
  end

  # def new
  #   @user = User.new(params[:user])
  # end

# routed as location
  def create
    @addressHash = HTTParty.get "api.smartystreets.com/street-address?auth-id=#{ENV['SMARTYSTREETS-AUTH-ID']}&auth-token=#{ENV['SMARTYSTREETS-AUTH-TOKEN']}&street=#{"userAddress"}&street2=&city=&state=&zipcode="
    @zip5 = @addressHash.parsed_response["components"]["zipcode"]
    @zip4 = @addressHash.parsed_response["components"]["plus4_code"]
    @user = User.create(:zip5 => @zip5, :zip4 => @zip4)
    redirect_to candidates_path
  end

# routed as candidates
  def candidates
    @user = User.where(id: session[:user_id]).first
    # @zip5 = "79901"
    # @addressHash = HTTParty.get "https://api.smartystreets.com/street-address?auth-id=ENV['SMARTYSTREETS-AUTH-ID']&auth-token=ENV['SMARTYSTREETS-AUTH-TOKEN']&#{@address}&street2=&city=&state=&zipcode="
    # @zip5 = @addressHash["components"]["zipcode"]
    # @zip4 = @addressHash["components"]["plus4_code"]
    # @zip5 = 11105
    # @zip4 = 1909
    @zip5 = @user.zip5
    @zip4 = @user.zip4

    # Call and parse API to get STATS about candidate
    @candidate = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}"
    @candidateHash = @candidate["candidateList"]["candidate"]

    # def vote_parser
    #   b = 0
    #   return b
    #   b += 1
    # end
    

  end

  def user_params
    params.require(:user).permit(:zip5, :zip4)
  end
end