require 'lyricfy'

fetcher = Lyricfy::Fetcher.new
song = fetcher.search 'Coldplay', 'Viva la vida'
puts song.body # prints lyrics separated by '\n'
puts lyrics.body("<br>")