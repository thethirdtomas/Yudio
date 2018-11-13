require 'data_mapper' # metagem, requires common plugins too.

class Video
	include DataMapper::Resource

	property :id, Serial
    #fill in the rest
    property :title, String
    property :description, String
    property :video_url, String
    property :pro, Boolean, :default=>false
end