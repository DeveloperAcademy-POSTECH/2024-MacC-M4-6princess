//
//  CameraPreview.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

///카메라 화면 프리뷰
struct CameraPreview: UIViewRepresentable{
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        // AVCaptureVideoPreviewLayer 생성
        
        DispatchQueue.main.async {
            camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
            camera.preview.frame = view.frame
            camera.preview.videoGravity = .resizeAspectFill
            
            //다른거 추가할꺼면 추가
            view.layer.addSublayer(camera.preview)
        }
        
        //starting session
        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        if camera.isTaken {
//                    camera.session.stopRunning()
//                }else {
//                    DispatchQueue.global(qos: .background).async {
//                        camera.session.startRunning()
//                    }
//                }
    }
}
