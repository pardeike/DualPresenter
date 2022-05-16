import AppKit
import SwiftUI

typealias KeyReceiver = (_ key: String, _ code: UInt16, _ modifiers: NSEvent.ModifierFlags) -> Void

struct KeyEventHandling: NSViewRepresentable {
	
	let keyReceiver: KeyReceiver
	
	class KeyView: NSView {
		
		var keyReceiver: KeyReceiver? = nil
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override init(frame frameRect: NSRect) {
			super.init(frame: NSRect.zero)
		}
		
		override var acceptsFirstResponder: Bool { true }
		override func keyDown(with event: NSEvent) {
			if let key = event.charactersIgnoringModifiers {
				keyReceiver?(key, event.keyCode, event.modifierFlags)
			}
		}
	}
	
	static func findKeyView(_ view: NSView) -> KeyView? {
		if let keyView = view as? KeyView {
			return keyView
		}
		for v in view.subviews {
			if let keyView = findKeyView(v) {
				return keyView
			}
		}
		return nil
	}
	
	static func focusOnWindow(_ window: NSWindow?) {
		let keyView = findKeyView(window?.contentView ?? NSView())
		window?.makeFirstResponder(keyView)
	}
	
	func makeNSView(context: Context) -> NSView {
		let view = KeyView()
		view.keyReceiver = keyReceiver
		DispatchQueue.main.async { // wait till next event cycle
			KeyEventHandling.focusOnWindow(view.window)
		}
		return view
	}
	
	func updateNSView(_ nsView: NSView, context: Context) {
	}
}
