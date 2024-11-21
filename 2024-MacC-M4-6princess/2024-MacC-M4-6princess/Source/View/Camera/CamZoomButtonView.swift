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
    
    enum ZoomFactor: Double {
        case ultraWide = 1.0      // 화면에는 0.5x로 표시
        case wide = 2.0           // 화면에는 1x로 표시
        case telephoto = 3.0      // 화면에는 2x로 표시
        case maxZoom = 4.0        // 화면에는 3x로 표시
        
        var displayText: String {
            switch self {
            case .ultraWide: return "0.5x"
            case .wide: return "1x"
            case .telephoto: return "2x"
            case .maxZoom: return "3x"
            }
        }
        
        var displayValue: Double {
            switch self {
            case .ultraWide: return 0.5
            case .wide: return 1.0
            case .telephoto: return 2.0
            case .maxZoom: return 3.0
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if viewModel.cameraPosition == .back {
                ForEach(getAvailableZoomFactors(), id: \.self) { factor in
                    Button {
                        viewModel.setZoom(factor: factor.rawValue)
                        print("\(factor.displayText)로 설정됨")
                    } label: {
                        Text(factor.displayText)
                            .foregroundColor(viewModel.currentZoomFactor == factor.rawValue ? .yellow : .white)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .background {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getAvailableZoomFactors() -> [ZoomFactor] {
        if viewModel.cameraManager.deviceType == .builtInUltraWideCamera {
            return [.ultraWide, .wide, .telephoto, .maxZoom]
        } else {
            return [.wide, .telephoto, .maxZoom]
        }
    }
}
