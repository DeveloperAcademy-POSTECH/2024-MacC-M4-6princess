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
    @StateObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        DispatchQueue.main.async {
            viewModel.preview = AVCaptureVideoPreviewLayer(session: viewModel.cameraManager.session)
            
            // 커스텀 비율 계산
            let screenWidth = UIScreen.main.bounds.width
            let height = screenWidth * 1.54
            let previewFrame = CGRect(x: 0, y: 0, width: screenWidth, height: height)
            
            viewModel.preview.frame = previewFrame
            viewModel.preview.videoGravity = .resizeAspect
            view.layer.addSublayer(viewModel.preview)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        viewModel.preview.frame = CGRect(
            x: 0,
            y: 0,
            width: uiView.frame.width,
            height: uiView.frame.width * 1.54
        )
    }
}
