//
//  CameraPreviewView.swift
//  OBSLive
//
//  Created by OBS Live Team
//

import SwiftUI
import AVFoundation
import HaishinKit

/// 相机预览视图，显示实时摄像头画面
struct CameraPreviewView: UIViewRepresentable {
    let streamingManager: StreamingManager
    
    func makeUIView(context: Context) -> HKView {
        let view = HKView()
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: HKView, context: Context) {
        // 将RTMP流附加到预览视图
        if uiView.attachStream == nil {
            DispatchQueue.main.async {
                uiView.attachStream = streamingManager.rtmpStream
            }
        }
    }
}

/// 自定义预览视图，支持触摸对焦
class CustomPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var focusView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .black
        
        // 添加触摸手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        // 创建对焦指示器
        setupFocusView()
    }
    
    private func setupFocusView() {
        focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView?.layer.borderColor = UIColor.yellow.cgColor
        focusView?.layer.borderWidth = 2
        focusView?.backgroundColor = UIColor.clear
        focusView?.alpha = 0
        addSubview(focusView!)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: self)
        
        // 显示对焦动画
        showFocusAnimation(at: tapPoint)
        
        // 执行对焦
        focusCamera(at: tapPoint)
    }
    
    private func showFocusAnimation(at point: CGPoint) {
        guard let focusView = focusView else { return }
        
        focusView.center = point
        focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        focusView.alpha = 1.0
        
        UIView.animate(withDuration: 0.3, animations: {
            focusView.transform = CGAffineTransform.identity
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                focusView.alpha = 0
            }, completion: nil)
        }
    }
    
    private func focusCamera(at point: CGPoint) {
        guard let previewLayer = previewLayer else { return }
        
        // 将触摸点转换为相机坐标
        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        // 通知代理执行对焦
        NotificationCenter.default.post(
            name: NSNotification.Name("CameraFocusRequested"),
            object: nil,
            userInfo: ["focusPoint": NSValue(cgPoint: focusPoint)]
        )
    }
    
    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        previewLayer?.removeFromSuperlayer()
        previewLayer = layer
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(layer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

#Preview {
    CameraPreviewView(streamingManager: StreamingManager())
}