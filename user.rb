require 'data_mapper' # metagem, requires common plugins too.

class User
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :password, String
    property :created_at, DateTime
    property :pro, Boolean, :default=>false
    property :administrator, Boolean, :default => false

    def login(password)
    	return self.password == password
    end
end

