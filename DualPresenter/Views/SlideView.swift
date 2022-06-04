import SwiftUI

struct SlideView: View {
	
	let slideNr: Int
	let slideCount: Int
	@Binding var currentSlide: Slide
	@State var selectedGraphicId: String? = nil
	@State var showXCode = false
	@State var showVSCode = false
	@State var showExtras = false
	
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
				
				SlideViewGrabber(geoSize: geo.size, name: "Code - Insiders", offsetX: [-0.25, 0.25], offsetY: [0.5, 0.5], scaleX: 0.5, scaleY: 1, clipX: 1, clipY: 1, show: $showVSCode)
				SlideViewGrabber(geoSize: geo.size, name: "Xcode", offsetX: [1.25, 0.75], offsetY: [0.5, 0.5], scaleX: 0.5, scaleY: 1, clipX: 1, clipY: 1, show: $showXCode)
				
				SlideViewGrabber(geoSize: geo.size, name: "Simulator", offsetX: [-0.11, 0.11], offsetY: [0.68, 0.68], scaleX: 0.22, scaleY: 1, clipX: 1, clipY: 0.9, show: $showExtras)
				SlideViewGrabber(geoSize: geo.size, name: "Camo Studio", offsetX: [-0.11, 0.11], offsetY: [0.475, 0.475], scaleX: 0.22, scaleY: 1, clipX: 1, clipY: 0.7, show: $showExtras)
			}
			.onReceive(NSNotification.publisher("select")) { evt in
				selectedGraphicId = evt.userInfo?["id"] as? String
			}
			.onReceive(NSNotification.publisher("xcode")) { _ in
				showXCode.toggle()
			}
			.onReceive(NSNotification.publisher("vscode")) { _ in
				showVSCode.toggle()
			}
			.onReceive(NSNotification.publisher("extras")) { _ in
				showExtras.toggle()
			}
			.onDeleteCommand {
				if let id = selectedGraphicId {
					currentSlide.graphics.removeAll { $0.id == id }
				}
			}
		}
	}
}
