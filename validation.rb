
def valid_url(url)
    yt_url = "https://www.youtube.com/watch?v="
    return url.include? yt_url
end