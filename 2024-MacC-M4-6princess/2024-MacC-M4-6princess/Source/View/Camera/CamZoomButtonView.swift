import SwiftUI
import AVFoundation

struct CamZoomButtonView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    enum ZoomOption: Double {
            case ultraWide = 1.0
            case wide = 2.0
            case telephoto = 3.0
            case maxZoom = 4.0
            
            func displayText(for position: AVCaptureDevice.Position) -> String {
                if position == .back {
                    switch self {
                    case .ultraWide: return "0.5x"
                    case .wide: return "1x"
                    case .telephoto: return "2x"
                    case .maxZoom: return "3x"
                    }
                } else {
                    switch self {
                    case .ultraWide: return "1x"
                    case .wide: return "2x"
                    case .telephoto: return "3x"
                    case .maxZoom: return "3x"
                    }
                }
            }
            
            func zoomFactor(for position: AVCaptureDevice.Position) -> Double {
                if position == .back {
                    switch self {
                    case .ultraWide: return 0.5  // 0.5x
                    case .wide: return 1.0       // 1x
                    case .telephoto: return 2.0   // 2x
                    case .maxZoom: return 3.0     // 3x
                    }
                } else {
                    switch self {
                    case .ultraWide: return 1.0   // 1x
                    case .wide: return 2.0        // 2x
                    case .telephoto: return 3.0    // 3x
                    case .maxZoom: return 3.0      // 3x
                    }
                }
            }
        }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(availableZoomOptions, id: \.rawValue) { option in
                ZoomButton(
                    text: option.displayText(for: viewModel.cameraPosition),
                    isSelected: viewModel.currentZoomFactor == option.zoomFactor(for: viewModel.cameraPosition)
                ) {
                    viewModel.setZoom(factor: option.zoomFactor(for: viewModel.cameraPosition))
                    print("Zoomed to \(option.displayText(for: viewModel.cameraPosition))")
                }
            }
        }
        .padding(.horizontal)
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
}

struct ZoomButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(isSelected ? .yellow : .white)
                .font(.system(size: 13, weight: .semibold))
        }
        .background {
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: 30, height: 30)
        }
    }
}
