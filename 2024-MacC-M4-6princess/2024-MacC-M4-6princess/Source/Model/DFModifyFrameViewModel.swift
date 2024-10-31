import SwiftUI

class DFModifyFrameViewModel: ObservableObject {
    
    @Published var btnOpacity: Double = 0.0
    @Published var imageHistory: [UIImage?] = []
    @Published var indexOfHistory: Int = 0
    @Published var currentSize = 0.0
    @Published var finalSize = 1.0
    @Published var currentAngle = Angle.zero
    @Published var finalAngle = Angle.zero
    @Published var draggedOffset = CGSize.zero
    @Published var accumulatedOffset = CGSize.zero
    @Published var image: UIImage?
    @Published var isShowCamera: Bool = false
    
}
