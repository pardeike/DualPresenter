import SwiftUI

struct SlideView: View {
	
	let slideNr: Int
	let slideCount: Int
	@Binding var currentSlide: Slide
	@State var selectedGraphicId: String? = nil
	@State var showXCode = false
	@State var showVSCode = false
	@State var showExtras = false
	
	let padding = CGFloat(80)
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .topLeading) {
				VStack {
					CustomizableTextEditor(simple: true, name: "select-title", text: $currentSlide.title)
						//.background(.white.opacity(0.1))
						.fixedSize(horizontal: false, vertical: true)
						.padding(EdgeInsets(top: 0, leading: 0, bottom: padding, trailing: 0))
					
					CustomizableTextEditor(simple: false, name: "select-content", text: $currentSlide.content)
						//.background(.white.opacity(0.1))
						.padding(EdgeInsets(top: 0, leading: 0, bottom: padding / 2, trailing: 0))
					
					Text("\(slideNr + 1) / \(slideCount)")
				}
				.padding(EdgeInsets(top: padding, leading: padding, bottom: padding / 2, trailing: padding))
				
				ForEach($currentSlide.graphics) { graphic in
					GraphicView(graphic: graphic, portSize: geo.size)
				}
				
				SlideViewGrabber(slideNr: slideNr, geoSize: geo.size, name: "Code - Insiders", offsetX: [-0.25, 0.25], offsetY: [0.5, 0.5], scaleX: 0.5, scaleY: 1, clipX: 1, clipY: 1, show: $showVSCode)
				SlideViewGrabber(slideNr: slideNr, geoSize: geo.size, name: "Xcode", offsetX: [1.25, 0.75], offsetY: [0.5, 0.5], scaleX: 0.5, scaleY: 1, clipX: 1, clipY: 1, show: $showXCode)
				
				SlideViewGrabber(slideNr: slideNr, geoSize: geo.size, name: "Simulator", offsetX: [-0.11, 0.11], offsetY: [0.68, 0.68], scaleX: 0.22, scaleY: 1, clipX: 1, clipY: 0.9, show: $showExtras)
				SlideViewGrabber(slideNr: slideNr, geoSize: geo.size, name: "Camo Studio", offsetX: [-0.11, 0.11], offsetY: [0.475, 0.475], scaleX: 0.22, scaleY: 1, clipX: 1, clipY: 0.7, show: $showExtras)
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
