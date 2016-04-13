class UsersController < ApplicationController
  require 'httParty'

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
    # @zip5 = 11105
    @zip5 = 79901
    # @zip4 = 1909
    @i = 0
    # @zip5 = @user.zip
    # @zip4 = @user.zip4

    # Call and parse API to get STATS about candidate
    @candidate = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}"
    @candidateHash = @candidate.parsed_response["candidateList"]["candidate"]
    #Set candidate ID to call other relevant hashes from the API
    @Id = @candidateHash[@i]["candidateId"]
    # Call and parse API to get candidate BIO
    @candidateBio = HTTParty.get "http://api.votesmart.org/CandidateBio.getBio?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
    @candidateBioHash = @candidateBio.parsed_response["bio"]["candidate"]
    @candidatePhoto = @candidateBioHash["photo"]
  end

  def user_params
    params.require(:user).permit(:zip)
  end
end