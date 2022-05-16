import AppKit
import AVKit

class PreviewView: NSView {
	
	var displayLayer = AVSampleBufferDisplayLayer()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		layer = displayLayer
		wantsLayer = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
