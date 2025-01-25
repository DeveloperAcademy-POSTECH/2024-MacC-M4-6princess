//
//  View+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/14/24.
//

import SwiftUI

struct RotateView: ViewModifier {
    let angle: Angle
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(angle, anchor: .center)
    }
}

struct RotatedAndScaledEffect: GeometryEffect {
    var angle: Angle
    var scale: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        // 뷰의 중심점 구하기
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // 중심점을 기준으로 회전 + 스케일
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: centerX, y: centerY)
        transform = transform.rotated(by: CGFloat(angle.radians))
        transform = transform.scaledBy(x: scale, y: scale)
        transform = transform.translatedBy(x: -centerX, y: -centerY)
        
        return ProjectionTransform(transform)
    }
}

extension View {
    func rotateView(angle: Angle) -> some View {
        self.modifier(RotateView(angle: angle))
    }
    
    func rotateAndScale(angle: Angle, scale: CGFloat = 1.0) -> some View {
            self.modifier(RotatedAndScaledEffect(angle: angle, scale: scale))
        }
    
    //모디파이어 적용 시 조건부적용이 가능하도록 - canvasView에서 사용중
    @ViewBuilder
        func applyIf<Transformed: View>(
            _ condition: Bool,
            transform: (Self) -> Transformed
        ) -> some View {
            if condition {
                transform(self)
            } else {
                self
            }
        }
}
