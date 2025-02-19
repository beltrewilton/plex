export default VideoPlayer = {
    mounted() { 
        const videoElement = this.el
        const video_path =  this.el.dataset.video
        // "https://audio.synaia.io/stream/video/442392808948818-18494589977-CNYE6FR4AM4D-end_of_task.mp4"
        const sourceElement = videoElement.querySelector("source")
        // sourceElement.src = video_path
        
        const token = "your_valid_token";

        // Fetch video file with authorization if necessary
        fetch(video_path, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.blob();
        })
        .then(blob => {
            const url = URL.createObjectURL(blob);
            sourceElement.src = url;
            videoElement.load();
        })
        .catch(error => {
            console.error('There was a problem with the fetch operation:', error);
        });

        // return () => {
        //     waveSurfer.destroy()
        //     this.playButton.el.removeEventListener("click", clickPlay)
        // };

    }
}