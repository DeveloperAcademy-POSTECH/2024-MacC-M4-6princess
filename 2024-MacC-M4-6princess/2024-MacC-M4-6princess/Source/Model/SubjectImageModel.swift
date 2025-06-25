import SwiftUI
import UIKit
import Foundation

class SubjectImage: Identifiable,NSCopying {
    
    var image: UIImage?
    var originalImage: UIImage?
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
   
    func getTapState() -> Bool {
        return isTapped
    }
    
    func isTappedToggle() {
        print(isTapped)
        isTapped.toggle()
        print(isTapped)
    }
    
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
        return max(scale,0.1)
    }
    
    func getAngle() -> Angle {
        return angle
    }
    func copy(with zone: NSZone? = nil) -> Any {
            let copy = SubjectImage()
            copy.image = self.image
            copy.originalImage = self.originalImage
            copy.maskImage = self.maskImage
            copy.sticker = self.sticker
            copy.text = self.text
            copy.textStyle = self.textStyle
            copy.angle = self.angle
            copy.offset = self.offset
            copy.scale = self.scale
            copy.originalText = self.originalText
            copy.isTapped = self.isTapped
            copy.isFullSticker = self.isFullSticker
            return copy
        }
}
