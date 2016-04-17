class UsersController < ApplicationController
  require 'httParty'
  # require 'candidate'

  def index
    @user = User.new
  end

  # def new
  #   @user = User.new(params[:user])
  # end

# routed as location
  def create
    @user = User.create(user_params)
    redirect_to candidates_path
  end

# routed as candidates
  def candidates
    @user = User.where(id: session[:user_id]).first
    @zip5 = "79901"
    # @zip5 = 11105
    # @zip4 = 1909
    # @zip5 = @user.zip
    # @zip4 = @user.zip4

    # Call and parse API to get STATS about candidate
    @candidate = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}"
    ### above API call isn't working.  Maybe this doesn't respond to a direct call, as feared? ###
    @candidateHash = @candidate.parsed_response["candidateList"]["candidate"]

    # def vote_parser
    #   b = 0
    #   return b
    #   b += 1
    # end
    

  end

  def user_params
    params.require(:user).permit(:zip)
  end
end