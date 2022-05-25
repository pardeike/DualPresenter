import SwiftUI
import Combine
import KeyboardShortcuts

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding(
		get: { lhs.wrappedValue ?? rhs },
		set: { lhs.wrappedValue = $0 }
	)
}

extension NSApplication {
	class func unfocus() {
		if let window = shared.windows.first, let contentView = window.contentView {
			window.makeFirstResponder(contentView)
		}
	}
}

extension CGPoint {
	mutating func add(_ point: CGPoint) {
		self = CGPoint(x: self.x + point.x, y: self.y + point.y)
	}
	mutating func sub(_ point: CGPoint) {
		self = CGPoint(x: self.x - point.x, y: self.y - point.y)
	}
}

extension CGSize {
	mutating func add(_ point: CGPoint) {
		self = CGSize(width: self.width + point.x, height: self.height + point.y)
	}
	mutating func sub(_ point: CGPoint) {
		self = CGSize(width: self.width - point.x, height: self.height - point.y)
	}
}

extension CGKeyCode
{
	static let shiftKeys: [CGKeyCode] = [0x38, 0x3C]
	static let optionKeys: [CGKeyCode] = [0x3A, 0x3D]
	static let commandKeys: [CGKeyCode] = [0x37]
	static let controlKeys: [CGKeyCode] = [0x3B, 0x3E]
	static let functionKeys: [CGKeyCode] = [0x3F]
}

extension Array where Element == CGKeyCode {
	var isPressed: Bool {
		return self.contains { CGEventSource.keyState(.combinedSessionState, key: $0) }
	}
}

extension NSNotification {
	class func post(_ name: String) {
		NotificationCenter.default.post(name: NSNotification.Name(name), object: nil)
	}
	class func post(_ name: String, id: String) {
		NotificationCenter.default.post(name: NSNotification.Name(name), object: nil, userInfo: ["id": id])
	}
	class func post(_ name: String, _ a: Int) {
		NotificationCenter.default.post(name: NSNotification.Name(name), object: nil, userInfo: ["a": a])
	}
	class func post(_ name: String, _ a: Int, _ b: Int) {
		NotificationCenter.default.post(name: NSNotification.Name(name), object: nil, userInfo: ["a": a, "b": b])
	}
	class func publisher(_ name: String) -> AnyPublisher<NotificationCenter.Publisher.Output, NotificationCenter.Publisher.Failure> {
		NotificationCenter.default.publisher(for: NSNotification.Name(name)).eraseToAnyPublisher()
	}
}

extension View {
	@ViewBuilder
	func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
		if condition { transform(self) }
		else { self }
	}
}

extension String {
	subscript(idx: Int) -> String {
		String(self[index(startIndex, offsetBy: idx)])
	}
	
	/*func cleanSourceCode() -> String {
		var result = self
		while true {
			var lines: [String] = []
			result.enumerateLines { l, s in lines.append(l) }
			if lines.isEmpty || lines[0].count == 0 { return result }
			let c = lines[0][0]
			if c != " " && c != "\t" { break }
			if lines.allSatisfy({ $0 == "" || $0.starts(with: c) }) == false { break }
			var offset = 0
			for line in lines {
				let len = line.count
				let idx = result.index(result.startIndex, offsetBy: offset)
				result.remove(at: idx)
				offset += len - 1 + 1
			}
		}
		while true {
			if let c = result.last, c.isWhitespace {
				result.removeLast()
				continue
			}
			break
		}
		return result
	}*/
}

extension NSMenu {
	func addItem(_ title: String, _ action: Selector?, _ key: String, _ flags: NSEvent.ModifierFlags = [.command]) {
		let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
		item.keyEquivalentModifierMask = flags
		self.addItem(item)
	}
}
