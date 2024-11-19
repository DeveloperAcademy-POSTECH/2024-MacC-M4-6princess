//
//  CamZoomButtonView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/12/24.
//

import SwiftUI

struct CamZoomButtonView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    // 후면 카메라 줌 팩터 배열
    let backCameraFactors: [Double] = [0.5, 1, 2, 3]
    // 전면 카메라 줌 팩터 배열
    let frontCameraFactors: [Double] = [0.5, 0.8, 1, 2, 3]
    
    var body: some View {
        HStack(spacing: 15) {
            if viewModel.cameraPosition == .front {
                // 후면 카메라일 때
                ForEach(getAvailableZoomFactors(), id: \.self) { factor in
                    Button {
                        viewModel.setZoom(factor: factor)
                    } label: {
                        Text(String(format: "%.1fx", factor))
                            .foregroundColor(viewModel.currentZoomFactor == factor ? .yellow : .white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            } else {
                // 전면 카메라일 때
                ForEach(frontCameraFactors, id: \.self) { factor in
                    Button {
                        viewModel.setZoom(factor: factor)
                    } label: {
                        
                        Image(systemName: factor == 0.8 ? "person.fill" : "person.2.fill")
                            .foregroundColor(viewModel.currentZoomFactor == factor ? .yellow : .white)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 사용 가능한 줌 팩터 배열 반환
    private func getAvailableZoomFactors() -> [Double] {
        if viewModel.cameraManager.deviceType == .builtInUltraWideCamera {
            return backCameraFactors
        } else {
            return Array(backCameraFactors.dropFirst()) // 0.5x 제외
        }
    }
}
