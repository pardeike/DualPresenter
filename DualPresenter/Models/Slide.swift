import SwiftUI

struct SlideText: Codable {
	var text: NSAttributedString
	var size: Int
	
	init(text: String, size: Int) {
		let txt = NSMutableAttributedString(string: text)
		txt.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: txt.length))
		txt.addAttribute(.font, value: NSFont.sfPro(size), range: NSRange(location: 0, length: txt.length))
		self.text = txt
		self.size = size
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let box = try? container.decode(ArchiverBox<NSAttributedString>.self, forKey: .text)
		text = box?.value ?? NSAttributedString()
		size = (try? container.decode(Int.self, forKey: .size)) ?? 12
	}
	
	enum CodingKeys: String, CodingKey {
		case text
		case size
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(ArchiverBox(text), forKey: .text)
		try? container.encode(size, forKey: .size)
	}
}

struct Graphic: Codable, Identifiable {
	var id = UUID().uuidString
	var url: URL
	var rect: NSRect
}

struct Slide: Codable {
	var title = SlideText(text: "", size: 80)
	var content = SlideText(text: "", size: 48)
	var source = ""
	var graphics = [Graphic]()
}
