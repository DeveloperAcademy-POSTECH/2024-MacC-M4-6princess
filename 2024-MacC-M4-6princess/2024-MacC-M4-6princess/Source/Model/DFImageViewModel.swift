import SwiftUI

class DFImageViewModel: ObservableObject {
    
    @Published var magnifyScale = 1.0
    @Published var lastScale = 1.0
    @Published var current: Angle = .degrees(0)
    @Published var draggedOffSet: CGSize = .zero
    @Published var accumulatedOffSet: CGSize = .zero
    @Published var angle: Angle = .degrees(0)
    @Published var isTappedImage: Bool = false
    @Published var isPushedDeleteButton: Bool = false
    
    @Published var width: CGFloat = .zero
    @Published var height: CGFloat = .zero
    
    func setSizeCompute(_ image: UIImage) {
        
        self.width = image.size.width
        self.height = image.size.height
    }
    
    ///최대 최소 스케일을 정해주는 메소드
    func setScaleValue(minimum: CGFloat, maximum: CGFloat) {
        
        if magnifyScale < minimum {
            magnifyScale = minimum
            
        } else if magnifyScale > maximum {
            magnifyScale = maximum
        }
        lastScale = 1.0
        
    }
    
    ///스케일의 변화량(속도) 을 동일하게 하기 위한 메소드
    func setScaleVolume(_ magnify: CGFloat) {
        
        let scaleVolume = magnify / lastScale
        magnifyScale *= scaleVolume
        lastScale = magnify
    }
    
    ///각 이미지의 스케일을 계산해주는 메소드
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
    
    func OffsetCompute(x: CGFloat, y: CGFloat) -> CGSize {
        
        let computedX = x * CGFloat(cos(angle.degrees * (Double.pi / 180.0))) - y * sin(angle.degrees * (Double.pi / 180.0))
        let computedY = x * CGFloat(sin(angle.degrees * (Double.pi / 180.0))) + y * cos(angle.degrees * (Double.pi / 180.0))

        
        let width = computedX * magnifyScale + draggedOffSet.width
        let height = computedY * magnifyScale + draggedOffSet.height
        
        return CGSize(width: width, height: height)
    }
    
}
