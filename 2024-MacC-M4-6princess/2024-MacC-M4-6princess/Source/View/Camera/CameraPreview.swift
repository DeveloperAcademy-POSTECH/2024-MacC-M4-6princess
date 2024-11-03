//
//  CameraPreview.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

///카메라 화면 프리뷰
//
//  CameraPreview.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // Preview layer는 이미 ViewModel 초기화 시점에서 설정되어 있음
        viewModel.preview.frame = view.frame
        viewModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(viewModel.preview)
        
        // 세션 시작
        DispatchQueue.main.async {
            viewModel.cameraManager.startSession()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Preview layer 프레임 업데이트
        viewModel.preview.frame = uiView.frame
    }
}
