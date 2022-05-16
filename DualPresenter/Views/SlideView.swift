import SwiftUI

struct SlideView: View {
	
	let slideNr: Int
	let slideCount: Int
	@Binding var currentSlide: Slide
	
	@State var animateScreen = 0
	@State var lastScreenState = -999
	@State var offsetX: [Double] = [0.5, 0]
	@State var offsetY: [Double] = [0.5, 0]
	@State var sizeX: [Double] = [0, 0]
	@State var sizeY: [Double] = [0, 0]
	
	func offsetX(_ geo: GeometryProxy) -> Double { geo.size.width * offsetX[lastScreenState < 0 ? 0 : 1] }
	func offsetY(_ geo: GeometryProxy) -> Double { geo.size.height * offsetY[lastScreenState < 0 ? 0 : 1] }
	func sizeX(_ geo: GeometryProxy) -> Double { geo.size.width * sizeX[lastScreenState < 0 ? 0 : 1] }
	func sizeY(_ geo: GeometryProxy) -> Double { geo.size.height * sizeY[lastScreenState < 0 ? 0 : 1] }
	
	func p(_ geo: GeometryProxy) -> CGFloat { 80 /* geo.size.height / 12 */ }
	
	func setScreenState(_ n: Int) {
		if lastScreenState == n {
			offsetX[1] = offsetX[0]
			offsetY[1] = offsetY[0]
			sizeX[1] = sizeX[0]
			sizeY[1] = sizeY[0]
			lastScreenState = -n
			animateScreen += 1
			return
		}
		
		if n == 1 {
			offsetX = [-0.25, 0.25]
			offsetY = [1.25, 0.75]
			sizeX = [0.5, 0.5]
			sizeY = [0.5, 0.5]
		}
		if n == 2 {
			offsetX = [0.5, 0.5]
			offsetY = [1.25, 0.75]
			sizeX = [1, 1]
			sizeY = [0.5, 0.5]
		}
		if n == 3 {
			offsetX = [1.25, 0.75]
			offsetY = [1.25, 0.75]
			sizeX = [0.5, 0.5]
			sizeY = [0.5, 0.5]
		}
		if n == 4 {
			offsetX = [-0.25, 0.25]
			offsetY = [0.5, 0.5]
			sizeX = [0.5, 0.5]
			sizeY = [1, 1]
		}
		if n == 5 {
			offsetX = [0.5, 0.5]
			offsetY = [0.5, 0.5]
			sizeX = [0, 1]
			sizeY = [0, 1]
		}
		if n == 6 {
			offsetX = [1.25, 0.75]
			offsetY = [0.5, 0.5]
			sizeX = [0.5, 0.5]
			sizeY = [1, 1]
		}
		if n == 7 {
			offsetX = [-0.25, 0.25]
			offsetY = [-0.25, 0.25]
			sizeX = [0.5, 0.5]
			sizeY = [0.5, 0.5]
		}
		if n == 8 {
			offsetX = [0.5, 0.5]
			offsetY = [-0.25, 0.25]
			sizeX = [1, 1]
			sizeY = [0.5, 0.5]
		}
		if n == 9 {
			offsetX = [1.25, 0.75]
			offsetY = [-0.25, 0.25]
			sizeX = [0.5, 0.5]
			sizeY = [0.5, 0.5]
		}
		
		DispatchQueue.main.async {
			lastScreenState = n
			animateScreen += 1
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .topLeading) {
				VStack {
					CustomizableTextEditor(simple: true, name: "select-title", text: $currentSlide.title)
						.fixedSize(horizontal: false, vertical: true)
						.padding(EdgeInsets(top: 0, leading: 0, bottom: p(geo), trailing: 0))
					
					VStack {
						CustomizableTextEditor(simple: false, name: "select-content", text: $currentSlide.content)
						Spacer()
					}
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
					
					Text("\(slideNr + 1) / \(slideCount)")
				}
				.padding(EdgeInsets(top: p(geo), leading: p(geo), bottom: 40, trailing: p(geo)))
				
				ScreenGrabber(app: "Xcode")
					.position(x: offsetX(geo), y: offsetY(geo))
					.frame(width: sizeX(geo), height: sizeY(geo))
					.animation(.linear(duration: 0.2), value: animateScreen)
			}
		}
		.onReceive(NSNotification.publisher("screen")) { val in
			if let n = val.userInfo?["n"] as? Int {
				setScreenState(n)
			}
		}
	}
}
