// scrollIntoView({ behavior: 'smooth' })
export default ScrollInto = {
    mounted() {
        const el = this.el
        el.addEventListener("click", () => {
            el.scrollIntoView({ behavior: 'smooth' })
        })
    }
}