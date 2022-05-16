import SwiftUI
import KeyboardShortcuts

struct MainView: View {
	
	// @StateObject var appState: AppState
	
	@State var showSettings = false
	@State var presentation = Presentation()
	@State var currentSlide = Slide()
	@State var fullScreen = false
	@State var slideNr = -1
	
	//init() {
	//	_appState = StateObject(wrappedValue: AppState())
	//}
	
	var body: some View {
		HStack {
			if slideNr == -1 {
				Text("Let's get started!")
			} else {
				SlideView(
					slideNr: slideNr,
					slideCount: presentation.slides.count,
					currentSlide: $currentSlide
				)
			}
		}
		.sheet(isPresented: $showSettings) {
			SettingsScreen() {
				showSettings.toggle()
			}
		}
		.onAppear {
			KeyboardShortcuts.onKeyDown(for: .toggleFullscreen) {
				if let window = NSApplication.shared.windows.first {
					window.toggleFullScreen(nil)
				}
			}
			KeyboardShortcuts.onKeyDown(for: .simpleAdvanceSlide) {
				if slideNr < presentation.slides.count - 1 {
					if slideNr >= 0 { presentation.slides[slideNr] = currentSlide }
					slideNr += 1
					currentSlide = presentation.slides[slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .nextSlide) {
				if slideNr < presentation.slides.count - 1 {
					if slideNr >= 0 { presentation.slides[slideNr] = currentSlide }
					slideNr += 1
					currentSlide = presentation.slides[slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .previousSlide) {
				if slideNr > 0 {
					presentation.slides[slideNr] = currentSlide
					slideNr -= 1
					currentSlide = presentation.slides[slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .addNewSlide) {
				if slideNr >= 0 { presentation.slides[slideNr] = currentSlide }
				slideNr += 1
				currentSlide = Slide()
				presentation.slides.insert(currentSlide, at: slideNr)
			}
			KeyboardShortcuts.onKeyDown(for: .deleteCurrentSlide) {
				if presentation.slides.isEmpty == false {
					presentation.slides.remove(at: slideNr)
					if slideNr >= presentation.slides.count { slideNr -= 1 }
					if presentation.slides.isEmpty {
						slideNr = -1
						currentSlide = Slide()
					} else {
						currentSlide = presentation.slides[slideNr]
					}
				}
			}
			KeyboardShortcuts.onKeyDown(for: .selectTitleField) {
				NSNotification.post("select-title")
			}
			KeyboardShortcuts.onKeyDown(for: .selectContentField) {
				NSNotification.post("select-content")
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromLeft) {
				NSNotification.post("screen", 4)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromRight) {
				NSNotification.post("screen", 6)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromTop) {
				NSNotification.post("screen", 8)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromBottom) {
				NSNotification.post("screen", 2)
			}
		}
		.background(KeyEventHandling { key, code, modifiers in
			let cmd = modifiers.contains(.command)
			let opt = modifiers.contains(.option)
			switch key {
				case ".":
					if cmd && opt {
						showSettings.toggle()
					}
				case "1", "2", "3", "4", "5", "6", "7", "8", "9":
					if cmd, let n = Int(key) {
						NSNotification.post("screen", n)
					}
				case "q":
					if cmd && opt {
						if let window = NSApplication.shared.windows.first, cmd {
							window.alphaValue = 0
						}
						DispatchQueue.main.async {
							exit(0)
						}
					}
				default:
					switch code {
						case 36: // return
							if cmd {
								NSNotification.post("screen", 5)
							}
						case 123: // arrow left
							if cmd {
								NSNotification.post("screen", 4)
							}
						case 124: // arrow right
							if cmd {
								NSNotification.post("screen", 6)
							}
						case 125: // arrow down
							if cmd {
								NSNotification.post("screen", 2)
							}
						case 126: // arrow up
							if cmd {
								NSNotification.post("screen", 8)
							}
						default:
							print("[\(key)] \(code)")
					}
					break
			}
		})
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}