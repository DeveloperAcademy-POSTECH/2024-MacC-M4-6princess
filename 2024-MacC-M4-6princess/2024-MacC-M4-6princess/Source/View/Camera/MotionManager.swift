//
//  MotionManager.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/14/24.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var currentOrientation: UIDeviceOrientation = .portrait
    private var lastUpdate: Date = Date()

    init() {
        startDeviceMotionUpdates()
    }

    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                guard let self = self, let attitude = data?.attitude else { return }
                
                // 일정 시간 간격으로 업데이트
                if Date().timeIntervalSince(self.lastUpdate) > 0.5 {
                    self.lastUpdate = Date()
                    self.updateOrientation(attitude: attitude)
                }
            }
        }
    }

    func rotationAngle(for orientation: UIDeviceOrientation) -> Angle {
        switch orientation {
        case .landscapeLeft:
            return .degrees(90)
        case .landscapeRight:
            return .degrees(-90)
        case .portrait:
            return .degrees(0)
        default:
            return .degrees(0)
        }
    }
    
    private func updateOrientation(attitude: CMAttitude) {
        if attitude.roll > .pi / 4 {
            currentOrientation = .landscapeRight
        } else if attitude.roll < -.pi / 4 {
            currentOrientation = .landscapeLeft
        } else {
            currentOrientation = .portrait
        }
    }
}
