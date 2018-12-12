# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
ENV['SSL_CERT_FILE'] = './cacert.pem'
require 'net/http'
require 'uri'
require 'json'
require 'httparty'

# youtube data public key from Bryan Cancel's Google Developer Console
# AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8
key = "AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8"

# youtube list parameters link below
# https://developers.google.com/youtube/v3/docs/videos/list

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
query = makeQueryString "24 karot gold", "24K Magic", "Bruno Mars"
relevanceLanguage = "en"
safeSearch = "none"
type = "video"

# print query
puts "searching " + query

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

# print the important parts of this json file
videos.each{ |video|
    puts("\n")
    puts("video id: =>" + video["id"]["videoId"] + "\n")
    puts("video title =>" + video["snippet"]["title"] + "\n")
    puts("video description =>" + video["snippet"]["description"] + "\n")
    puts("thumb nails =>" + video["snippet"]["thumbnails"].to_json + "\n")
}