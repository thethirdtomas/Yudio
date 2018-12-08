require "sinatra"
require "stripe"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "validation.rb"


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