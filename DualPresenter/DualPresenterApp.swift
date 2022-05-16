import AppKit
import SwiftUI
import KeyboardShortcuts

@main
struct DualPresenterApp: App {
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var body: some Scene {
		WindowGroup {
			MainView().frame(minWidth: 320, maxWidth: .infinity, minHeight: 240, maxHeight: .infinity, alignment: .center)
				.background(
					Image("background")
						.resizable()
				)
				.onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
					if let window = NSApplication.shared.windows.first {
						window.showsResizeIndicator = false
						window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
						window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
						window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
					}
				})
		}
		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unifiedCompact(showsTitle: false))
	}
}
