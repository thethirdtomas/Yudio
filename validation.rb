
def valid_url(url)
    yt_url = "youtube.com"
    return url.include? yt_url
end

def get_video_id(url)
    index = 0
    for x in 0..url.length
        if url[x] == '?'
            index = x
            break
        end
    end
    index += 3
    return url[index, index+11]
end