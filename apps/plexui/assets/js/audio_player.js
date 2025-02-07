import WaveSurfer from 'wavesurfer.js'

export default AudioPlayer = {
    mounted() { 
        const playButton = this.el
        const audio_path = this.el.dataset.audiopath
        const container = this.el.dataset.container
        const progressColor = this.el.dataset.progresscolor
        const audioContainer = document.getElementById(container)
        //TODO: binds html elements. see odoo module.!

        const waveSurfer = WaveSurfer.create({
            container: audioContainer,
            height: 70,
            waveColor: '#ECF2FF',
            progressColor: progressColor,
            barWidth: 5,
            barGap: 2,
            barRadius: 10,
            cursorColor: '#787186',
            cursorWidth: 1,
            responsive: true,
            // plugins: [TimelinePlugin.create({
            //   height: 17,
            // })],
        });
        // waveSurfer.load(audio_path);

        const token = "your_valid_token"; 

        fetch(audio_path, {
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
            waveSurfer.load(url);
        })
        .catch(error => {
            console.error('There was a problem with the fetch operation:', error);
        });

        const clickPlay = (el) => {
            waveSurfer.playPause();
            el.target.innerHTML = waveSurfer.isPlaying() ? "Pause" : "Play";
        }

        waveSurfer.on('ready', () => {
            console.log(waveSurfer)
        });

        const dummy = (el) => {
            alert("You clicked.")
        }

        playButton.addEventListener("click", clickPlay)

        // return () => {
        //     waveSurfer.destroy()
        //     this.playButton.el.removeEventListener("click", clickPlay)
        // };

    }
}