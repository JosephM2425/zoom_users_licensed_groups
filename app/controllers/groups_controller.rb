class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
    api_key = Rails.application.credentials[:API_KEY]
    api_secret = Rails.application.credentials[:API_SECRET]

    payload = {
      iss: api_key,
      exp: 1.hour.from_now.to_i
    }
    
    token = JWT.encode(payload, api_secret, "HS256", { typ: 'JWT' })

    url = URI("https://api.zoom.us/v2/users?status=active&page_size=150")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    
    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{token}"
    request["content-type"] = 'application/json'

    response = https.request(request)
    usersJson = JSON.parse(response.read_body)
    
    def countLicenses(usersJson)
      count = 0 
      usersJson["users"].each do |user|
        if user["type"] == 2
          count = count + 1
        end
      end

      return count
    end

    users_with_license = countLicenses(usersJson)

    licenses = 30

    @licencias_restantes = licenses - users_with_license
    
  end

  # GET /groups/1 or /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @users = User.all
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    @users = User.all
  end

  def update_licenses
    @group = Group.find(params[:group_id])
    api_key = Rails.application.credentials[:api_key]
    api_secret = Rails.application.credentials[:api_secret]

    payload = {
      iss: api_key,
      exp: 1.hour.from_now.to_i
    }
    
    token = JWT.encode(payload, api_secret, "HS256", { typ: 'JWT' })

    if params[:group][:actions].include? "put"
      type_licensed = 2
    else 
      type_licensed = 1
    end
    #byebug
    @group.users.each do |user|
      url = URI("https://api.zoom.us/v2/users/#{user.email}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Patch.new(url)
      
      

      request["content-type"] = "application/json"
      request["authorization"] = "Bearer #{token}"
      request.body = { "type": type_licensed }.to_json
      response = https.request(request)
    end
    respond_to do |format|
      format.html { redirect_to @group, notice: "Group licenses succesfully updated"}
    end
    
    
    
    
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :schedule, :actions, user_ids: [])
    end
end
