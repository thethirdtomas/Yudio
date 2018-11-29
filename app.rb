require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "validation.rb"

#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

enable :sessions
if User.all(type: 2).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.type = 2
	u.save
end
# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	@download_ready = params["download_ready"]
	@video_id = params["video_id"]
	erb :index
end

post "/process_download" do
	
	if valid_url(params[:url])
		video_id = get_video_id(params[:url])
		flash[:success] = "MP3 download ready"
		redirect "/?download_ready=true&video_id=#{video_id}"
	else
		flash[:error] = "Please enter a Youtube URL "
		redirect "/"
	end
end