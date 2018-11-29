require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "validation.rb"
require_relative 'download.rb'

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
	erb :index
end

post "/process_download" do
	urls = Array.new
	
	4.times do |x|
		key = "url" + x.to_s
		if valid_url(params[key])
			download_mp3(params[key])
		end
	end
	

	if urls.empty? 
		flash[:error] = "Please enter a Youtube URL "
	else
		flash[:success] = "Will download in the future"
	end
	redirect "/"
end