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
})

/*
//hide lyrics of previous query
//we do this because searching for lyrics takes a while
$("#lyricContainer").hide()

console.log("searching for lyrics")

lyrics = `I used to rule the world\nSeas would rise when I gave the word\nNow in the morning I sleep alone\nSweep the streets I used to own\nI used to roll the dice\nFeel the fear in my enemy's eyes\nListen as the crowd would sing\n"Now the old king is dead! Long live the king!"\nOne minute I held the key\nNext the walls were closed on me\nAnd I discovered that my castles stand\nUpon pillars of salt and pillars of sand\nI hear Jerusalem bells a-ringing\nRoman Cavalry choirs are singing\nBe my mirror, my sword and shield\nMy missionaries in a foreign field\nFor some reason I can't explain\nOnce you'd gone there was never\nNever an honest word\nAnd that was when I ruled the world\nIt was the wicked and wild wind\nBlew down the doors to let me in\nShattered windows and the sound of drums\nPeople couldn't believe what I'd become\nRevolutionaries wait\nFor my head on a silver plate\nJust a puppet on a lonely string\nOh who would ever want to be king?\nI hear Jerusalem bells a-ringing\nRoman cavalry choirs are singing\nBe my mirror, my sword and shield\nMy missionaries in a foreign field\nFor some reason I can't explain\nI know Saint Peter won't call my name\nNever an honest word\nBut that was when I ruled the world\nI hear Jerusalem bells a-ringing\nRoman cavalry choirs are singing\nBe my mirror, my sword and shield\nMy missionaries in a foreign field\nFor some reason I can't explain\nI know Saint Peter won't call my name\nNever an honest word\nBut that was when I ruled the world`
lyrics = lyrics.replace(/(\r\n\t|\n|\r\t)/gm,"<br>");

//show the lyrics area
$("#lyricContainer").show()

//set html so that it read <br> tags between lyric lines
$("#lyricsArea").html(lyrics)
*/