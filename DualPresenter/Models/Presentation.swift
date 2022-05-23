import SwiftUI

struct Presentation: Codable {
	var slides: [Slide] = []
	
	static func load(_ url: URL) -> Presentation {
		do {
			let data = try Data(contentsOf: url)
			return try JSONDecoder().decode(Presentation.self, from: data)
		} catch {
			print(error)
			return Presentation()
		}
	}
	
	func save(_ url: URL) {
		do {
			let data = try JSONEncoder().encode(self)
			try data.write(to: url)
		} catch {
			print(error)
		}
	}
}
