class UsersController < ApplicationController
  require 'httParty'
  require 'smartystreets'
  require 'uri'
  require 'json'
  require 'net/https'
  
  def index
    
  end

  # routed as "location"
  def create
    @user = User.create(params[:id])
    @user.address = params[:user][:address]
    @user.save!
    
    if @user.save 
      redirect_to zip_path
    else
      redirect_to root_path
    end
  end

  def zip
    @user = User.last
    @authID = URI.encode(ENV['SMARTYSTREETS_AUTH_ID'])
    @authToken = URI.encode(ENV['SMARTYSTREETS_AUTH_TOKEN'])

    uri = URI('https://api.smartystreets.com/street-address')
    args = {
      'street' => "#{@user.address}",
      'auth-id' => "#{ENV['SMARTYSTREETS_AUTH_ID']}",
      'auth-token' => "#{ENV['SMARTYSTREETS_AUTH_TOKEN']}"
    }
    uri.query = URI.encode_www_form(args)

    response = Net::HTTP.get_response(uri)

    @responseHash = eval("#{JSON.pretty_generate(JSON.parse(response.body))}")

    @user.zip5 = @responseHash[0][:components][:zipcode]
    @user.zip4 = @responseHash[0][:components][:plus4_code]
    @user.save!
    
    if @user.zip5 != nil
      redirect_to candidates_path
    end

  end

  # routed as "candidates"
  def candidates
  # This will work as long as only one person at a time uses the app :-/
    @user = User.last
    @zip5 = @user.zip5
    @zip4 = @user.zip4

  # Call and parse API to get STATS about candidate
    @candidates = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}&zip4=#{@zip4}&electionYear=2014"
    @candArray = @candidates["candidateList"]["candidate"]

  # Run through candidate array indices
      @i = 0

    while @i < @candArray.size
      # Set candidate ID to call other relevant hashes from the API
      @Id = @candArray[@i]["candidateId"]
  # <!-- For Bio -->
      @candBio = HTTParty.get "http://api.votesmart.org/CandidateBio.getBio?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
      @candBioHash = @candBio["bio"]["candidate"]
      @candArray[@i]["photo"] = @candBioHash["photo"]
  # <!-- For Votes in prior offices -->
        @candidateVotes = HTTParty.get "http://api.votesmart.org/Votes.getByOfficial?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
      if @candidateVotes != nil
        @candVotesHash = @candidateVotes["bills"]
        @candArray[@i]["votes"] = @candVotesHash
      else
        @candArray[@i]["votes"] = {}
      end

      @i += 1
    end

  end

  def user_params
    params.require(:user).permit(:zip5, :zip4, :address)
  end

end