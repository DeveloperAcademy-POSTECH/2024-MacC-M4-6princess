//
//  TestDragView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//

import SwiftUI
struct TestDragView: View {
    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    var felix = "Felix"
    var idolImg: UIImage
    init() {
        guard let idolCGImage = UIImage(named: felix)?.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
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
    
    var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: idolImg)
                .frame(width: 100, height: 100)
                .position(location)
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag)
                )
            if let fingerLocation = fingerLocation {
                Circle()
                    .stroke(Color.clear, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
    }
}
