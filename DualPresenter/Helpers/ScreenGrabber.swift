import AppKit
import SwiftUI
import ScreenCaptureKit

var currentStream: SCStream?

struct ScreenGrabber: View {
	let app: String
	let width: Double
	let height: Double
	
	var body: some View {
		ScreenGrabberRepresentable(app: app, width: width, height: height)
	}
}

struct ScreenGrabberRepresentable: NSViewRepresentable {
	typealias Representable = Self
	
	let app: String
	let width: Double
	let height: Double
	let previewView: PreviewView
	
	init(app: String, width: Double, height: Double) {
		self.app = app
		self.width = width
		self.height = height
		self.previewView = PreviewView()
	}
	
	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		view.layer?.backgroundColor = .clear
		view.addSubview(previewView)
		previewView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			previewView.widthAnchor.constraint(equalTo: view.widthAnchor),
			previewView.heightAnchor.constraint(equalTo: view.heightAnchor),
		])
		return view
	}
	
	func updateNSView(_ view: NSView, context: Context) {
		context.coordinator.updateStream(width, height)
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(app, width, height, previewView)
	}
	
	class Coordinator: NSObject, SCStreamOutput {
		let app: String
		let previewView: PreviewView
		
		func streamConfiguration(window: SCWindow, screenWidth: Double, screenHeight: Double) -> SCStreamConfiguration {
			let streamConfig = SCStreamConfiguration()
			streamConfig.queueDepth = 5
			let winFrame = window.frame
			let f = max(screenWidth / winFrame.width, screenHeight / winFrame.height)
			streamConfig.width = Int(screenWidth / f)
			streamConfig.height = Int(screenHeight / f)
			streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
			streamConfig.backgroundColor = .clear
			streamConfig.showsCursor = true
			return streamConfig
		}
		
		func isAppWindow(_ window: SCWindow) -> Bool {
			return window.isOnScreen && window.frame.width > 400 && (window.owningApplication?.applicationName ?? "").contains(self.app)
		}
		
		func getXCodeWindow() -> SCWindow? {
			var result: SCWindow?
			let group = DispatchGroup()
			group.enter()
			SCShareableContent.getExcludingDesktopWindows(true, onScreenWindowsOnly: true) { sharableContent, error in
				if error == nil, let sharableContent = sharableContent {
					if let window = sharableContent.windows.first(where: self.isAppWindow) {
						result = window
					}
				}
				group.leave()
			}
			group.wait()
			return result
		}
		
		func updateStream(_ screenWidth: Double, _ screenHeight: Double) {
			guard let window = getXCodeWindow() else { return }
			if currentStream == nil {
				let filter = SCContentFilter(desktopIndependentWindow: window)
				let config = self.streamConfiguration(window: window, screenWidth: screenWidth, screenHeight: screenHeight)
				currentStream = SCStream(filter: filter, configuration: config, delegate: nil)
				try! currentStream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
				currentStream!.startCapture(completionHandler: nil)
			}
			currentStream?.updateConfiguration(self.streamConfiguration(window: window, screenWidth: screenWidth, screenHeight: screenHeight))
		}
		
		init(_ app: String, _ screenWidth: Double, _ screenHeight: Double, _ previewView: PreviewView) {
			self.app = app
			self.previewView = previewView
			super.init()
			updateStream(screenWidth, screenHeight)
		}
		
		func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
			previewView.displayLayer.enqueue(sampleBuffer)
		}
	}
}
