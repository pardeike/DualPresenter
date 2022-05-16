import SwiftUI

struct SlideText {
	var text: NSAttributedString
	var size: Int
	var alignment: Alignment
	
	init(text: String, size: Int, alignment: Alignment) {
		let txt = NSMutableAttributedString(string: text)
		txt.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: txt.length))
		txt.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(size)), range: NSRange(location: 0, length: txt.length))
		self.text = txt
		self.size = size
		self.alignment = alignment
	}
}

struct Slide {
	var title = SlideText(text: "", size: 64, alignment: .leading)
	var content = SlideText(text: "", size: 48, alignment: .leading)
}
