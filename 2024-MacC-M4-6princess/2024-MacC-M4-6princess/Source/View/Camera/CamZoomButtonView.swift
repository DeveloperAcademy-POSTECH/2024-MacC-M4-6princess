import SwiftUI
import AVFoundation

struct CamZoomButtonView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    enum ZoomOption: Double {
        case ultraWide = 1.0  // 실제 줌 팩터값은 1.0으로 유지
        case wide = 2.0
        case telephoto = 3.0
        case maxZoom = 4.0
        
        func isSelected(viewModel: CameraViewModel) -> Bool {
            let factor = viewModel.currentZoomFactor
            let isUltraWide = viewModel.cameraManager.deviceType == .builtInUltraWideCamera
            
            switch self {
            case .ultraWide:
                return isUltraWide && factor == 1.0
            case .wide:
                return (!isUltraWide && factor == 1.0) || (isUltraWide && factor == 2.0)
            case .telephoto:
                return factor == 3.0
            case .maxZoom:
                return factor == 4.0
            }
        }
        
//        func displayText(for position: AVCaptureDevice.Position) -> String {
//            if position == .back {
//                switch self {
//                case .ultraWide: return ".5"  // 표시만 0.5x
//                case .wide: return "1"
//                case .telephoto: return "2"
//                case .maxZoom: return "3"
//                }
//            } else {
//                switch self {
//                case .ultraWide: return "1"
//                case .wide: return "2"
//                case .telephoto: return "3"
//                case .maxZoom: return "3"
//                }
//            }
//        }
        func displayText(for position: AVCaptureDevice.Position, currentZoom: CGFloat, isUltraWide: Bool) -> String {
                if position == .back {
                    if isUltraWide {
                        // UltraWide 카메라일 때의 표시 로직
                        switch currentZoom {
                        case 1.0..<1.9:  // 실시간 줌 팩터 표시
                            return String(format: "%.1f", currentZoom/2)
                        case 1.9..<2.9:  // 1x 표시 구간
                            return "1"
                        case 2.9..<3.9:  // 2x 표시 구간
                            return "2"
                        default:         // 3x 표시 구간
                            return "3"
                        }
                    } else {
                        switch currentZoom {
                        case 1.0..<1.9:
                            return "1"
                        case 1.9..<2.9:
                            return "2"
                        default:
                            return "3"
                        }
                    }
                } else {
                    switch self {
                    case .ultraWide: return "1"
                    case .wide: return "2"
                    case .telephoto: return "3"
                    case .maxZoom: return "3"
                    }
                }
            }
        
        func zoomFactor(for position: AVCaptureDevice.Position) -> Double {
            if position == .back {
                switch self {
                case .ultraWide: return 1.0  // 실제 줌 팩터는 1.0 유지
                case .wide: return 2.0
                case .telephoto: return 3.0
                case .maxZoom: return 4.0
                }
            } else {
                switch self {
                case .ultraWide: return 1.0
                case .wide: return 2.0
                case .telephoto: return 3.0
                case .maxZoom: return 3.0
                }
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(availableZoomOptions, id: \.rawValue) { option in
                ZoomButton(
                    text: option.displayText(for: viewModel.cameraPosition,
                                             currentZoom: isZoomSelected(option: option, currentZoom: viewModel.currentZoomFactor) ? viewModel.currentZoomFactor : option.zoomFactor(for: viewModel.cameraPosition),
                                             isUltraWide: viewModel.cameraManager.deviceType == .builtInUltraWideCamera),
                    isSelected: isZoomSelected(option: option, currentZoom: viewModel.currentZoomFactor)
                ) {
                    viewModel.setZoom(factor: option.zoomFactor(for: viewModel.cameraPosition))
                }
                .frame(width: 24, height: 24)
                .padding(.vertical, 8)
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 11)
        .background(.black.opacity(0.2))
        .cornerRadius(19)
        .padding(.bottom, 20)
    }
    
    private var availableZoomOptions: [ZoomOption] {
        let isUltraWide = viewModel.cameraManager.deviceType == .builtInUltraWideCamera
        let isBackCamera = viewModel.cameraPosition == .back
        
        if isBackCamera {
            return isUltraWide ?
            [.ultraWide, .wide, .telephoto, .maxZoom] :
            [.wide, .telephoto, .maxZoom]
        } else {
            return [.ultraWide, .wide, .telephoto]
        }
    }
    private func isZoomSelected(option: ZoomOption, currentZoom: CGFloat) -> Bool {
        let isUltraWide = viewModel.cameraManager.deviceType == .builtInUltraWideCamera
        
        if viewModel.cameraPosition == .back {
            if isUltraWide {
                switch option {
                case .ultraWide: return currentZoom >= 1.0 && currentZoom < 1.9
                case .wide: return currentZoom >= 1.9 && currentZoom < 2.9
                case .telephoto: return currentZoom >= 2.9 && currentZoom < 3.9
                case .maxZoom: return currentZoom >= 3.9
                }
            } else {
                switch option {
                case .wide: return currentZoom >= 1.0 && currentZoom < 1.9
                case .telephoto: return currentZoom >= 1.9 && currentZoom < 2.9
                case .maxZoom: return currentZoom >= 2.9
                default: return false
                }
            }
        } else {
            return currentZoom == option.rawValue
        }
    }
}

struct ZoomButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            Text(isSelected ? text + "x" : text)
                .foregroundColor(isSelected ? .yellow : .white)
                .font(.system(size: isSelected ? 13 : 12, weight: isSelected ? .semibold : .regular))
        }
        .background {
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: isSelected ? 30 : 24, height: isSelected ? 30 : 24)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}
