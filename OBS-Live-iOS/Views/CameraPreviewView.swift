import SwiftUI

struct CameraPreviewView: View {
	var body: some View {
		#if canImport(HaishinKit)
		CameraPreviewRepresentable()
			.background(Color.black)
		#else
		ZStack {
			Color.black
			Text("Camera Preview")
				.foregroundColor(.white)
				.opacity(0.6)
		}
		#endif
	}
}

#if canImport(HaishinKit)
import HaishinKit
import AVFoundation

struct CameraPreviewRepresentable: UIViewRepresentable {
	@EnvironmentObject var streamingManager: StreamingManager

	func makeUIView(context: Context) -> HKView {
		let view = HKView()
		view.videoGravity = AVLayerVideoGravity.resizeAspectFill
		if let stream = streamingManager.rtmpStream {
			view.attachStream(stream)
		}
		return view
	}

	func updateUIView(_ uiView: HKView, context: Context) {
		if let stream = streamingManager.rtmpStream {
			if uiView.stream == nil {
				uiView.attachStream(stream)
			}
		} else {
			uiView.attachStream(nil)
		}
	}
}
#endif