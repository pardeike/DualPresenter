import AppKit
import ScreenCaptureKit

class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ notification: Notification) {
		if NSColorPanel.shared.isVisible {
			NSColorPanel.shared.close()
		}
		if NSFontPanel.shared.isVisible {
			NSFontPanel.shared.close()
		}
		NSApplication.unfocus()
		
		/*print("Available windows:")
		SCShareableContent.getExcludingDesktopWindows(true, onScreenWindowsOnly: true) { sharableContent, error in
			if error == nil, let sharableContent = sharableContent {
				sharableContent.windows.forEach { win in
					print("- \(win.owningApplication?.applicationName ?? "???") \(win.frame.width) x \(win.frame.height)")
				}
			}
		}*/
	}
	
	func applicationWillUpdate(_ notification: Notification) {
		if let menu = NSApplication.shared.mainMenu {
			menu.items.removeAll { $0.title != "Edit" }
			
			let appMenuItem = NSMenuItem(title: "App", action: nil, keyEquivalent: "")
			menu.items.insert(appMenuItem, at: 0)
			
			let appMenu = NSMenu()
			appMenuItem.submenu = appMenu
			
			appMenu.addItem("Settings", #selector(settings), ",")
			appMenu.addItem(NSMenuItem.separator())
			appMenu.addItem("Colors", #selector(toggleColors), "c", [.command, .shift])
			appMenu.addItem("Fonts", #selector(toggleFonts), "f", [.command, .shift])
			appMenu.addItem(NSMenuItem.separator())
			appMenu.addItem("Save", #selector(save), "s")
			appMenu.addItem(NSMenuItem.separator())
			appMenu.addItem("Quit", #selector(quit), "q", [.command, .option])
		}
	}
	
	@objc
	func settings() {
		NSNotification.post("settings")
	}
	
	@objc
	func save() {
		NSNotification.post("save")
	}
	
	@objc
	func quit() {
		NSNotification.post("quit")
	}
	
	@objc
	func toggleColors() {
		if NSColorPanel.shared.isVisible {
			NSColorPanel.shared.close()
		} else {
			NSColorPanel.shared.orderBack(self)
		}
	}
	
	@objc
	func toggleFonts() {
		if NSFontPanel.shared.isVisible {
			NSFontPanel.shared.close()
		} else {
			NSFontPanel.shared.orderBack(self)
		}
	}
}
