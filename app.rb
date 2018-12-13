require "sinatra"
require "stripe"
require 'sinatra/flash'
require 'json'
require 'lyricfy'

require "openssl"
require 'base64'
require 'net/http/post/multipart'

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

post "/downloadFile" do
	# grab the params
	audioBlob = params[:audioBlob]
	savedBlob = params[:savedBlob]
	audioUrl = params[:audioUrl]
	blobName = params[:blobName]

	# get or create save path
	save_path = "public/audio/" 
	unless File.exists?(save_path)
		Dir::mkdir(save_path)
	end
	file_name = save_path + blobName

	# mime type "ogg" REQUIRED
	audio_data = Base64.decode64(savedBlob['data:audio/ogg; base64,'.length .. -1])
	File.open(file_name, 'wb') do |f| 
		f.write audio_data
	end

	# process the file

	# Json format link below
	# https://www.acrcloud.com/docs/acrcloud/metadata/music/

	# Info Taken From Bryan Cancel's ARCCloud Account
	requrl = "http://identify-us-west-2.acrcloud.com/v1/identify"
	access_key = "ed66b9b729dceb1347def34575b815ef"
	access_secret = "NC6mUBMa2YrLUSzU7Y61QIulkh6EpB575LRkCRKp"

	http_method = "POST"
	http_uri = "/v1/identify"
	data_type = "audio"
	signature_version = "1"
	timestamp = Time.now.utc().to_i.to_s

	string_to_sign = http_method+"\n"+http_uri+"\n"+access_key+"\n"+data_type+"\n"+signature_version+"\n"+timestamp

	digest = OpenSSL::Digest.new('sha1')
	signature = Base64.encode64(OpenSSL::HMAC.digest(digest, access_secret, string_to_sign))

	file_name = "./" + file_name
	sample_bytes = File.size(file_name)

	url = URI.parse(requrl)
	File.open(file_name) do |file|
	req = Net::HTTP::Post::Multipart.new url.path,
		"sample" => UploadIO.new(file, "audio/ogg", file_name),
		"access_key" =>access_key,
		"data_type"=> data_type,
		"signature_version"=> signature_version,
		"signature"=>signature,
		"sample_bytes"=>sample_bytes,
		"timestamp" => timestamp
		res = Net::HTTP.start(url.host, url.port) do |http|
			http.request(req)
		end
		puts(res.body)
	end

	return "hi"
end

# define function to easily generate a query string based on params
def makeQueryString song, album, artist
	string = ""
	string += "\"" + song + "\"" if(song.nil? == false) 
	string += " from " if(song.nil? == false && album.nil? == false) 
	string += "\"" + album + "\"" if(album.nil? == false) 
	string +=" by " if((song.nil? == false && artist.nil? == false) || (album.nil? == false && artist.nil? == false)) 
	string += "\"" + artist + "\"" if(artist.nil? == false) 
	return string
end

post "/getLyrics" do
	# grab the params
	songName = params[:song]
	albumName = params[:album]
	artistName = params[:artist]

	# search for lyrics depending on avail params
	if(artistName != "" && songName != "")
		# setup for search
		fetcher = Lyricfy::Fetcher.new

		# perform the search
		puts "-------------------------lyric fetch start"
		song = fetcher.search(artistName, songName)
		puts "-------------------------lyric fetch end"

		# inform the client
		if(song.nil?)
			return 'Lyrics for ' + makeQueryString(songName, albumName, artistName) + ' Not Found'
		else
			return song.body
		end
	else
		return 'In order to find the lyrics for ' + makeQueryString(songName, albumName, artistName) + ' (1) Artist Name AND (2) Song Name are required'
	end
end

post "/getURL" do
	# grab the params
	song = params[:song]
	album = params[:album]
	artist = params[:artist]
	
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