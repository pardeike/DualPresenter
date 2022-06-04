import SwiftUI

struct Presentation: Codable {
	var slideNr: Int
	{
		get { _slideNr ?? -1 }
		set { _slideNr = newValue }
	}
	
	var slides: [Slide] = []
	var _slideNr: Int?
	
	enum CodingKeys: String, CodingKey {
		case slides
		case _slideNr = "slideNr"
	}
	
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
