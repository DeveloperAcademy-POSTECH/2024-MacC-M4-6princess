//
//  MotionManager.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/14/24.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    @Published var currentOrientation: UIDeviceOrientation = .portrait //이걸 model로 따로 빼기
    private var motionManager = CMMotionManager()
    private var lastUpdate: Date = Date()

    init() {
        startDeviceMotionUpdates()
    }

    //코어 모션 인식을 시작하는 함수
    func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                guard let self = self, let attitude = data?.attitude else { return }
                
                // 일정 시간 간격으로 업데이트
                if Date().timeIntervalSince(self.lastUpdate) > 0.5 {
                    self.lastUpdate = Date()
                    self.updateOrientation(attitude: attitude)
                    print("지금 상태는 \(currentOrientation) 방향")
//                    print("yaw: \(attitude.yaw)")
                    
                }
            }
        }
    }

    //카메라뷰 아이콘 회전을 위한 함수
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
    
    //기기의 yaw 값을 받아서 디바이스의 방향을 설정
    private func updateOrientation(attitude: CMAttitude) {
        if abs(attitude.yaw) > 0 && abs(attitude.yaw) < 1 {
            currentOrientation = .portrait //정방향
        } else if trunc(attitude.yaw) == -1 {
            currentOrientation = .landscapeRight //전면 카메라가 오른쪽에 있고 가로로 놓여진 상태
        } else if trunc(attitude.yaw) == 1 {
            currentOrientation = .landscapeLeft //전면 카메라가 왼쪽에 있고 가로로 놓여진 상태
        } else {
            currentOrientation = .portraitUpsideDown //전면 카메라가 거꾸로 된 상태
        }
    }
}
