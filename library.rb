require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
# if on heroku, use Postgres database
# if not use sqlite3 database I gave you
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class Library
    include DataMapper::Resource
    property :id, Serial
    property :user_id, Integer
    property :created_at, DateTime
    def getVideos()
      @videos = Video.all(:library_id => self.id)
      return @videos
    end

    def videoCount()
      return self.getVideos().count()
    end

    def videoCap?()
      userType = User.get(self.user_id).type
      #If the User is Free and they have 5 videos stored, they have reached their cap.
      #Return true if cap is reached.
      return (userType == 0 && self.videoCount() == 5)
    end
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Library.auto_upgrade!

