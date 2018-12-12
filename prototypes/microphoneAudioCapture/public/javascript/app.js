//TODO... check if it makes a difference to select the mic of a "groupId"... and not just "deviceId"


$( document ).ready(function() {

    audioDevices = []
    mediaRecorder = ""
    audioChunks = []

    //Output details before allowing the user to start recording
    if (!!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia) == false) {
        $("#notrecording").text("Our App Doesn't work from this browser :(")
    } else {
        navigator.mediaDevices.enumerateDevices().then(gotDevices)
    
        function gotDevices(deviceInfos) {
            //iterate through all our audio and video devices
            for (var i = 0; i < deviceInfos.length; i++) {
                deviceInfo = deviceInfos[i]
                if(deviceInfo.kind == 'audioinput'){
                    audioDevices.push(deviceInfo)
                }
            }
    
            //display microphone message
            if(audioDevices.length == 0){
                $("#notrecording").text("No Microphone Detected")
            }
            else if(audioDevices.length == 1){
                $("#notrecording").text("Using the Only Microphone detected " + audioDevices[0].deviceId + " : " + audioDevices[0].label)
            }
            else{
                //create select tag
                $("#notrecording").text("Multiple Microphones detected, one selected\n")
                $("#notrecording").append(`<br>`)
                $("#notrecording").append(`<label for="audioSource">Audio source: </label><select id="audioSource"></select>`)

                //create a function that keep track of what mic is selected
                $("#notrecording > select").change(function() {
                    selectNewDevice($(this).val());
                });

                //add in the selection options
                for(i = 0; i < audioDevices.length; i++){
                    audioDevice = audioDevices[i]
                    option = document.createElement('option');
                    option.value = i
                    option.text = "groupID: " + audioDevice.groupId + " deviceID: " + audioDevice.deviceId + " deviceLabel: " + audioDevice.label || 'unlabeled'
                    $("#notrecording > select").append(option)
                }

                //select default device
                selectNewDevice(0)
            }
        }
    }
    
    function report(){
        saveRecording()
    }

    function selectNewDevice(index){
        var constraints = {
            audio: {
                deviceId: {exact: audioDevices[index].deviceId}
            }
        };

        navigator.mediaDevices.getUserMedia(constraints)
        .then((stream) => {
            //create a recorder that is available for manuipulation
            mediaRecorder = new MediaRecorder(stream)

            mediaRecorder.ondataavailable = function (event){
                audioChunks.push(event.data)
            }
        })
    }

    function startRecording(){
        mediaRecorder.start()
    }

    function stopRecording(){
        mediaRecorder.stop()
    }

    function saveRecording(){
        //pause the recording
        /*
        paused = false
        if(mediaRecorder.state == "recording"){
            mediaRecorder.pause()
            paused = true
        }
        */
        mediaRecorder.pause()

        //audio chunk conversion
        const audioBlob = new Blob(audioChunks, { type: 'audio/mpeg' })
        const audioUrl = URL.createObjectURL(audioBlob)
        const audio = new Audio(audioUrl)

        console.log(audioUrl)

        //link hacking to save the file
        var a = document.createElement('a')
        document.body.appendChild(a)
        a.style = 'display: none'
        a.href = audioUrl
        a.download = 'test.mp3'
        a.click()
        a.remove()

        //resume the recording
        /*
        if(paused){
            mediaRecorder.resume()
        }
        */
    }

    $( "#record" ).click(function() {
        if(mediaRecorder.state == "inactive"){
            startRecording()
            $("#record").text("Stop")
        }
        else{
            stopRecording()
            $("#record").text("Start")
        }
    })

    $( "#save" ).click(function() {
        saveRecording()
    })

})