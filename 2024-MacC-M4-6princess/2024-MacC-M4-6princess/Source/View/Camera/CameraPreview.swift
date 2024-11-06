//
//  CameraPreview.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

///카메라 화면 프리뷰
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
            
            
            DispatchQueue.main.async {
                viewModel.preview = AVCaptureVideoPreviewLayer(session: viewModel.cameraManager.session)
                viewModel.preview.frame = view.frame
                viewModel.preview.videoGravity = .resizeAspectFill
                view.layer.addSublayer(viewModel.preview)
            }
        DispatchQueue.main.async {
            viewModel.cameraManager.session.startRunning()
                }
            
            return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        viewModel.cameraManager.stopSession()
        viewModel.preview.frame = uiView.bounds
    }
}
