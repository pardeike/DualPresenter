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
	
	func setScreenState(_ a: Int?, _ b: Int?) {
		guard let a = a else { return }
		print(a, lastScreenState)
		if lastScreenState == a {
			offsetX[1] = offsetX[0]
			offsetY[1] = offsetY[0]
			sizeX[1] = sizeX[0]
			sizeY[1] = sizeY[0]
			lastScreenState = -a
			animateScreen += 1
			return
		}
		
		lastScreenState = -a
		animateScreen += 1
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(210)) {
			if a == 1 {
				offsetX = [-0.25, 0.25]
				offsetY = [1.25, 0.75]
				sizeX = [0.5, 0.5]
				sizeY = [0.5, 0.5]
			}
			if a == 2 {
				offsetX = [0.5, 0.5]
				offsetY = [1.25, 0.75]
				sizeX = [1, 1]
				sizeY = [0.5, 0.5]
			}
			if a == 3 {
				offsetX = [1.25, 0.75]
				offsetY = [1.25, 0.75]
				sizeX = [0.5, 0.5]
				sizeY = [0.5, 0.5]
			}
			if a == 4 {
				offsetX = [-0.25, 0.25]
				offsetY = [0.5, 0.5]
				sizeX = [0.5, 0.5]
				sizeY = [1, 1]
			}
			if a == 5 {
				offsetX = [0.5, 0.5]
				offsetY = [0.5, 0.5]
				sizeX = [0.0001, 1]
				sizeY = [0.0001, 1]
			}
			if a == 6 {
				offsetX = [1.25, 0.75]
				offsetY = [0.5, 0.5]
				sizeX = [0.5, 0.5]
				sizeY = [1, 1]
			}
			if a == 7 {
				offsetX = [-0.25, 0.25]
				offsetY = [-0.25, 0.25]
				sizeX = [0.5, 0.5]
				sizeY = [0.5, 0.5]
			}
			if a == 8 {
				offsetX = [0.5, 0.5]
				offsetY = [-0.25, 0.25]
				sizeX = [1, 1]
				sizeY = [0.5, 0.5]
			}
			if a == 9 {
				offsetX = [1.25, 0.75]
				offsetY = [-0.25, 0.25]
				sizeX = [0.5, 0.5]
				sizeY = [0.5, 0.5]
			}
		
			DispatchQueue.main.async {
				lastScreenState = a
				animateScreen += 1
			}
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
				
				if sizeX(geo) > 0.0001 {
					ScreenGrabber(app: "Xcode", width: sizeX(geo), height: sizeY(geo))
						.position(x: offsetX(geo), y: offsetY(geo))
						.frame(width: sizeX(geo), height: sizeY(geo))
						.animation(.linear(duration: 0.2), value: animateScreen)
				}
			}
		}
		.onReceive(NSNotification.publisher("screen")) { val in
			let a = val.userInfo?["a"] as? Int
			let b = val.userInfo?["b"] as? Int
			setScreenState(a, b)
		}
	}
}
