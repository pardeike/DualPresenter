import Foundation

final class Action: NSObject {
	
	private let _action: () -> ()
	
	init(action: @escaping () -> ()) {
		_action = action
		super.init()
	}
	
	@objc func action() {
		_action()
	}
}
