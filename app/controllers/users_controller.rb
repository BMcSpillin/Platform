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
    if @user.valid?
      @user.save!
      redirect_to zip_path
    else
      flash[:error] = @user.error
      render :index
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

  # <!-- Call Votesmart API for Bio -->
      @candBio = HTTParty.get "http://api.votesmart.org/CandidateBio.getDetailedBio?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
      
      @candBioHash = @candBio["bio"]["candidate"]
      @candEducationHash = @candBioHash["education"]
      @candProfessionHash = @candBioHash["profession"]
      @candExperienceHash = @candBioHash["political"]
      # @candOffice = @candBio["bio"]["office"]

  # Office Type
      # if @candOffice = nil
      #   @candArray[@i]["office"] = "Other"
      # elsif @candOffice["type"] != nil
      #   @candArray[@i]["office"] = @candOffice["type"]
      # elsif @candOffice["name"] != nil
      #   @candArray[@i]["office"] = @candOffice["name"]
      # else
      #   @candArray[@i]["office"] = "Other"
      # end

  #LOCAL OFFICE ARRAY
    @localOffices = ["Comptroller", "Council", "Parish President", "Mayor", "Vice Mayor", "County Sheriff", "Public Advocate", "Township Manager", "Township Committee Member", "Town Supervisor", "Town Manager", "Town Clerk", "Town Board Member", "Assembly Member", "Assistant Deputy Mayor", "Assistant Judge", "Assistant Mayor", "Board Chairman", "Selectperson", "Selectman", "Town Administrator", "Sole Commissioner", "Single Member", "Secretary", "Representative", "Regional Elder", "Probate Judge", "Presiding Officer", "Board Member", "Board President", "Borough President", "Burgess", "Chairman", "City Director", "City Manager", "Clerk", "Municipal Manager", "Police Juror", "President of Commission", "Municipal Clerk", "Metro Councilmember", "Member", "Mayor President", "Freeholder", "Executive", "Director", "Deputy Vice Mayor", "Deputy Town Supervisor", "Deputy Supervisor", "Deputy Presiding Officer", "Deputy Mayor", "Deputy Executive", "Delegate", "County Treasurer", "County Supervisor", "County Solicitor", "Councilperson", "Councilor", "Councilmember", "County Magistrate", "Councilman", "Commission", "Freeholder", "Village Manager", "Public Advocate", "Clerk of Courts", "Chair of Commission", "County Judge and Executive", "Council Member", "Alderman", "Trustee", "County Register of Wills", "County Recorder of Deeds", "County Member", "County Legislator", "County Council", "County Controller", "County Administrator", "Councilman President", "Council Vice President", "Council Solicitor", "Council Secretary", "Council Person", "Council Chairman", "Committeemember", "Committee Member", "Clerk of Judicial Records", "Associate Chief Justice of the Supreme Court", "Associate Justice of the Supreme Court", "Deputy Chief Justice of the Supreme Court", "Judge of the Supreme Court", "Presiding Judge of the Appellate Court", "Presiding Justice of the Supreme Court", "Senior Associate Judge of the Appellate Court", "Senior Associate Justice of the Supreme Court", "Senior Justice of the Supreme Court", "Vice Chief Justice of the Supreme Court", "Vice Presiding Judge of the Appellate Court", "Council President", "Village President", "Supervisor", "First Selectman", "Treasurer", "Magistrate", "First Vice President", "Justice of the Peace", "Second Vice President", "First Vice Chair", "Second Vice Chair", "Chair of County Board", "Chair of County Council", "County Executive", "Chief Executive", "County Mayor", "County Judge", "Commissioner", "Legislator"]
  #STATE OFFICE ARRAY
    @stateOffices = ["Governor", "Lieutenant Governor", "State Assembly", "State House", "State Senate", "State Board of Education", "Auditor", "Auditor and Inspector", "State School Superintendent", "State Superintendent of Public Instruction", "Executive Council", "Public Service Commission Vice Chair", "Legislative Post Auditor", "Director of the Public Utilities Commission", "Commissioner of State Board of Elections", "Attorney General", "Chairman of Board of Education", "Administrator of the Office of State Lands", "Agricultural Commissioner", "Agriculture Commissioner", "Agriculture Director", "Trustee, Office of Hawaiian Affairs", "Chair of the Transport Commission", "Chair of the Railroad Commission", "Chair of the Public Utilities Commission", "Chair of Rail Development Commission", "Chair of Public Utilities Commission", "Chair of Public Service Commission", "Chair of Licensing and Regulation Commission", "Chair of Elections Commission", "Auditor General", "Auditor of Accounts", "Auditor of Public Accounts", "Board of Education Chair", "Budget Director", "Chair of Board of Elections", "Secretary of State", "Chairman of the Department of Agriculture", "Chairman of the Department of Land and Natural Resources", "Chairman of the State Board of Elections", "Chairman of the Tax Commission", "Chief Business Officer of Office for Economic Development", "Chief Executive Officer of Finance Authority", "Chief Financial Officer", "Chief of the Office of Economic Growth", "Clerk of Courts", "Clerk of the Supreme Court", "Commission on Indian Affairs", "Commissioner of Administration", "Commissioner of Administrative and Financial Services", "Commissioner of Agriculture", "Commissioner of Agriculture and Consumer Services", "Commissioner of Agriculture and Forestry", "Commissioner of Agriculture and Industries", "Commissioner of Agriculture and Industry", "Commissioner of Agriculture and Markets", "Commissioner of Banking and Finance", "Commissioner of Commerce", "Commissioner of Commerce and Insurance", "Commissioner of Conservation", "Commissioner of Corrections", "Commissioner of Defense, Veterans and Emergency Management", "Commissioner of Economic and Community Development", "Commissioner of Education", "Commissioner of Elections", "Commissioner of Environment and Conservation", "Commissioner of Environmental Protection", "Commissioner of Environmental Quality", "Commissioner of Finance", "Commissioner of General Land Office", "Commissioner of Health", "Commissioner of Health and Human Services", "Commissioner of Health and Social Services", "Commissioner of Inland Fisheries and Wildlife", "Commissioner of Insurance", "Commissioner of Labor", "Commissioner of Labor and Industries", "Commissioner of Labor and Workforce", "Commissioner of Marine Resources", "Commissioner of Natural Resources", "Commissioner of Professional and Financial Regulation", "Commissioner of Public Lands", "Commissioner of Public Safety", "Commissioner of Revenue", "Commissioner of Schools and Public Lands", "Commissioner of State Lands", "Commissioner of Taxation and Finance", "Commissioner of the Department of Administration", "Commissioner of the Department of Administrative Services", "Commissioner of the Department of Banking", "Corporation Commissioner (Public Utilities)", "Corporation Commissioner", "Corporation Commission Vice-Chairman", "Corporation Commission Chairman", "Coordinator of Indian Affairs", "Controller", "Commissioner of the Department of Banking and Insurance", "Commissioner of the Department of Banking, Insurance, Securities, and Health Care Administration", "Comptroller of the Treasury", "Comptroller of Public Accounts", "Comptroller General", "Commissioner of the Department of Environmental Protection", "Commissioner of the Department of Health", "Commissioner of the Department of Health and Senior Services", "Commissioner of the Department of Human Services", "Commissioner of Veteran's Affairs", "Commissioner of Transportation", "Commissioner of the Office of Administration", "Commissioner of the General Land Office", "Commissioner of the Finance and Administration", "Commissioner of the Department of Veterans' Affairs", "Commissioner of the Department of Transportation", "Commissioner of the Department of Personnel", "Commissioner of the Department of Labor and Workforce Development", "Adjutant General", "Director of Budget and Finance", "Director of Business and Industry", "Director of Department of Agriculture", "Director of Department of Education", "Director of Division of Revenue", "President of the State Board of Education", "President of the Board of Public Utilities", "Director of Education", "Director of Finance", "Director of Finance and Administration", "Director of Health and Human Services", "President of Public Utilities Commission", "Ombudsman", "Chair of Utilities and Transportation Commission", "Chair of the Civil Service Commission", "Chairperson of the Labor and Industry Review Commission", "Commissioner of Agriculture and Commerce", "Commissioner of Human Rights", "Commissioner of Management and Budget", "Commissioner of the Bureau of Mediation Services", "Commissioner of the Department of Energy and Environmental Protection", "Director of the Department of Agriculture and Rural Development", "Director of the Department of Energy, Labor and Economic Growth", "Director of the Department of Family and Protective Services", "Director of the Department of Natural Resources and Environment", "Director of the Department of Technology, Management and Budget", "Director of the Government Accountability Board", "Director of the Office of the State Employer", "Executive Director of Environmental Quality", "Executive Director of Indian Affairs", "Executive Director of the Department of Revenue", "Executive Director of the Workforce Commission", "Secretary of Business, Housing, and Transportation", "Secretary of Food and Agriculture", "Secretary of Health and Human Resources", "Secretary of Workforce Solutions", "Labor and Industry Review Commissioner", "Labor Commissioner", "Labor Commissioner (Department of Labor)", "Labor Commissioner (Labor and Industry)", "Labor Commissioner (Secretary of Labor, Licensing, and Regulation)", "Land Commissioner", "Natural Resources and Conservation Director", "Natural Resources Director", "Office of Homeland Security Director", "Public Health and Human Services Director", "Public Health Commissioner", "Public Safety Commissioner", "Public Service Commission Chair", "Public Service Commissioner", "Public Service Commissioner, President", "Public Utilities Commission Chair", "Public Utilities Commission Vice-Chair", "Public Utilities Commissioner", "Railroad Commissioner", "Revenue Commissioner", "Revenue Director", "School Superintendent", "Secretary of Labor and Workforce Development", "Secretary of Administration", "Secretary of Administration and Finance", "Secretary of Aging", "Secretary of Agriculture", "Secretary of Agriculture and Forestry", "Secretary of Banking", "Secretary of Commerce", "Secretary of Commerce and Tourism", "Secretary of Commerce and Trade", "Secretary of Community and Economic Development", "Secretary of Conservation and Natural Resources", "Secretary of Department of Natural Resources and Environmental Control", "Secretary of Education", "Secretary of Education and Cultural Affairs", "Secretary of Energy and Environmental Affairs", "Secretary of Energy, Minerals and Natural Resources", "Secretary of Environment and Natural Resources", "Secretary of Environmental Protection", "Secretary of Finance", "Secretary of Finance and Administration", "Secretary of Game, Fish and Parks", "Secretary of General Services", "Secretary of Health", "Secretary of Health and Environment", "Secretary of Health and Human Services", "Secretary of Health and Mental Hygiene", "Secretary of Health and Social Services", "Secretary of Housing and Economic Development", "Secretary of Human Services", "State Mine Inspector", "State Courts Administrator", "Secretary of Labor", "State Auditor", "Secretary of Wildlife and Parks", "Secretary of Veterans' Services", "Secretary of Veterans Affairs", "Secretary of Transportation and Construction", "Secretary of Transportation", "Secretary of the Environment", "Secretary of the Education Cabinet", "Secretary of the Department of Revenue", "Secretary of the Department of Health and Hospitals", "Secretary of the Department of Agriculture", "Secretary of the Commonwealth", "Secretary of Labor and Industry", "Secretary of the Budget", "Secretary of Labor and Workforce Development Agency", "Secretary of Legislative Affairs", "Secretary of Natural Resources", "Secretary of Planning and Policy", "Secretary of Public Safety", "Secretary of Public Welfare", "State Superintendent of Schools", "Superintendent of Education", "Superintendent of Public Instruction", "Superintendent of the Insurance Department", "Superintendent, Department of Education", "Tax Commissioner", "Taxation Director", "Transportation Director", "Treasurer and Insurance Commissioner", "Utilities and Transportation Commission", "Secretary of Revenue", "Secretary of Revenue & Regulation", "Secretary of Taxation and Revenue", "Secretary of Technology", "Secretary of the Agency of Commerce and Community Development", "Secretary of the Agency of Human services", "Secretary of the Agency of Natural Resources", "State Mine Inspector (Office of Mine Safety and Licensing)", "Chief Justice of the Supreme Court", "Justice of the Supreme Court", "Chief Judge of the Appellate Court", "Judge of the Appellate Court", "Director of Insurance", "Director of Labor", "Director of Labor and Industrial Relations", "Director of Labor Licensing and Regulation", "Director of Mining and Reclamation Division", "Director of Parks, Recreation and Tourism", "Director of Public Safety", "Director of Revenue", "Director of Revenue and Taxation", "Director of Social Services"]
  #FEDERAL OFFICE ARRAY
    @federalOffices = ["U.S. House", "U.S. Senate", "President", "Chief Judge of the U.S. Court of Appeals", "Chief Judge of the U.S. District Court", "Judge of the U.S. Court of Appeals", "Judge of the U.S. District Court", "Senior Judge of the U.S. Court of Appeals", "Senior Judge of the U.S. District Court", "Solicitor General"]

  # Photo or Placeholder
      if @candBioHash["photo"] != nil
        @candArray[@i]["photo"] = @candBioHash["photo"]
      else
        @candArray[@i]["photo"] = "assets/placeholder.png"
      end
  # Education
      if @candBioHash["education"] != nil
        @candArray[@i]["education"] = @candEducationHash["institution"]
      else
        @candArray[@i]["education"] = "None Available"
      end
  # Profession
      if @candBioHash["profession"] != nil
        @candArray[@i]["profession"] = @candProfessionHash["experience"]
      else
        @candArray[@i]["profession"] = "None Available"
      end
  # Political Experience
      if @candExperienceHash != nil
        @candArray[@i]["experience"] = @candExperienceHash["experience"]
      else
        @candArray[@i]["experience"] = "Not Applicable"
      end
  # <!-- Cal Votesmart API for Votes in prior offices -->
      @candidateVotes = HTTParty.get "http://api.votesmart.org/Votes.getByOfficial?key=#{ENV['VOTESMART_API_KEY']}&candidateId=#{@Id}"
      if @candidateVotes != nil
        @candVotesHash = @candidateVotes["bills"]
        @candArray[@i]["votes"] = @candVotesHash
      else
        @candArray[@i]["votes"] = "Not Applicable"
      end

      @i += 1
    end

  end

  def user_params
    params.require(:user).permit(:zip5, :zip4, :address)
  end

end