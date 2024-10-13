//
//  TestDragView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//

import SwiftUI
struct TestDragView: View {
    @State private var location: CGPoint = CGPoint(x: 100, y: 100)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    @State var idolWidth:CGFloat = 100
    var felix = "Felix"
    var idolImg: UIImage
    var idolRatio:CGFloat
    init() {
        guard let idolCGImage = UIImage(named: felix)?.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
        idolRatio = idolImg.size.height/idolImg.size.width
    }
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }
    }
    
//    var fingerDrag: some Gesture {
//        DragGesture()
//            .updating($fingerLocation) { (value, fingerLocation, transaction) in
//                fingerLocation = value.location
//            }
//    }
    
    var body: some View {
        ZStack {
            Image(uiImage: idolImg)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: idolWidth, height: idolWidth * idolRatio)
                .position(location)
                .gesture(
                    simpleDrag
//                        .simultaneously(with: fingerDrag)
                )

        }
    }
}
