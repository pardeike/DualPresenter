import AppKit
import SwiftUI
import ScreenCaptureKit

struct ScreenGrabber: View {
	let app: String
	var body: some View {
		ScreenGrabberRepresentable(app: app)
			.background(.clear)
	}
}

struct ScreenGrabberRepresentable: NSViewRepresentable {
	typealias Representable = Self
	
	let app: String
	let previewView = PreviewView()
	
	func makeNSView(context: Context) -> NSView {
		let view = NSView()
		view.addSubview(previewView)
		previewView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			previewView.topAnchor.constraint(equalTo: view.topAnchor),
			previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
		previewView.layer?.zPosition = -1
		return view
	}
	
	func updateNSView(_ view: NSView, context: Context) {
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(app, previewView)
	}
	
	class Coordinator: NSObject, SCStreamOutput {
		let app: String
		let previewView: PreviewView
		
		var currentStream: SCStream? {
			willSet {
				if currentStream != nil, currentStream != newValue {
					currentStream?.stopCapture(completionHandler: nil)
				}
			}
		}
		
		init(_ app: String, _ previewView: PreviewView) {
			self.app = app
			self.previewView = previewView
			self.currentStream = nil
			super.init()
			SCShareableContent.getExcludingDesktopWindows(true, onScreenWindowsOnly: true) { sharableContent, error in
				guard error == nil, let sharableContent = sharableContent else { return }
				if let window = sharableContent.windows.first(where: { $0.isOnScreen && $0.frame.width > 400 && ($0.owningApplication?.applicationName ?? "").contains(app) }) {
					let filter = SCContentFilter(desktopIndependentWindow: window)
					let streamConfig = SCStreamConfiguration()
					streamConfig.queueDepth = 5
					streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
					streamConfig.showsCursor = false
					let stream = SCStream(filter: filter, configuration: streamConfig, delegate: nil)
					self.currentStream = stream
					try! stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
					stream.startCapture(completionHandler: nil)
				}
			}
		}
		
		func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
			previewView.displayLayer.enqueue(sampleBuffer)
			/*if let imageBuffer = sampleBuffer.imageBuffer {
				let width = CVPixelBufferGetWidth(imageBuffer)
				let height = CVPixelBufferGetHeight(imageBuffer)
				let currentRatio = window.aspectRatio.width / window.aspectRatio.height
				let ratio = CGFloat(width) / CGFloat(height)
				if currentRatio.isNaN || abs(currentRatio - ratio) > 0.01 {
					window.aspectRatio = .init(width: width, height: height)
					window.layoutIfNeeded()
				}
			}*/
		}
	}
}
