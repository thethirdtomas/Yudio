require "sinatra"
require_relative "authentication.rb"
#require 'capybara/poltergeist'
require "stripe"
#Capybara.javascript_driver = :poltergeist

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

DataMapper.finalize
User.auto_upgrade!
Video.auto_upgrade!

#make an admin user if one doesn't exist!
if User.all(administrator: true).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.administrator = true
	u.save
end

#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

get "/videos" do
	authenticate!
	(current_user.pro || current_user.administrator) ? @Videos=Video.all : @Videos=Video.all(:pro => false)
	erb :videos
end

get "/videos/new" do
	admin!
	erb :"/videos/new"
end

post "/videos/create" do
	admin!
	if(params["title"] && params["description"] && params["video_url"])
		newVid = Video.new
		newVid.title = params["title"]
		newVid.description = params["description"]
		newVid.video_url = params["video_url"]
		newVid.pro = true if params["pro"]=="on"
		newVid.save
		redirect "/videos"
	else
		return "Invalid Paramaters"
	end
end

get "/upgrade" do 
	authenticate!
	if current_user && (!current_user.pro && !current_user.administrator)
		erb :upgrade
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
	current_user.pro = true
	current_user.save
	erb :charge
  end
