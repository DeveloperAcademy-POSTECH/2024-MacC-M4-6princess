//
//  UIIamge+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 1/23/25.
//


import SwiftUI

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
            let cgImage = self.cgImage!
            let width = cgImage.width
            let height = cgImage.height
            
            let imageBounds = CGRect(x: 0, y: 0, width: width, height: height)
            let rotatedBounds = imageBounds.applying(CGAffineTransform(rotationAngle: radians))
            
            UIGraphicsBeginImageContext(rotatedBounds.size)
            let context = UIGraphicsGetCurrentContext()!
            
            // 중심점으로 이동
            context.translateBy(x: rotatedBounds.width/2, y: rotatedBounds.height/2)
            context.rotate(by: radians)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.draw(cgImage, in: CGRect(x: -width/2, y: -height/2, width: width, height: height))
            
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return rotatedImage
        }
}

