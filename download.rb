require 'youtube-dl'


def download_mp3(url)
    filename = "#{10000 + Random.rand(90000)}.mp4"
    YoutubeDL.download url, output: "public/music/#{filename}"
    send_file "public/music/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end