import SwiftUI

struct Handle: View {
	
	enum Corner {
		case topLeft
		case topRight
		case bottomLeft
		case bottomRight
	}
	
	let corner: Corner
	let callback: () -> Void
	var size: CGFloat
	@Binding var dx: CGFloat
	@Binding var dy: CGFloat
	@Binding var dw: CGFloat
	@Binding var dh: CGFloat
	@Binding var startOffset: CGSize?
	
	var body: some View {
		Color.black
			.overlay {
				Color.white
					.padding(2)
			}
			.frame(width: size, height: size)
			.gesture(
				DragGesture()
					.onChanged { gesture in
						if let startOffset = startOffset {
							let x = gesture.translation.width - startOffset.width
							let y = gesture.translation.height - startOffset.height
							DispatchQueue.main.async {
								switch corner {
									case .topLeft:
										dx += x
										dy += y
										dw -= x
										dh -= y
									case .topRight:
										dy += y
										dw += x
										dh -= y
									case .bottomLeft:
										dx += x
										dw -= x
										dh += y
									case .bottomRight:
										dw += x
										dh += y
								}
							}
						} else {
							startOffset = gesture.translation
						}
					}
					.onEnded { _ in
						startOffset = nil
						callback()
					}
			)
	}
}
