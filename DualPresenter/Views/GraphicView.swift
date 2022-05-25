import SwiftUI

struct GraphicView: View {
	
	@Binding var graphic: Graphic
	let portSize: CGSize
	@State var dx = CGFloat(0)
	@State var dy = CGFloat(0)
	@State var dw = CGFloat(0)
	@State var dh = CGFloat(0)
	@State var startOffset: CGSize? = nil
	
	var x: CGFloat { $graphic.rect.origin.x.wrappedValue * portSize.width + dx }
	var y: CGFloat { $graphic.rect.origin.y.wrappedValue * portSize.height + dy }
	var w: CGFloat { $graphic.rect.size.width.wrappedValue * portSize.width + dw }
	var h: CGFloat { $graphic.rect.size.height.wrappedValue * portSize.height + dh }
	
	@State var selected = false
	let dashTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	@State var dashPhase = CGFloat(0)
	
	init(graphic: Binding<Graphic>, portSize: CGSize) {
		_graphic = graphic
		self.portSize = portSize
	}
	
	func updateGraphic() {
		graphic.rect.origin = CGPoint(x: x / portSize.width, y: y / portSize.height)
		graphic.rect.size = CGSize(width: w / portSize.width, height: h / portSize.height)
		dx = 0
		dy = 0
		dw = 0
		dh = 0
	}

	var body: some View {
		AsyncImage(url: graphic.url) { phase in
			switch phase {
				case .empty:
					ZStack(alignment: .center) { ProgressView() }
						.background(.black.opacity(0.1))
						.offset(x: x, y: y)
						.frame(width: max(1, w), height: max(1, h))
				case .success(let image):
					ZStack {
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
					}
					.if(selected) {
						$0.overlay(
							ZStack {
								Rectangle()
									.stroke(.white, style: StrokeStyle(lineWidth: 1, dash: [10, 10], dashPhase: dashPhase + 10))
								Rectangle()
									.stroke(.black, style: StrokeStyle(lineWidth: 1, dash: [10, 10], dashPhase: dashPhase))
							}
							.overlay {
								VStack {
									HStack {
										Handle(corner: .topLeft, callback: updateGraphic, size: 8, dx: $dx, dy: $dy, dw: $dw, dh: $dh, startOffset: $startOffset)
											.offset(x: -4, y: -4)
										Spacer()
										Handle(corner: .topRight, callback: updateGraphic, size: 8, dx: $dx, dy: $dy, dw: $dw, dh: $dh, startOffset: $startOffset)
											.offset(x: 4, y: -4)
									}
									Spacer()
									HStack {
										Handle(corner: .bottomLeft, callback: updateGraphic, size: 8, dx: $dx, dy: $dy, dw: $dw, dh: $dh, startOffset: $startOffset)
											.offset(x: -4, y: 4)
										Spacer()
										Handle(corner: .bottomRight, callback: updateGraphic, size: 8, dx: $dx, dy: $dy, dw: $dw, dh: $dh, startOffset: $startOffset)
											.offset(x: 4, y: 4)
									}
								}
							}
						)
					}
					.offset(x: x, y: y)
					.frame(width: max(1, w), height: max(1, h))
					.gesture(
						DragGesture()
							.onChanged { gesture in
								if startOffset == nil { startOffset = gesture.translation }
								DispatchQueue.main.async {
									dx = gesture.translation.width - startOffset!.width
									dy = gesture.translation.height - startOffset!.height
								}
							}
							.onEnded { _ in
								startOffset = nil
								updateGraphic()
							}
					)
				default:
					EmptyView()
			}
		}
		.onTapGesture {
			NSNotification.post("select", id: graphic.id)
		}
		.onReceive(NSNotification.publisher("select")) { evt in
			if let id = evt.userInfo?["id"] as? String {
				if id == graphic.id {
					selected = true
				} else {
					selected = false
					updateGraphic()
				}
			}
		}
		.onReceive(dashTimer) { _ in
			dashPhase += 1
		}
	}
}
