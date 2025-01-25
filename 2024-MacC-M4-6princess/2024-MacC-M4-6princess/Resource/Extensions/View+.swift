//
//  View+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/14/24.
//

import SwiftUI

//extension UIImage {
//    func rotate(orientation: UIDeviceOrientation) -> UIImage? {
//        var angle: CGFloat = 0.0
//        
//        switch orientation {
//        case .landscapeLeft:
//            angle = .pi / 2
//        case .landscapeRight:
//            angle = -.pi / 2
//        case .portrait:
//            angle = 0
//        default:
//            return self
//        }
//        
//        UIGraphicsBeginImageContext(self.size)
//        let context = UIGraphicsGetCurrentContext()
//        context?.translateBy(x: self.size.width / 2, y: self.size.height / 2)
//        context?.rotate(by: angle)
//        context?.translateBy(x: -self.size.width / 2, y: -self.size.height / 2)
//        self.draw(in: CGRect(origin: .zero, size: self.size))
//        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return rotatedImage
//    }
//}

struct RotateView: ViewModifier {
    let angle: Angle
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(angle, anchor: .center)
    }
}

extension View {
    func rotateView(angle: Angle) -> some View {
        self.modifier(RotateView(angle: angle))
    }
}
