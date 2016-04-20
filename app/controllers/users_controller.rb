class UsersController < ApplicationController
  require 'httParty'
  require 'cgi'
  
  def index
    # @user = User.new
    @address = ""
  end

  # routed as "location"
  def create
    # SmartyStreets.set_auth("#{ENV['SMARTYSTREETS_AUTH_ID']}", "#{ENV['SMARTYSTREETS_AUTH_TOKEN']}")
    redirect_to zip_path
  end

  def zip
    # cgi = CGI.new
    # urlFriendlyStreet = cgi.escape(params["userAddress"]) 
    @entered = params["userAddress"]
    SmartyStreets::StreetAddressApi.call(
      SmartyStreets::StreetAddressRequest.new(
        :street => "#{CGI::escape("2313 38th st long island city ny")}"
      )
    )

    @zip5 = SmartyStreets::StreetAddressResponse::Components.zipcode
    @zip4 = SmartyStreets::StreetAddressResponse::Components.plus4_code
    @user = User.create(@zip5, @zip4)
    # puts @zipcode
    # @user = User.create(
    #   :zip5 => userAddress.Components[@zipcode]
    #   :zip4 => userAddress.Components[@plus4_code]
    #   )
    redirect_to candidates_path
  end

  # routed as "candidates"
  def candidates
    @user = User.where(id: session[:user_id]).first
    @zip5 = "79901"

  # Call and parse API to get STATS about candidate
    @candidates = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}"
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
  # <!-- For Votes -->    
      @candidateVotes = HTTParty.get "http://api.votesmart.org/Votes.getByOfficial?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
      @candVotesHash = @candidateVotes["bills"]
      @candArray[@i]["votes"] = @candVotesHash............

      @i += 1
    end

      # <!-- For Votes in prior offices -->

  end

  def user_params
    params.require(:user).permit(:zip5, :zip4)
  end
end