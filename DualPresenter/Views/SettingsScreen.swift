import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
	
	let closeAction: () -> Void
	
	var body: some View {
		VStack {
			Text("Shortcuts").font(.title)
			Spacer(minLength: 20)
			VStack(alignment: .trailing) {
				Form {
					Section("Basics") {
						KeyboardShortcuts.Recorder("Toggle Fullscreen Mode", name: .toggleFullscreen)
						KeyboardShortcuts.Recorder("Default Advance Slide", name: .simpleAdvanceSlide)
						KeyboardShortcuts.Recorder("Insert Source", name: .insertSourceCode)
							.padding(.bottom, 20)
					}
					Section("Movement") {
						KeyboardShortcuts.Recorder("Next Slide", name: .nextSlide)
						KeyboardShortcuts.Recorder("Previous Slide", name: .previousSlide)
							.padding(.bottom, 20)
					}
					Section("Editing") {
						KeyboardShortcuts.Recorder("Add New Slide", name: .addNewSlide)
						KeyboardShortcuts.Recorder("Delete Current Slide", name: .deleteCurrentSlide)
						KeyboardShortcuts.Recorder("Toggle Source", name: .toggleSourceCode)
						KeyboardShortcuts.Recorder("Select Title", name: .selectTitleField)
						KeyboardShortcuts.Recorder("Select Content", name: .selectContentField)
							.padding(.bottom, 20)
					}
					Section("App 1") {
						KeyboardShortcuts.Recorder("From Left", name: .app1FromLeft)
						KeyboardShortcuts.Recorder("From Right", name: .app1FromRight)
						KeyboardShortcuts.Recorder("From Center", name: .app1FromCenter)
						KeyboardShortcuts.Recorder("From Top", name: .app1FromTop)
						KeyboardShortcuts.Recorder("From Bottom", name: .app1FromBottom)
							.padding(.bottom, 20)
					}
					Section("App 2") {
						KeyboardShortcuts.Recorder("From Left", name: .app2FromLeft)
						KeyboardShortcuts.Recorder("From Right", name: .app2FromRight)
						KeyboardShortcuts.Recorder("From Center", name: .app2FromCenter)
						KeyboardShortcuts.Recorder("From Top", name: .app2FromTop)
						KeyboardShortcuts.Recorder("From Bottom", name: .app2FromBottom)
							.padding(.bottom, 20)
					}
				}
			}
			
			Button(action: closeAction) {
				Text("      OK      ")
					.font(.system(size: 16))
					.padding(8)
					.background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
			}
			.keyboardShortcut(.defaultAction)
			.buttonStyle(PlainButtonStyle())
			
		}
		.padding()
		.frame(minWidth: 320)
	}
}
