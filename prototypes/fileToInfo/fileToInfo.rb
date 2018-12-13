require "openssl"
require 'base64'
require 'net/http/post/multipart'

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

file_name = File.dirname(__FILE__) + "./testSong.mp3"
sample_bytes = File.size(file_name)

puts File.exist?(file_name)

url = URI.parse(requrl)
File.open(file_name) do |file|
  req = Net::HTTP::Post::Multipart.new url.path,
    "sample" => UploadIO.new(file, "audio/mp3", file_name),
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