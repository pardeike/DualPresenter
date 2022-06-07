import AppKit
import SwiftUI
import ScreenCaptureKit

struct ScreenGrabber: View {
	
	let slideNr: Int
	let app: String
	let width: Double
	let height: Double
	
	var body: some View {
		ScreenGrabberRepresentable(slideNr: slideNr, app: app, width: width, height: height)
			//.background(.black.opacity(0.5))
	}
}

struct ScreenGrabberRepresentable: NSViewRepresentable {
	typealias Representable = Self
	
	let slideNr: Int
	let app: String
	let width: Double
	let height: Double
	let previewView: PreviewView
	
	init(slideNr: Int, app: String, width: Double, height: Double) {
		self.slideNr = slideNr
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
		context.coordinator.updateStream(previewView, width, height)
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(slideNr, app, width, height, previewView)
	}
	
	class Coordinator: NSObject, SCStreamOutput {
		let slideNr: Int
		let app: String
		let previewView: PreviewView
		var currentStream: SCStream?
		
		func streamConfiguration(winFrame: NSRect, screenWidth: Double, screenHeight: Double) -> SCStreamConfiguration {
			let streamConfig = SCStreamConfiguration()
			streamConfig.queueDepth = 5
			let f = max(screenWidth / winFrame.width, screenHeight / winFrame.height)
			streamConfig.width = Int(screenWidth / f)
			streamConfig.height = Int(screenHeight / f)
			streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
			streamConfig.backgroundColor = .clear
			streamConfig.showsCursor = true
			return streamConfig
		}
		
		func updateStream(_ previewView: PreviewView, _ screenWidth: Double, _ screenHeight: Double) {
			// print("Getting windows for \(app)")
			var found = false
			SCShareableContent.getExcludingDesktopWindows(true, onScreenWindowsOnly: true) { sharableContent, error in
				if let sharableContent = sharableContent {
					if let window = sharableContent.windows.first(where: { win in
						return win.title != "" && win.frame.width > 128 && win.frame.width < 1920 && (win.owningApplication?.applicationName ?? "") == self.app
					}) {
						print("- \(window.title ?? "")")
						found = true
						if let currentStream = self.currentStream {
							currentStream.updateConfiguration(self.streamConfiguration(winFrame: window.frame, screenWidth: screenWidth, screenHeight: screenHeight))
						} else {
							let filter = SCContentFilter(desktopIndependentWindow: window)
							let config = self.streamConfiguration(winFrame: window.frame, screenWidth: screenWidth, screenHeight: screenHeight)
							let stream = SCStream(filter: filter, configuration: config, delegate: nil)
							try! stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
							stream.startCapture { err in
								if let err = err {
									print("Error \(err)")
								}
							}
							self.currentStream = stream
						}
					}
				}
				if found == false || error != nil {
					if let currentStream = self.currentStream {
						currentStream.stopCapture()
						try? currentStream.removeStreamOutput(self, type: .screen)
						self.currentStream = nil
					}
				}
			}
		}
		
		init(_ slideNr: Int, _ app: String, _ screenWidth: Double, _ screenHeight: Double, _ previewView: PreviewView) {
			self.slideNr = slideNr
			self.app = app
			self.previewView = previewView
			super.init()
			updateStream(previewView, screenWidth, screenHeight)
		}
		
		func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
			previewView.displayLayer.enqueue(sampleBuffer)
		}
	}
}
