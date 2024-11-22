import SwiftUI

struct subjectImage: Hashable { //@@struct인데 왜 소문자로 시작하나요?
    
    var image: UIImage?
    var angle: Angle = .degrees(0)
    var offSet: CGSize = .zero
    var scale: CGFloat = .zero
    
}
