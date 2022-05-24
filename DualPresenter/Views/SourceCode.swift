import SwiftUI

struct SourceCode: View {
	
	@Binding var source: String
	
	var body: some View {
		VStack {
			Text("Source Code").font(.title)
			Spacer(minLength: 20)
			
			TextEditor(text: $source)
				.font(.body.monospaced())
		}
		.padding()
		.frame(width: (NSApplication.shared.mainWindow?.frame.width ?? 1024) * 0.75, height: 480)
	}
}
