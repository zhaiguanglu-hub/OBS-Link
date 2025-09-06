import SwiftUI
import AVFoundation
import HaishinKit

/// SwiftUI wrapper for camera preview using HaishinKit's RTMPStream
struct CameraPreviewView: UIViewRepresentable {
    @Binding var rtmpStream: RTMPStream?
    @Binding var isStreaming: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing preview layer
        uiView.layer.sublayers?.removeAll { $0 is AVCaptureVideoPreviewLayer }
        
        guard let rtmpStream = rtmpStream else { return }
        
        // Create and configure preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: rtmpStream.mixer.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = uiView.bounds
        
        uiView.layer.addSublayer(previewLayer)
        
        // Update frame when bounds change
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}

/// Alternative camera preview using AVCaptureVideoPreviewLayer directly
struct DirectCameraPreviewView: UIViewRepresentable {
    @Binding var isStreaming: Bool
    let cameraPosition: AVCaptureDevice.Position
    
    private let captureSession = AVCaptureSession()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        setupCameraSession()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame when bounds change
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
    
    private func setupCameraSession() {
        guard captureSession.inputs.isEmpty else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        captureSession.commitConfiguration()
        
        // Start session on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

/// Camera preview with tap-to-focus functionality
struct InteractiveCameraPreviewView: UIViewRepresentable {
    @Binding var isStreaming: Bool
    let cameraPosition: AVCaptureDevice.Position
    let onTap: (CGPoint) -> Void
    
    private let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        setupCameraSession()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setupCameraSession() {
        guard captureSession.inputs.isEmpty else { return }
        
        captureSession.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        self.videoDevice = videoDevice
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        captureSession.commitConfiguration()
        
        // Start session on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    class Coordinator: NSObject {
        let parent: InteractiveCameraPreviewView
        
        init(_ parent: InteractiveCameraPreviewView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            parent.onTap(location)
            
            // Focus at tap point
            if let videoDevice = parent.videoDevice {
                do {
                    try videoDevice.lockForConfiguration()
                    if videoDevice.isFocusPointOfInterestSupported {
                        videoDevice.focusPointOfInterest = location
                        videoDevice.focusMode = .autoFocus
                    }
                    if videoDevice.isExposurePointOfInterestSupported {
                        videoDevice.exposurePointOfInterest = location
                        videoDevice.exposureMode = .autoExpose
                    }
                    videoDevice.unlockForConfiguration()
                } catch {
                    print("Failed to configure focus: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview Helpers

struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DirectCameraPreviewView(
                isStreaming: .constant(false),
                cameraPosition: .back
            )
            .previewDisplayName("Back Camera")
            
            DirectCameraPreviewView(
                isStreaming: .constant(false),
                cameraPosition: .front
            )
            .previewDisplayName("Front Camera")
        }
    }
}