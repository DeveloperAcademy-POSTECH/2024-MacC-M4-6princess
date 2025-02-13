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
            viewModel.preview.frame = viewModel.frameSize
            viewModel.preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(viewModel.preview)
            
            //                viewModel.cameraManager.session.startRunning()
        }
        
        // 터치 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        //        viewModel.cameraManager.stopSession()
        //        viewModel.preview.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(viewModel: viewModel)
        }

    class Coordinator: NSObject {
            let viewModel: CameraViewModel
            
            init(viewModel: CameraViewModel) {
                self.viewModel = viewModel
            }
            
            @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                guard let view = gesture.view else { return }
                let location = gesture.location(in: view)
                
                // 초점 설정
                viewModel.focus(at: location, in: view)
                
                // 노란 네모 애니메이션 추가
                let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                focusView.center = location
                focusView.layer.borderWidth = 2
                focusView.layer.borderColor = UIColor.yellow.cgColor
                focusView.backgroundColor = UIColor.clear
                
                // 애니메이션 효과
                DispatchQueue.main.async {
                    view.addSubview(focusView)
                    UIView.animate(withDuration: 0.5, animations: {
                        focusView.alpha = 0
                        focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }) { _ in
                        focusView.removeFromSuperview()
                    }
                }
            }
        }
}
