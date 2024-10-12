////
////  CameraPhotoView.swift
////  2024-MacC-M4-6princess
////
////  Created by 김이예은 on 10/11/24.
////
//
//import SwiftUI
//
//struct CameraPhotoView: View {
//    @ObservedObject var camera: CameraModel
//    @Binding var uiView: UIHostingController<CameraPhotoView>
//    
//    var body: some View {
//        let images = camera.imageViews // CameraModel에서 이미지 배열 가져오기
//        let count = images.count
//        
//        let rows = Int(ceil(Double(count) / 2.0)) // 2열
//        let cols = min(count, 2) // 최대 2열
//        
//        let imageWidth = uiView.bounds.width / CGFloat(cols)
//        let imageHeight = uiView.bounds.height / CGFloat(rows)
//        
//        VStack {
//            if camera.isAllTaken {
//                // 찍은 사진 모두 보여주는 뷰
//                
//                
//                for (index, image) in images.enumerated() {
//                    let imageView = UIImageView(image: image)
//                    imageView.contentMode = .scaleAspectFit
//                    
//                    let row = index / cols
//                    let col = index % cols
//                    imageView.frame = CGRect(
//                        x: CGFloat(col) * imageWidth,
//                        y: CGFloat(row) * imageHeight,
//                        width: imageWidth,
//                        height: imageHeight
//                    )
//                    
//                    uiView.addSubview(imageView)
//                }
//    //                        camera.session.stopRunning()
//            }else {
//                DispatchQueue.global(qos: .background).async {
//                    camera.session.startRunning()
//                    
//                }
//                
//                
//            }
//        }
//    }
//}
//
