import SwiftUI


class SubjectImage: Identifiable {
    
    // ✅ 원본 이미지는 필요할 때만 저장
    private var _originalImage: UIImage?
    var originalImage: UIImage? {
        get { _originalImage }
        set {
            // 축소된 버전만 저장
            if let newImage = newValue {
                _originalImage = resizeImage(newImage, maxDimension: 2048)
            } else {
                _originalImage = nil
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            // ✅ 이미지 설정 시 자동으로 축소
            if let img = image, max(img.size.width, img.size.height) > 2048 {
                image = resizeImage(img, maxDimension: 2048)
            }
        }
    }
    
    var maskImage: UIImage?
    var sticker: UIImage?
    var text: UIImage?
    var textStyle: TextStyle?
    var angle: Angle = .degrees(0)
    var offset: CGSize = .zero
    var scale: CGFloat = 1.0
    var originalText: String = ""
    var isTapped: Bool = true
    let id: UUID = UUID()
    var isFullSticker = false
    
    // ✅ 이미지 리사이즈 헬퍼
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSize = max(size.width, size.height)
        
        guard maxSize > maxDimension else { return image }
        
        let scale = maxDimension / maxSize
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // 기존 메서드들...
    func setScale(scale: CGFloat) { self.scale = scale }
    func setAngle(angle: Angle) { self.angle = angle }
    func setOffset(offset: CGSize) { self.offset = offset }
    func getOffset() -> CGSize { return offset }
    func getScale() -> CGFloat { return max(scale, 0.1) }
    func getAngle() -> Angle { return angle }
}
