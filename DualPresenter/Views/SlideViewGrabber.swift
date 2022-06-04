import SwiftUI

struct SlideViewGrabber: View {
	
	let geoSize: CGSize
	let name: String
	let offsetX: [Double]
	let offsetY: [Double]
	let scaleX: Double
	let scaleY: Double
	let clipX: Double
	let clipY: Double
	
	@State var animateScreen = 0
	@Binding var show: Bool
	@State var realShow = false
	
	func oX() -> Double { geoSize.width * offsetX[realShow ? 1 : 0] }
	func oY() -> Double { geoSize.height * offsetY[realShow ? 1 : 0] }
	
	var body: some View {
		HStack {
			ScreenGrabber(app: name, width: geoSize.width * scaleX, height: geoSize.height * scaleY)
				.frame(width: geoSize.width * scaleX, height: geoSize.height * scaleY)
		}
		.clipped()
		.position(x: oX(), y: oY())
		.frame(width: geoSize.width * scaleX * clipX, height: geoSize.height * scaleY * clipY)
		.animation(.linear(duration: 0.2), value: animateScreen)
		.onChange(of: show) { newValue in
			realShow = newValue
			animateScreen += 1
		}
	}
}
