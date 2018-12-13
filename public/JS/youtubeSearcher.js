$(document).ready(function() {
    songName = $("#songName")
    albumName = $("#albumName")
    artistName = $("#artistName")

    function makeQueryString(song, album, artist){
        string = ""
        if(song != "") string += "\"" + song + "\""
        if(song != "" && album != "") string += " from "
        if(album != "") string += "\"" + album + "\""
        if((song != "" && artist != "") || (album != "" && artist !="" )) string +=" by "
        if(artist != "") string += "\"" + artist + "\""
        return string
    }

    function runLyricSearch(){
        //show lyrics section
        $("#lyricContainer").show()

        //grab data (if nothing then == "")
        song = $(songName).val()
        album = $(albumName).val()
        artist = $(artistName).val()

        //output result
        if(song != "" && artist != ""){
            console.log("searching for lyrics") //For "is it still working?" checks

            //show loading... eventually we will flip this below...
            $("#lyricsLoading").show()
            $("#lyricsLoaded").hide()

            $.ajax({
                method: "POST",
                url: "/getLyrics",
                data: {
                    "song" : song,
                    "album" : album,
                    "artist" : artist
                },
                success: function (lyrics) {
                    console.log("lyric search complete successfully") //For "is it still working?" checks

                    //create message
                    //replace new line characters for the new line character of html "<br>"
                    var regex = /\\n/gi
                    lyrics = lyrics.replace(regex, "<br>")

                    //show loaded
                    $("#lyricsLoading").hide()
                    $("#lyricsLoaded").show()

                    //display message
                    $("#lyricsLoaded").html(lyrics)
                },
                error: function (jqXHR, textStatus, errorThrown) { 
                    console.log("lyric search complete un-successfully") //For "is it still working?" checks

                    //create message
                    var message = 'Lyrics for ' + makeQueryString(song, album, artist) + ' Not Found'
                    + '<br>' + "The song might be to new"
                    + '<br>' + "Song Lyrics are retreived from MetroLyrics"
                    + '<br>' + "Make sure the song lyrics are available there"
                    + '<br>' + "If they are, make sure your spelling is correct"

                    //show loaded
                    $("#lyricsLoading").hide()
                    $("#lyricsLoaded").show()

                    //display message
                    $("#lyricsLoaded").html(message)
                }
            })
        }
        else{
            //show as loaded
            $("#lyricsLoading").hide()
            $("#lyricsLoaded").show()

            //show lyrics in html
            $("#lyricsLoaded").html('In order to find the lyrics for ' + makeQueryString(song, album, artist) + ' (1) Artist Name AND (2) Song Name are required')
        }
    }

    function linkUpdaters(textField){
        //generate youtube link
        $(textField).focusout(function() {
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
                    /*
                    youtube search tips
                    --- + and – symbols respectively
                    --- exactly match by placing things in quotations
                    --- Use ‘intitle’ to find keywords in video title
                    */
                    url = "https://www.youtube.com/watch?v=" + response[0]['id']
                    $("#urlLocation").val(url)
                }
            });
        })

        //display lyrics
        $(textField).focusout(function() {
            runLyricSearch()
        })
    }

    linkUpdaters(songName)
    linkUpdaters(albumName)
    linkUpdaters(artistName)

    $("#lyricSearchButton").on("click", function(event){
        event.preventDefault();
        runLyricSearch()
    })
})