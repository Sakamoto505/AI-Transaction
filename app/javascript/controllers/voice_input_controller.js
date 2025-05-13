import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'startButton', 'stopButton', 'breakButton']

  static values = {
    lang: { type: String, default: 'ru-RU' }
  }

  connect() {
    console.log("VoiceInputController connected");
    this.#initializeRecognition()
  }

  startRecording() {
    console.log("startRecording called");
    if (this.recognition) {
      this.recognition.start()
      this.#toggleRecordingButtons(true)
    } else {
      console.error("SpeechRecognition not supported");
    }
  }

  endRecording() {
    if (this.recognition) {
      this.recognition.stop()
      this.#toggleRecordingButtons(false)
      if (this.inputTarget.value.trim() !== '') {
        this.#autoSubmit()
      }
    }
  }

  breakRecording() {
    if (this.recognition) {
      this.recognition.stop()
      this.#toggleRecordingButtons(false)
      this.clearInput()
    }
  }

  clearInput() {
    this.inputTarget.value = ''
  }

  #autoSubmit() {
    this.inputTarget.closest('form').requestSubmit()
  }

  #initializeRecognition() {
    this.recognition = null

    if ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window) {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      this.recognition = new SpeechRecognition()
      this.recognition.lang = this.langValue
      this.recognition.continuous = true
      this.recognition.interimResults = true

      this.recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript
        this.inputTarget.value = transcript
      }

      this.recognition.onerror = (event) => {
        console.error("SpeechRecognition error:", event.error);
      }
    } else {
      console.error("SpeechRecognition not supported in this browser");
    }
  }

  #toggleRecordingButtons(isRecording) {
    if (isRecording) {
      this.startButtonTarget.classList.add('hidden')
      this.stopButtonTarget.classList.remove('hidden')
      this.breakButtonTarget.classList.remove('hidden')
    } else {
      this.startButtonTarget.classList.remove('hidden')
      this.stopButtonTarget.classList.add('hidden')
      this.breakButtonTarget.classList.add('hidden')
    }
  }
}