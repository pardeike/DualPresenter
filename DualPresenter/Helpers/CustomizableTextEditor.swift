import AppKit
import SwiftUI

struct CustomizableTextEditor: View {
	
	var simple: Bool
	var name: String
	@Binding var text: SlideText
	
	var body: some View {
		TextViewRepresentable(simple: simple, name: name, text: $text.text, size: $text.size)
			.frame(minHeight: CGFloat($text.size.wrappedValue) * 1.4, alignment: .leading)
	}
}

class FocusAwareTextView: NSTextView {
	var name: String = ""
	var simple = false
	var onFocusLost: (() -> Void)? = nil
	
	override func resignFirstResponder() -> Bool {
		onFocusLost?()
		return super.resignFirstResponder()
	}
	
	override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
		if let replacementString = replacementString, replacementString == "\t" {
			if name == "select-content" {
				if textStorage?.length == 0 {
					NSNotification.post("select-title")
					return false
				}
			} else {
				NSNotification.post("select-content")
				return false
			}
		}
		return super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
	}
	
	func removeCommonPrefix(_ str: NSMutableAttributedString) {
		while true {
			var lines: [String] = []
			str.string.enumerateLines { l, s in lines.append(l) }
			if lines.isEmpty || lines[0].count == 0 { return }
			let c = lines[0][0]
			if c != " " && c != "\t" { break }
			if lines.allSatisfy({ $0 == "" || $0.starts(with: c) }) == false { break }
			var offset = 0
			for line in lines {
				let len = line.count
				str.replaceCharacters(in: NSRange(location: offset, length: 1), with: "")
				offset += len - 1 + 1
			}
		}
	}
	
	func removeTrailingWhitespace(_ str: NSMutableAttributedString) {
		while true {
			if let c = str.string.last, c.isWhitespace {
				str.replaceCharacters(in: NSRange(location: str.string.count - 1, length: 1), with: "")
				continue
			}
			break
		}
	}
	
	override func paste(_ sender: Any?) {
		if simple {
			pasteAsPlainText(sender)
			return
		}
		if CGKeyCode.shiftKeys.isPressed {
			let pb = NSPasteboard.general
			let aStrings = pb.readObjects(forClasses: [NSAttributedString.self]) as! [NSAttributedString]
			if let str = aStrings.first {
				let cleaned = NSMutableAttributedString(attributedString: str)
				let all = NSRange(location: 0, length: cleaned.length)
				cleaned.removeAttribute(.font, range: all)
				cleaned.removeAttribute(.paragraphStyle, range: all)
				cleaned.removeAttribute(.backgroundColor, range: all)
				let newline = String(format: "%C", NSLineSeparatorCharacter)
				for i in 0..<cleaned.length {
					if cleaned.string[i] == "\n" {
						cleaned.replaceCharacters(in: NSRange(location: i, length: 1), with: newline)
					}
				}
				removeCommonPrefix(cleaned)
				removeTrailingWhitespace(cleaned)
				insertText(cleaned, replacementRange: selectedRange())
				return
			}
		}
		super.paste(sender)
	}
}

struct TextViewRepresentable: NSViewRepresentable {
	typealias Representable = Self
	
	var simple: Bool
	var name: String = ""
	@Binding var text: NSAttributedString
	@Binding var size: Int
	
	@Environment(\.undoManager) var undoManger
	
	func makeNSView(context: Context) -> NSView {
		let nsTextView = FocusAwareTextView(frame: .zero)
		nsTextView.name = name
		nsTextView.simple = simple
		nsTextView.onFocusLost = {
			nsTextView.setSelectedRange(NSRange())
		}
		context.coordinator.textView = nsTextView
		nsTextView.delegate = context.coordinator
		nsTextView.textStorage?.delegate = context.coordinator
		nsTextView.drawsBackground = false
		nsTextView.allowsUndo = true
		nsTextView.importsGraphics = true
		nsTextView.allowsImageEditing = true
		nsTextView.font = NSFont.sfPro($size.wrappedValue)
		return nsTextView
	}
	
	func updateNSView(_ view: NSView, context: Context) {
		if let nsTextView = view as? NSTextView {
			let sel = nsTextView.selectedRange()
			let newStorage = NSTextStorage(attributedString: text)
			nsTextView.layoutManager?.replaceTextStorage(newStorage)
			nsTextView.setSelectedRange(sel)
			nsTextView.sizeToFit()
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self, simple, name, size)
	}
	
	class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
		
		var textView: FocusAwareTextView?
		var simple: Bool
		var name: String
		var size: CGFloat
		var parent: Representable?
		var subscription: NSObjectProtocol?
		
		init(_ textEditor: Representable, _ simple: Bool, _ name: String, _ size: Int) {
			self.simple = simple
			self.name = name
			self.parent = textEditor
			self.subscription = nil
			self.size = CGFloat(size)
			super.init()
			subscription = NotificationCenter.default.addObserver(forName: NSNotification.Name(name), object: nil, queue: nil) { [weak self] _ in
				DispatchQueue.main.async {
					if let textView = self?.textView {
						textView.window?.makeFirstResponder(textView)
						//textView.selectAll(nil)
					}
				}
			}
		}
		
		deinit {
			if let subscription = subscription {
				NotificationCenter.default.removeObserver(subscription)
			}
		}
		
		func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
			// print(commandSelector)
			if commandSelector == #selector(NSResponder.pageUp(_:)) {
				NSNotification.post("select-title")
				return false
			}
			if commandSelector == #selector(NSResponder.pageDown(_:)) {
				NSNotification.post("select-content")
				return false
			}
			if commandSelector == #selector(NSResponder.cancelOperation(_:)) || commandSelector == #selector(NSSavePanel.cancel(_:)) {
				NSApplication.unfocus()
				return true
			}
			if commandSelector == #selector(NSResponder.insertNewline(_:)) {
				if let event = NSApp.currentEvent,  event.modifierFlags.contains(.shift) {
					textView.insertLineBreak(nil)
					return true
				}
			}
			return false
		}
		
		func textDidChange(_ notification: Notification) {
			guard notification.name == NSText.didChangeNotification,
				  let nsTextView = notification.object as? NSTextView else {
				return
			}
			parent?.text = nsTextView.attributedString()
		}
		
		func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
			if simple { return }
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineHeightMultiple = 1.2
			paragraphStyle.lineSpacing = 0
			paragraphStyle.paragraphSpacing = size
			paragraphStyle.tabStops = stride(from: 1, to: 20, by: 1).map { NSTextTab(textAlignment: .left, location: $0 * size) }
			textStorage.addAttributes([.paragraphStyle: paragraphStyle], range: editedRange)
			textStorage.removeAttribute(.backgroundColor, range: editedRange)
		}
		
		func undoManager(for view: NSTextView) -> UndoManager? {
			return parent?.undoManger
		}
	}
}
