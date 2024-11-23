import SwiftUI

struct SubjectImage: Identifiable, Hashable {
    
    let id: UUID = UUID()
    var image: UIImage?
    var originalImage: UIImage? // 원본 이미지
    var angle: Angle = .degrees(0)
    var offSet: CGSize = .zero
    var scale: CGFloat = 1.0
    
}
