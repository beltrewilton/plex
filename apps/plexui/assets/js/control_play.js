// speech-non-scripted-id
export default ControlPlay = {
    mounted() {
        let speechNonscriptedBtn = this.el
        speechNonscriptedBtn.addEventListener("click", () => {
            const speechNonscriptedDiv = document.getElementById("speech-non-scripted-id")
            const speechscriptedDiv = document.getElementById("speech-scripted-id")
            if (this.el.id == "tab-one") {
                speechNonscriptedDiv.classList.remove("hidden")
                speechscriptedDiv.classList.add("hidden")
            } else {
                speechscriptedDiv.classList.remove("hidden")
                speechNonscriptedDiv.classList.add("hidden")
            }
        })
    }
}