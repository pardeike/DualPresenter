import SwiftUI
import KeyboardShortcuts

struct MainView: View {
	
	@StateObject var appState: AppState
	
	@State var showSettings = false
	@State var showSourceCode = false
	@State var presentation = Presentation.load(presentationURL())
	@State var currentSlide = Slide()
	@State var fullScreen = false
	@State var slideNr = -1
	
	init() {
		_appState = StateObject(wrappedValue: AppState())
	}
	
	static func presentationURL() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0].appendingPathComponent("dualpresenter.json")
	}
	
	func save() {
		if slideNr != -1 {
			presentation.slides[slideNr] = currentSlide
			presentation.save(MainView.presentationURL())
		}
	}
	
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
		.sheet(isPresented: $showSourceCode) {
			SourceCode(source: $currentSlide.source)
		}
		.onDrop(of: ["public.url", "public.file-url"], isTargeted: nil) { (items) -> Bool in
			if slideNr >= 0, let item = items.first {
				if let identifier = item.registeredTypeIdentifiers.first {
					if identifier == "public.url" || identifier == "public.file-url" {
						Task {
							item.loadItem(forTypeIdentifier: identifier, options: nil) { urlData, error in
								if let urlData = urlData as? Data {
									let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
									currentSlide.graphics.append(Graphic(url: url, rect: NSRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)))
								}
							}
						}
					}
				}
				return true
			}
			return false
		}
		.onAppear {
			if let first = presentation.slides.first {
				slideNr = 0
				currentSlide = first
			}
		}
		.onAppear {
			KeyboardShortcuts.onKeyDown(for: .toggleFullscreen) {
				if let window = NSApplication.shared.windows.first {
					window.toggleFullScreen(nil)
				}
			}
			KeyboardShortcuts.onKeyDown(for: .toggleSourceCode) {
				if slideNr >= 0 || showSourceCode {
					showSourceCode.toggle()
					if showSourceCode == false {
						save()
					}
				}
			}
			KeyboardShortcuts.onKeyDown(for: .insertSourceCode) {
				if slideNr >= 0 {
					let source = currentSlide.source
					if source.count > 0 {
						let pb = NSPasteboard.general
						var oldPaste = [(NSPasteboard.PasteboardType, Data)]()
						if let types = pb.types {
							oldPaste = types.filter { pb.data(forType: $0) != nil }.map { t in (t, pb.data(forType: t)!) }
						}
						pb.clearContents()
						pb.setString(source, forType: .string)
						FakeKey.send(fakeKey: "V", useCommandFlag: true)
						DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(200)) {
							pb.clearContents()
							oldPaste.forEach { pb.setData($0.1, forType: $0.0) }
						}
					}
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
				save()
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
					save()
				}
			}
			KeyboardShortcuts.onKeyDown(for: .selectTitleField) {
				NSNotification.post("select-title")
			}
			KeyboardShortcuts.onKeyDown(for: .selectContentField) {
				NSNotification.post("select-content")
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromLeft) {
				NSNotification.post("screen", 1, 4)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromRight) {
				NSNotification.post("screen", 1, 6)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromCenter) {
				NSNotification.post("screen", 1, 5)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromTop) {
				NSNotification.post("screen", 1, 8)
			}
			KeyboardShortcuts.onKeyDown(for: .app1FromBottom) {
				NSNotification.post("screen", 1, 2)
			}
			KeyboardShortcuts.onKeyDown(for: .app2FromLeft) {
				NSNotification.post("screen", 2, 4)
			}
			KeyboardShortcuts.onKeyDown(for: .app2FromRight) {
				NSNotification.post("screen", 2, 6)
			}
			KeyboardShortcuts.onKeyDown(for: .app2FromCenter) {
				NSNotification.post("screen", 2, 5)
			}
			KeyboardShortcuts.onKeyDown(for: .app2FromTop) {
				NSNotification.post("screen", 2, 8)
			}
			KeyboardShortcuts.onKeyDown(for: .app2FromBottom) {
				NSNotification.post("screen", 2, 2)
			}
		}
		.onReceive(NSNotification.publisher("settings")) { _ in
			showSettings.toggle()
		}
		.onReceive(NSNotification.publisher("save")) { _ in
			save()
		}
		.onReceive(NSNotification.publisher("quit")) { _ in
			save()
			NSApplication.shared.windows.forEach { $0.alphaValue = 0 }
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { exit(0) }
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
