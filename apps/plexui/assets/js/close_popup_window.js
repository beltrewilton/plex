export default ClosePopup = {
    mounted() { 
        this.el.addEventListener("click", () => { window.close() })
    }
}