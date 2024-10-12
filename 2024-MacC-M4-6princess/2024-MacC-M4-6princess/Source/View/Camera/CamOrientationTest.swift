//
//  CameraOrientationTest.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/8/24.
//

import SwiftUI

struct CameraOrientationTest: ViewModifier {
    @Binding var orientation: UIDeviceOrientation
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
        
    }
}

