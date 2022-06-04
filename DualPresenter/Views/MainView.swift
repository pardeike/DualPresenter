import SwiftUI
import KeyboardShortcuts

struct MainView: View {
	
	@StateObject var appState: AppState
	
	@State var showSettings = false
	@State var showSourceCode = false
	@State var presentation = Presentation.load(presentationFile())
	@State var currentSlide = Slide()
	@State var fullScreen = false
	
	init() {
		_appState = StateObject(wrappedValue: AppState())
	}
	
	static func presentationFile() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0].appendingPathComponent("dualpresenter.json")
	}
	
	static func presentationBackupFolder() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let folder = paths[0].appendingPathComponent("dualpresenter-backups")
		try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
		return folder
	}
	
	func save() {
		if presentation.slideNr != -1 {
			presentation.slides[presentation.slideNr] = currentSlide
			let file = MainView.presentationFile()
			if FileManager.default.fileExists(atPath: file.path) {
				let df = DateFormatter()
				df.dateFormat = "yyyy-MM-dd HH.mm.ss'.json'"
				let backupName = df.string(from: Date())
				try? FileManager.default.copyItem(at: file, to: MainView.presentationBackupFolder().appendingPathComponent(backupName))
			}
			presentation.save(MainView.presentationFile())
		}
	}
	
	var body: some View {
		HStack {
			if presentation.slideNr == -1 {
				Text("Let's get started!")
			} else {
				SlideView(
					slideNr: presentation.slideNr,
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
			if presentation.slideNr >= 0, let item = items.first {
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
			if presentation.slideNr >= 0 && presentation.slideNr < presentation.slides.count {
				currentSlide = presentation.slides[presentation.slideNr]
			}
		}
		.onAppear {
			KeyboardShortcuts.onKeyDown(for: .toggleFullscreen) {
				if let window = NSApplication.shared.windows.first {
					window.toggleFullScreen(nil)
				}
			}
			KeyboardShortcuts.onKeyDown(for: .toggleSourceCode) {
				if presentation.slideNr >= 0 || showSourceCode {
					showSourceCode.toggle()
					if showSourceCode == false {
						save()
					}
				}
			}
			KeyboardShortcuts.onKeyDown(for: .insertSourceCode) {
				if presentation.slideNr >= 0 {
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
				if presentation.slideNr < presentation.slides.count - 1 {
					if presentation.slideNr >= 0 { presentation.slides[presentation.slideNr] = currentSlide }
					presentation.slideNr += 1
					currentSlide = presentation.slides[presentation.slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .nextSlide) {
				if presentation.slideNr < presentation.slides.count - 1 {
					if presentation.slideNr >= 0 { presentation.slides[presentation.slideNr] = currentSlide }
					presentation.slideNr += 1
					currentSlide = presentation.slides[presentation.slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .previousSlide) {
				if presentation.slideNr > 0 {
					presentation.slides[presentation.slideNr] = currentSlide
					presentation.slideNr -= 1
					currentSlide = presentation.slides[presentation.slideNr]
				}
			}
			KeyboardShortcuts.onKeyDown(for: .addNewSlide) {
				if presentation.slideNr >= 0 { presentation.slides[presentation.slideNr] = currentSlide }
				let slideToCopy = currentSlide
				presentation.slideNr += 1
				currentSlide = slideToCopy
				presentation.slides.insert(currentSlide, at: presentation.slideNr)
				save()
			}
			KeyboardShortcuts.onKeyDown(for: .deleteCurrentSlide) {
				if presentation.slides.isEmpty == false {
					presentation.slides.remove(at: presentation.slideNr)
					if presentation.slideNr >= presentation.slides.count { presentation.slideNr -= 1 }
					if presentation.slides.isEmpty {
						presentation.slideNr = -1
						currentSlide = Slide()
					} else {
						currentSlide = presentation.slides[presentation.slideNr]
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
			KeyboardShortcuts.onKeyDown(for: .toggleXCode) {
				NSNotification.post("xcode")
			}
			KeyboardShortcuts.onKeyDown(for: .toggleVSCode) {
				NSNotification.post("vscode")
			}
			KeyboardShortcuts.onKeyDown(for: .toggleExtras) {
				NSNotification.post("extras")
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
