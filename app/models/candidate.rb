# class Candidate
#   include HTTParty

#   base_uri "http://api.votesmart.org/"

#   attr_accessor :ballotName, :electionOffice

#   def initialize(zip5, ballotName, electionOffice)
#     puts "Vote for me!"
#     self.zip5 = zip5
#     self.ballotName = ballotName
#     self.electionOffice = electionOffice
#     # @zip5 = @user.zip
#     # puts @zip5
#     # @zip4 = @user.zip4
#   end

#   def findUserCandidates

#   end

# end
  # @user = User.where(id: session[:user_id]).first
  #   # @zip5 = 11105
  #   @zip5 = 79901
  #   @zip4 = 1909
  #   @i = 0
  #   # @zip5 = @user.zip
  #   # @zip4 = @user.zip4

  #   # Call and parse API to get STATS about candidate
  #   @candidate = HTTParty.get "http://api.votesmart.org/Candidates.getByZip?key=#{ENV['VOTESMART_API_KEY']}&zip5=#{@zip5}"
  #   @candidateHash = @candidate.parsed_response["candidateList"]["candidate"]
  #   #Set candidate ID to call other relevant hashes from the API
  #   @Id = @candidateHash[@@i]["candidateId"]
  #   # Call and parse API to get candidate BIO
  #   @candidateBio = HTTParty.get "http://api.votesmart.org/CandidateBio.getBio?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
  #   @candidateBioHash = @candidateBio.parsed_response["bio"]["candidate"]
  #   @candidatePhoto = @candidateBioHash["photo"]