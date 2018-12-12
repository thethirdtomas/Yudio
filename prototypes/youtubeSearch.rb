# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
ENV['SSL_CERT_FILE'] = './cacert.pem'
require 'net/http'
require 'uri'
require 'json'
require 'httparty'

url = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8&maxResults=3&order=relevance&part=snippet&q=24+karot+gold+by+bruno+mars&relevanceLanguage=en&safeSearch=none&type=video"

uir = URI(url)
response = Net::HTTP.get(url)
puts JSON.parse(response)

=begin
response = HTTParty.get(url)
puts response.parsed_response
=end

=begin
uri = URI.parse("https://www.googleapis.com/youtube/v3/search?key=AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8&maxResults=3&order=relevance&part=snippet&q=24+karot+gold+by+bruno+mars&relevanceLanguage=en&safeSearch=none&type=video")
request = Net::HTTP::Get.new(uri)
request["Content-Length"] = "0"
request["User-Agent"] = "Yt::Request (gzip)"

req_options = {
  use_ssl: uri.scheme == "https",
}
# puts(request)
puts(JSON.parse(request))

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts(response)
puts(JSON.parse(response))
=end

=begin
Yt.configure do |config|
	config.api_key = 'AIzaSyBveT5vyHDYjHAyiVMbAa19l5HSoPQEdM8'
	config.log_level = :debug
end

videos = Yt::Collections::Videos.new

videoList = videos.where(
	q: '24 karot gold by bruno mars',
	max_results: '3',
	order: 'relevance',
	relevanceLanguage: 'en',
	safeSearch: 'none',
	type: 'video',
	part: 'snippet',
)

youtubeLinkBase = "https://www.youtube.com/watch?v="
# from id get videoId (Ex: 8s9PhFW1ow8)

# get the above from returned json file

puts("done start")

videoList.each do |x|
    puts("d")
end
=end
puts("done end")