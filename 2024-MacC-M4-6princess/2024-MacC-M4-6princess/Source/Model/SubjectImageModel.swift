import SwiftUI


class SubjectImage: Identifiable {
    
    var image: UIImage?
    var originalImage: UIImage?
    var sticker: UIImage?
    var text: UIImage?
    
    var angle: Angle = .degrees(0)
    var offset: CGSize = .zero
    var scale: CGFloat = 1.0
    var originalText: String = ""
    
    var isTapped: Bool = false
    
    let id: UUID = UUID()
    
    func setScale(scale: CGFloat) {
        self.scale = scale
    }
    
    func setAngle(angle: Angle) {
        self.angle = angle
    }
    
    func setOffset(offset: CGSize) {
        self.offset = offset
    }
    
    func getOffset() -> CGSize {
        return offset
    }
    
    func getScale() -> CGFloat {
        return scale
    }
    
    func getAngle() -> Angle {
        return angle
    }
}

