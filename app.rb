require "sinatra"
require "stripe"
require 'sinatra/flash'
require 'json'

# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
ENV['SSL_CERT_FILE'] = './cacert.pem'
require 'net/http'
require 'uri'
require 'httparty'

# youtube data public key from Bryan Cancel's Google Developer Console
# AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8
key = "AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8"

# youtube list parameters link below
# https://developers.google.com/youtube/v3/docs/videos/list

require_relative "authentication.rb"
require_relative "validation.rb"

post "/getURL" do
	# grab the params
	song = params[:song]
	album = params[:album]
	artist = params[:artist]

	# define function to easily generate a query string based on params
	def makeQueryString song, album, artist
		string = song
		if(string.nil? == false)
			string += " from "
		end
		string += album
		if(string.nil? == false)
			string += " by "
		end
		string += artist
		return string
	end
	
	# set your parameters
	maxResults = 3
	order = "relevance"
	part = "snippet"
	query = makeQueryString song, album, artist
	relevanceLanguage = "en"
	safeSearch = "none"
	type = "video"
	
	# url is constructed with those params
	url = "https://www.googleapis.com/youtube/v3/search?key=" + key + 
	"&maxResults=" + maxResults.to_s +
	"&order=" + order +
	"&part=" + part +
	"&q=" + URI::encode(query) +
	"&relevanceLanguage=" + relevanceLanguage +
	"&safeSearch=" + safeSearch +
	"&type=" + type
	
	# grab json file that the url outputs
	response = HTTParty.get(url)
	json = response.parsed_response
	videos = json["items"]

	# create  var that we will return to ajax call
	response = []
	
	# create and add the hash for each of the videos
	videos.each{ |video|
		videoHash = {}
		videoHash[:id] = video["id"]["videoId"]
		videoHash[:title] = video["snippet"]["title"]
		videoHash[:description] = video["snippet"]["description"]
		videoHash[:thumbnails] = video["snippet"]["thumbnails"].to_json

		response.push(videoHash)
	}
	
	return response.to_json
end

#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

enable :sessions
set :bind, '0.0.0.0'

if User.all(type: 2).count == 0
	u = User.new
	u.name = "admin"
	u.email = "admin@admin.com"
	u.password = "admin"
	u.type = 2
	u.save

	lib = Library.new
	lib.user_id = u.id
	lib.save
end
# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	@download_ready = params["download_ready"]
	@video_url = params["video_url"]
	erb :index
end

get "/my_library" do
	authenticate!
	erb :"user/myLibrary"
end

post "/process_download" do
	
	if valid_url(params[:url])
		video_url = params[:url]
		flash[:success] = "Click on the link below to begin downloading MP3"
		redirect "/?download_ready=true&video_url=#{video_url}"
	else
		flash[:error] = "Please enter a Youtube URL "
		redirect "/"
	end
end

get "/upgrade" do
	authenticate!
	if current_user && current_user.type < 1
		erb :"/user/upgrade"
	else
		redirect "/"
	end
end

post '/charge' do
	# Amount in cents 
	@amount = 500
	customer = Stripe::Customer.create(
	  :email => 'customer@example.com',
	  :source  => params[:stripeToken]
	)
  
	charge = Stripe::Charge.create(
	  :amount      => @amount,
	  :description => 'Sinatra Charge',
	  :currency    => 'usd',
	  :customer    => customer.id
	)
	current_user.type = 1
	current_user.save
	redirect "my_library"
end

get "/new" do
	erb :"videos/new"
end
post "/create" do
	authenticate!
	if current_user.getLibrary().videoCap?()
		redirect "my_library"
	else
		newVid = Video.new
		newVid.library_id = current_user.getLibrary().id
		newVid.title = params['title'] if params['title']
		newVid.video_url = params['video_url'] if params['video_url']
		newVid.save
		redirect "my_library"
	end
end