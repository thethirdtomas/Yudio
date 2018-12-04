require 'sinatra'
require_relative "user.rb"
require_relative "library.rb"

enable :sessions

set :session_secret, 'super secret'

get "/login" do
	erb :"authentication/login"
end


post "/process_login" do
	email = params[:email]
	password = params[:password]

	user = User.first(email: email.downcase)

	if(user && user.login(password))
		session[:user_id] = user.id
		redirect "/"
	else
		flash[:error] = "Invalid username or password"
		redirect "/login"
	end
end

get "/logout" do
	session[:user_id] = nil
	redirect "/"
end

get "/create_account" do
	erb :"authentication/create_account"
end


post "/register" do
	name = params[:name]
	email = params[:email]
	password = params[:password]

	u = User.new
	u.name = name
	u.email = email.downcase
	u.password =  password
	u.save

	session[:user_id] = u.id

	lib = Library.new
	lib.user_id = u.id
	lib.save
	erb :"authentication/successful_signup"

end

#This method will return the user object of the currently signed in user
#Returns nil if not signed in
def current_user
	if(session[:user_id])
		@u ||= User.first(id: session[:user_id])
		return @u
	else
		return nil
	end
end

#if the user is not signed in, will redirect to login page
def authenticate!
	if !current_user
		redirect "/login"
	end
end