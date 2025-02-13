//
//  CameraViewModel+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 2/13/25.
//

import SwiftUI
extension CameraViewModel {
    func focus(at point: CGPoint, in view: UIView) {
        guard let device = cameraManager.videoDeviceInput?.device else { return }
        
        // 화면 좌표를 카메라 좌표로 변환
        let focusPoint = CGPoint(
            x: point.x / view.bounds.width,
            y: point.y / view.bounds.height
        )
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
        } catch {
            print("초점 설정 오류: \(error.localizedDescription)")
        }
    }
}

