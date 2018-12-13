$(document).ready(function() {
    songName = $("#songName")
    albumName = $("#albumName")
    artistName = $("#artistName")

    function linkUpdaters(textField){
        //generate youtube link
        $(textField).focusout(function() {
            console.log("url")
            $.ajax({
                method: "POST",
                url: "/getURL",
                data: {
                    "song" : $(songName).val(), 
                    "album" : $(albumName).val(),
                    "artist" : $(artistName).val()
                },
                success: function (response) {
                    response = JSON.parse(response)
                    url = "https://www.youtube.com/watch?v=" + response[0]['id']
                    $("#urlLocation").val(url)
                }
            });
        })

        //display lyrics
        $(textField).focusout(function() {
            console.log("lyric")
            $.ajax({
                method: "POST",
                url: "/getLyrics",
                data: {
                    "song" : $(songName).val(),
                    "album" : $(albumName).val(),
                    "artist" : $(artistName).val()
                },
                success: function (response) {
                    $("#lyricTitle").show()
                    /*
                    response =  response.replace(/\n/g, "-----")
                    console.log(response)
                    */
                    $("#lyricsArea").html(response)
                }
            });
        })
    }

    linkUpdaters(songName)
    linkUpdaters(albumName)
    linkUpdaters(artistName)

    recordAudio = $("#recordAudio")
    recording = false

    $(recordAudio).on("click", function(){
        console.log("recording " + recording)
        start = "fa-microphone"
        stop = "fa-microphone-slash"
        $(this).find("i").removeClass(((recording) ? stop : start))
        $(this).find("i").addClass(((recording) ? start : stop))
        recording = !recording
    })
});