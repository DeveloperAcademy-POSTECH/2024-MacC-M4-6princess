import SwiftUI

class DFOverlayBoxViewModel: ObservableObject {
    
    @Published var width: CGFloat = .zero
    @Published var height: CGFloat = .zero
    @Published var isPushedZoom: Bool = false
    
    func OffsetCompute(x: CGFloat, y: CGFloat, subject: SubjectImage) -> CGSize {
        
        let computedX = x * CGFloat(cos(subject.getAngle().degrees * (Double.pi / 180.0))) - y * sin(subject.getAngle().degrees * (Double.pi / 180.0))
        let computedY = x * CGFloat(sin(subject.getAngle().degrees * (Double.pi / 180.0))) + y * cos(subject.getAngle().degrees * (Double.pi / 180.0))

        
        let width = computedX * subject.getScale() + subject.getOffset().width
        let height = computedY * subject.getScale() + subject.getOffset().height
        
        return CGSize(width: width, height: height)
    }
    
    func scaleCompute(_ image: UIImage) -> CGFloat {
        
        var scale: CGFloat = image.size.height / (UIScreen.main.bounds.width * 4/3)
        
        
        if image.size.width / scale > UIScreen.main.bounds.width || image.size.width >= image.size.height {
            scale = image.size.width / UIScreen.main.bounds.width
        }
        return scale
    }
}
