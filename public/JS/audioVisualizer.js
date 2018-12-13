$( document ).ready(function() {
    //mappings known from ARCCloud API
    var errorCodeToError = {
        "1001" : `Sorry, we could not 
                <br> recognize the song`,
        "2000" : `Sorry, we could not 
                <br> record, the recording 
                <br> device might not have 
                <br> the required permissions`,
        "3000" : `Sorry, the recognizer broke`,
        "2005" : `Sorry, the search timed out`,
        "2004" : `Sorry, we were not able to 
                <br> generate the song's fingerprint`,
        "2002" : `Sorry, there was a parsing error`
    }

    //variables that will let us save recorded audio
    var userMedia = ""
    var mediaRecorder = ""
    var audioChunks = []

    //variables for audio visualizer
    "use strict";
    var paths = document.getElementsByTagName('path');
    var visualizer = document.getElementById('visualizer');
    var mask = visualizer.getElementById('mask');
    var h = document.getElementsByTagName('h1')[0];
    var path;
    var report = 0;
    
    var soundDesired = function (stream) {
        //Audio stops listening in FF without // window.persistAudioStream = stream;
        //https://bugzilla.mozilla.org/show_bug.cgi?id=965483
        //https://support.mozilla.org/en-US/questions/984179
        window.persistAudioStream = stream;
        var audioContent = new AudioContext();
        var audioStream = audioContent.createMediaStreamSource( stream );
        var analyser = audioContent.createAnalyser();
        audioStream.connect(analyser);
        analyser.fftSize = 1024;

        var frequencyArray = new Uint8Array(analyser.frequencyBinCount);
        visualizer.setAttribute('viewBox', '0 0 255 255');
      
        //Through the frequencyArray has a length longer than 255, there seems to be no
        //significant data after this point. Not worth visualizing.
        for (var i = 0 ; i < 255; i++) {
            path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('stroke-dasharray', '4,1');
            mask.appendChild(path);
        }
        var doDraw = function () {
            requestAnimationFrame(doDraw);
            analyser.getByteFrequencyData(frequencyArray);
          	var adjustedLength;
            for (var i = 0 ; i < 255; i++) {
              	adjustedLength = Math.floor(frequencyArray[i]) - (Math.floor(frequencyArray[i]) % 5);
                paths[i].setAttribute('d', 'M '+ (i) +',255 l 0,-' + adjustedLength);
            }

        }
        doDraw();
    }

    var soundNotAllowed = function (error) {
        h.innerHTML = "You must allow your microphone.";
        console.log(error);
    }

    /*window.navigator = window.navigator || {};
    /*navigator.getUserMedia =  navigator.getUserMedia       ||
                              navigator.webkitGetUserMedia ||
                              navigator.mozGetUserMedia    ||
                              null;*/
    navigator.getUserMedia({audio:true}, soundDesired, soundNotAllowed)

    navigator.mediaDevices.getUserMedia({audio:true}).then((stream) => {
        //create a recorder that is available for manuipulation
        mediaRecorder = new MediaRecorder(stream)

        mediaRecorder.ondataavailable = function (event){
            audioChunks.push(event.data)
        }
    })

    var recordAudio = $("#recordAudio")
    var recording = false
    var micLocked = false

    function micSwitch(){
        var start = "fa-microphone"
        var stop = "fa-stop-circle"
        $(recordAudio).find("i").removeClass(((recording) ? stop : start))
        $(recordAudio).find("i").addClass(((recording) ? start : stop))
        recording = !recording

        //hide all errors
        $("#songIdentifierError").hide()

        //start recording
        if(recording) mediaRecorder.start()
        else{ //stop recording
            mediaRecorder.stop()

            //use time with a wait of 0 simply to allow stop to finish before running
            //this way we are guaranteeed to grab our audioChunk
            setTimeout(function(){ 
                //audio chunk conversion
                const audioBlob = new Blob(audioChunks, {type: "audio/webm"}) //mime type: "audio/webm" REQUIRED
                var savedBlob = ""
                const audioUrl = (window.URL || window.webkitURL).createObjectURL(audioBlob)

                //create file reader
                var reader  = new FileReader()
                //read blob as something else [EXPERIMENT]
                reader.readAsDataURL(audioBlob) //param of type "blob" AND use of "readAsDataURL" REQUIRED
                //run this function after file read complete
                reader.onloadend = function() {
                    savedBlob = reader.result

                    //send data as form data (you can send audioBlobs any other way)
                    var data = new FormData();
                    data.append('audioBlob', audioBlob)
                    data.append('savedBlob', savedBlob)
                    data.append('audioUrl', audioUrl)
                    data.append('blobName', (new Date()).getTime() + ".ogg") //extension ".ogg" REQUIRED

                    //run the ajax call to download the file to the server
                    $.ajax({
                        url: "/downloadFile",
                        type: 'POST',
                        data: data,
                        contentType: false,
                        processData: false,
                        success: function (response) {
                            //error code documentation
                            //https://www.acrcloud.com/docs/acrcloud/metadata/error-codes/

                            //json file documentation
                            //https://www.acrcloud.com/docs/acrcloud/metadata/music-acrbm/

                            response = JSON.parse(response)

                            retreivedError = response['status']['code']
                            if(retreivedError == "0"){
                                //hide potentially visible errors
                                $("#songIdentifierError").hide()

                                //grab all data from json
                                retreivedSongName = response['metadata']['music'][0]['title']
                                retreivedAlbumName = response['metadata']['music'][0]['album']['name']
                                //only grab main artist
                                retreivedArtistsNames = response['metadata']['music'][0]['artists'][0]['name']

                                /*
                                //code to grab all artists
                                var len = (response['metadata']['music'][0]['artists']).length
                                var index
                                for(index = 0; index < len; index++){
                                    var artist = response['metadata']['music'][0]['artists'][index]['name']
                                    if(index == 0) retreivedArtistsNames += artist
                                    else retreivedArtistsNames += " and " + artist
                                }
                                */

                                //set the field
                                $("#songName").val(retreivedSongName)
                                $("#albumName").val(retreivedAlbumName)
                                $("#artistName").val(retreivedArtistsNames)

                                //trick the other js file to run its scripts
                                $("#artistName").select()
                                $("#artistName").blur()
                            }
                            else{
                                //make sure errors are visible
                                $("#songIdentifierError").show()
                                $("#songIdentifierError").html(errorCodeToError[retreivedError])
                            }
                        }
                    });
                }
            }, 0);
        }
    }

    function micIndicator(isProcessing){
        icon = $("#audioRecognizerLoading").find("i")
        if(isProcessing){
            $(icon).addClass("fa-refresh")
            $(icon).addClass("fa-spin")
            $(icon).addClass("fa")
            $(icon).removeClass("fas")
            $(icon).removeClass("fa-check")
        }
        else{
            $(icon).removeClass("fa-refresh")
            $(icon).removeClass("fa-spin")
            $(icon).removeClass("fa")
            $(icon).addClass("fas")
            $(icon).addClass("fa-check")
        }
    }

    $(recordAudio).on("click", function(){
        console.log("recording " + recording)
        if(recording == false){
            //lock the mic for X seconds
            micLocked = true

            //tell user their recording is now processing
            micIndicator(true)

            //start the recording
            micSwitch()

            //automatically show a message if the user stop the mic within x milliseconds
            var millisecondsBeforeUnlock = 7000 //7 seconds
            setTimeout(function(){ 
                if(recording){
                    //unlock the mic
                    micLocked = false
                    
                    //tell user they can stop the recording
                    micIndicator(false)
                }
            }, millisecondsBeforeUnlock)

            //automaticaly stop the mic after x milliseconds (at this point the larger file gives no benefits)
            var millisecondsBeforeAutoStop = 20000 //20 seconds
            setTimeout(function(){ 
                if(recording){
                    //automatically stop the mic
                    micSwitch()
                }
            }, millisecondsBeforeAutoStop)
        }
        else{ //DONT allow users to stop the recording since it needs to record for atleast 15 seconds
            if(micLocked) alert("We need atleast 7 seconds to identify the song")
            micSwitch()
        }
    })
})