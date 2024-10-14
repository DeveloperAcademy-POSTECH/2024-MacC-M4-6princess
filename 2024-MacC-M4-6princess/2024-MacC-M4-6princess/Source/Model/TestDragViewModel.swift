//
//  TestDragViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/14/24.
//
import SwiftUI

class TestDragViewModel: ObservableObject {
    //아이돌 위치 잡기
    @Published var location: CGPoint = CGPoint(x: 100, y: 100) //뷰가 생길때 재초기화,이건 디폴트값
    @Published var idolWidth: CGFloat
    let idolImg: UIImage
    let idolRatio: CGFloat
    @Published var idolRect: CGRect = .zero // 아이돌 이미지 왼쪽 상단 좌표
    
    init() {
        guard let idolCGImage = UIImage(named: "Felix")?.cgImage else {
            fatalError("이미지 로드 실패")
        }
        
        self.idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
        self.idolRatio = idolImg.size.height / idolImg.size.width
        self.idolWidth = 150
        idolRect = CGRect(x: location.x - idolWidth/2, y: location.y - (idolWidth * idolRatio)/2 , width: idolWidth, height: idolWidth * idolRatio)
    }
    
    func updateLocation(with translation: CGSize, startLocation: CGPoint?) {
        var newLocation = startLocation ?? location
        newLocation.x += translation.width
        newLocation.y += translation.height
        self.location = newLocation
    }
}
