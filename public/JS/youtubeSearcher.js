//-------------------------------------------------------JQUERY ABOVE-------------------------------------------------------

$(document).ready(function() {
    songName = $("#songName")
    albumName = $("#albumName")
    artistName = $("#artistName")

    function linkUpdaters(textField){
        $(textField).focusout(function() {
            $.ajax({
                method: "POST",
                url: "/getURL",
                data: {
                    "song" : $(songName).val(), 
                    "album" : $(albumName).val(),
                    "artist" : $(artistName).val(),
                },
                success: function (response) {
                    response = JSON.parse(response)
                    url = "https://www.youtube.com/watch?v=" + response[0]['id']
                    $("#urlLocation").val(url)
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