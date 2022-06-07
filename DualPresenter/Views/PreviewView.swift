import AppKit
import AVKit

class PreviewView: NSView {
	
	var displayLayer = AVSampleBufferDisplayLayer()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		displayLayer.preventsDisplaySleepDuringVideoPlayback = true
		displayLayer.frame = NSRect.zero
		displayLayer.backgroundColor = .clear
		displayLayer.videoGravity = .resize
		layer = displayLayer
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func recreateLayer() {
		displayLayer = AVSampleBufferDisplayLayer()
		displayLayer.preventsDisplaySleepDuringVideoPlayback = true
		displayLayer.frame = NSRect.zero
		displayLayer.backgroundColor = .clear
		displayLayer.videoGravity = .resize
		layer = displayLayer
	}
}
