import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // ESCキーでモーダルを閉じる
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  open() {
    this.modalTarget.classList.remove("hidden")
    // overflow-hiddenを削除してスクロールバーのズレを防ぐ
    // document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    // document.body.classList.remove("overflow-hidden")
  }

  // 背景クリックで閉じる
  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  // ESCキーで閉じる
  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}