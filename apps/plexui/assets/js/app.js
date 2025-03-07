// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import AudioPlayer from "./audio_player"
import HalfGauge from "./half_gauge"
import LetterGauge from "./letter_gauge"
import ScoreGauge from "./score_gauge"
import ProgressBar from "./progresss_bar"
import VideoPlayer from "./video_player"
import ControlPlay from "./control_play"
import ScrollInto from "./scroll_into_video"
import ClosePopup from "./close_popup_window"
import DataPicker from "./date_picker"

let hooks = {}
hooks.AudioPlayer = AudioPlayer
hooks.HalfGauge = HalfGauge
hooks.LetterGauge = LetterGauge
hooks.ScoreGauge = ScoreGauge
hooks.ProgressBar = ProgressBar
hooks.VideoPlayer = VideoPlayer
hooks.ControlPlay = ControlPlay
hooks.ScrollInto = ScrollInto
hooks.ClosePopup = ClosePopup
hooks.DataPicker = DataPicker


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

