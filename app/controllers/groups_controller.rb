class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
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
    
    
    api_key = Rails.application.credentials.zoom[:api_key]
    api_secret = Rails.application.credentials.zoom[:api_secret]

    payload = {
      iss: api_key,
      exp: 1.hour.from_now.to_i
    }
    
    token = JWT.encode(payload, api_secret, "HS256", { typ: 'JWT' })

    #@group.users.each do |user|
    #  print user.email
    #end

    @group.users.each do |user|
      url = URI("https://api.zoom.us/v2/users/#{user.email}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Patch.new(url)
      request["content-type"] = "application/json"
      request["authorization"] = "Bearer #{token}"
      request.body = { "type": 1 }.to_json

      response = https.request(request)
      puts "response.read_body"
      puts response.read_body
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
      params.require(:group).permit(:name, :schedule, user_ids: [])
    end
end
