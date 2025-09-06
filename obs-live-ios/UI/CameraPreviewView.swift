import SwiftUI
import HaishinKit
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
	@EnvironmentObject var streamingManager: StreamingManager

	func makeUIView(context: Context) -> HKView {
		let v = HKView()
		v.videoGravity = .resizeAspectFill
		return v
	}

	func updateUIView(_ uiView: HKView, context: Context) {
		streamingManager.attachPreview(to: uiView)
	}
}