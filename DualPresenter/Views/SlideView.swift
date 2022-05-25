import SwiftUI

struct SlideViewGrabber: View {
	
	let size: CGSize
	let name: String
	let idx: Int
	
	@State var animateScreen = 0
	@State var lastScreenState = -999
	@State var offsetX: [Double] = [0.5, 0]
	@State var offsetY: [Double] = [0.5, 0]
	@State var sizeX: [Double] = [0, 0]
	@State var sizeY: [Double] = [0, 0]
	
	func oX() -> Double { size.width * offsetX[lastScreenState < 0 ? 0 : 1] }
	func oY() -> Double { size.height * offsetY[lastScreenState < 0 ? 0 : 1] }
	func sX() -> Double { size.width * sizeX[lastScreenState < 0 ? 0 : 1] }
	func sY() -> Double { size.height * sizeY[lastScreenState < 0 ? 0 : 1] }
	
	func setScreenState(_ idx: Int?) {
		
		guard let idx = idx else { return }
		if lastScreenState == idx {
			offsetX[1] = offsetX[0]
			offsetY[1] = offsetY[0]
			sizeX[1] = sizeX[0]
			sizeY[1] = sizeY[0]
			lastScreenState = -idx
			animateScreen += 1
			return
		}
		
		lastScreenState = -idx
		animateScreen += 1
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(210)) {
			if idx == 2 {
				offsetX = [0.5, 0.5]
				offsetY = [1, 0.5]
				sizeX = [1, 1]
				sizeY = [0.5, 0.5]
			}
			if idx == 4 {
				offsetX = [-0.5, 0]
				offsetY = [0.5, 0.5]
				sizeX = [0.5, 0.5]
				sizeY = [1, 1]
			}
			if idx == 5 {
				offsetX = [0, 0.5]
				offsetY = [0, 0.5]
				sizeX = [0.0001, 1]
				sizeY = [0.0001, 1]
			}
			if idx == 6 {
				offsetX = [1, 0.5]
				offsetY = [0.5, 0.5]
				sizeX = [0.5, 0.5]
				sizeY = [1, 1]
			}
			if idx == 8 {
				offsetX = [0.5, 0.5]
				offsetY = [-0.5, 0]
				sizeX = [1, 1]
				sizeY = [0.5, 0.5]
			}
			
			DispatchQueue.main.async {
				lastScreenState = idx
				animateScreen += 1
			}
		}
	}
	
	var body: some View {
		ZStack {
			if sX() > 0.0001 {
				ScreenGrabber(app: name, width: sX(), height: sY())
					.position(x: oX(), y: oY())
					.frame(width: sX(), height: sY())
					.animation(.linear(duration: 0.2), value: animateScreen)
			}
		}
		.frame(width: size.width, height: size.height)
		.onReceive(NSNotification.publisher("screen")) { val in
			if let n = val.userInfo?["a"] as? Int, n == idx {
				let b = val.userInfo?["b"] as? Int
				setScreenState(b)
			}
		}
	}
}

struct SlideView: View {
	
	let slideNr: Int
	let slideCount: Int
	@Binding var currentSlide: Slide
	@State var selectedGraphicId: String? = nil
	
	func p(_ geo: GeometryProxy) -> CGFloat { 80 /* geo.size.height / 12 */ }
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .topLeading) {
				VStack {
					CustomizableTextEditor(simple: true, name: "select-title", text: $currentSlide.title)
						//.background(.white.opacity(0.1))
						.fixedSize(horizontal: false, vertical: true)
						.padding(EdgeInsets(top: 0, leading: 0, bottom: p(geo), trailing: 0))
					
					CustomizableTextEditor(simple: false, name: "select-content", text: $currentSlide.content)
						//.background(.white.opacity(0.1))
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
					
					Text("\(slideNr + 1) / \(slideCount)")
				}
				.padding(EdgeInsets(top: p(geo), leading: p(geo), bottom: 40, trailing: p(geo)))
				
				ForEach($currentSlide.graphics) { graphic in
					GraphicView(graphic: graphic, portSize: geo.size)
				}
				
				SlideViewGrabber(size: geo.size, name: "Xcode", idx: 1)
				SlideViewGrabber(size: geo.size, name: "Code", idx: 2)
			}
			.onReceive(NSNotification.publisher("select")) { evt in
				selectedGraphicId = evt.userInfo?["id"] as? String
			}
			.onDeleteCommand {
				if let id = selectedGraphicId {
					currentSlide.graphics.removeAll { $0.id == id }
				}
			}
		}
	}
}
