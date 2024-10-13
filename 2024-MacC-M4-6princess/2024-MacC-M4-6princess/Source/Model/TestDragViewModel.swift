//
//  TestDragViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//
import SwiftUI

class TestDragViewModel: ObservableObject {
    @Published var location: CGPoint
    @Published var idolWidth: CGFloat
    let idolImg: UIImage
    let idolRatio: CGFloat
    
    init() {
        guard let idolCGImage = UIImage(named: "Felix")?.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
        self.idolRatio = idolImg.size.height / idolImg.size.width
        self.location = CGPoint(x: 100, y: 100)
        self.idolWidth = 100
    }
    
    func updateLocation(with translation: CGSize, startLocation: CGPoint?) {
        var newLocation = startLocation ?? location
        newLocation.x += translation.width
        newLocation.y += translation.height
        self.location = newLocation
    }
}
