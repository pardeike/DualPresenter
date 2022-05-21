import SwiftUI
import Combine
import KeyboardShortcuts

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding(
		get: { lhs.wrappedValue ?? rhs },
		set: { lhs.wrappedValue = $0 }
	)
}

extension NSNotification {
	class func post(_ name: String) {
		NotificationCenter.default.post(name: NSNotification.Name(name), object: nil)
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

extension String {
	subscript(idx: Int) -> String {
		String(self[index(startIndex, offsetBy: idx)])
	}
}
