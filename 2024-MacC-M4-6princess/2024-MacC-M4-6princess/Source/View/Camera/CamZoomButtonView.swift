import SwiftUI
import AVFoundation
import Combine

struct CamZoomButtonView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    @State private var didApplyDefaultZoom = false
    
    struct ZoomStop: Identifiable, Hashable {
        let value: CGFloat        // 실제로 적용할 줌 값
        let displayValue: CGFloat // 사용자에게 보여줄 값
        var id: CGFloat { value }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(zoomStops) { stop in
                let target = stop.value
                let label = label(for: stop)
                ZoomButton(
                    text: label,
                    isSelected: isZoomSelected(stop: stop)
                ) {
                    viewModel.setZoom(factor: target)
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
        .onAppear {
            applyDefaultZoomIfNeeded()
        }
        .onChange(of: viewModel.cameraPosition) { _ in
            didApplyDefaultZoom = false
            applyDefaultZoomIfNeeded()
        }
        .onReceive(viewModel.cameraManager.$videoDeviceInput) { _ in
            didApplyDefaultZoom = false
            applyDefaultZoomIfNeeded()
        }
        .onReceive(viewModel.$currentZoomFactor) { _ in
            applyDefaultZoomIfNeeded()
        }
    }
    
    /// 줌 하이라이트 버튼 목록
    private var zoomStops: [ZoomStop] {
        let maxZoom = maxZoomFactor
        let scale = zoomValueScale
        var stops: [ZoomStop] = []
        
        if viewModel.cameraPosition == .back {
            let desiredStops: [CGFloat] = supportsUltraWideLens ? [0.5, 1.0, 2.0, 3.0] : [1.0, 2.0, 3.0]
            desiredStops.forEach { value in
                appendStop(value, scale: scale, to: &stops, maxZoom: maxZoom)
            }
        } else {
            [1.0, 2.0, 3.0].forEach { value in
                appendStop(value, scale: 1.0, to: &stops, maxZoom: maxZoom)
            }
        }
        
        return stops
    }
    
    /// 표시용 배율과 실제 적용 배율을 묶어서 스톱 배열에 추가
    private func appendStop(_ displayValue: CGFloat,
                            scale: CGFloat,
                            to stops: inout [ZoomStop],
                            maxZoom: CGFloat,
                            condition: Bool = true,
                            actualValue: CGFloat? = nil) {
        guard condition else { return }
        guard scale > 0 else { return }
        
        let targetValue = actualValue ?? (displayValue * scale)
        guard targetValue <= maxZoom + 0.01 else { return }
        
        if stops.first(where: { abs($0.value - targetValue) < 0.05 }) == nil {
            stops.append(ZoomStop(value: targetValue, displayValue: displayValue))
        }
    }
    
    /// 줌 배율을 받아서 .5, 1, 2, 3 중에 가까운 값으로 표시
    private func label(for stop: ZoomStop) -> String {
        let value = stop.displayValue
        if abs(value - 0.5) < 0.01 {
            return ".5"
        }
        
        if abs(value.rounded() - value) < 0.05 {
            return "\(Int(value.rounded()))"
        }
        
        return String(format: "%.1f", value)
    }
    
    /// 현재 줌이 해당 스톱과 가까운지를 표시용 배율 기준으로 판별(하이라이트를 윟해)
    private func isZoomSelected(stop: ZoomStop) -> Bool {
        let tolerance: CGFloat = 0.15
        let currentDisplay = currentDisplayZoom
        if abs(currentDisplay - stop.displayValue) < tolerance {
            return true
        }
        let isLastStop = zoomStops.last?.id == stop.id
        return currentDisplay > stop.displayValue && isLastStop
    }
    
    /// 초광각 렌즈 활성화 여부 검사
    private var supportsUltraWideLens: Bool {
        guard viewModel.cameraPosition == .back else { return false }
        return viewModel.cameraManager.hasUltraWideLens
    }
    
    /// 최대 배율 값
    private var maxZoomFactor: CGFloat {
        min(viewModel.cameraManager.maxAvailableZoomFactor, 15.0)
    }
    
    /// 실제 배율을 보여주는 배율 값으로 변환
    private var zoomValueScale: CGFloat {
        guard supportsUltraWideLens else { return 1.0 }
        let actualUltraWide = viewModel.cameraManager.minAvailableZoomFactor
        let desiredUltraWide: CGFloat = 0.5
        
        guard actualUltraWide > 0 else { return 1.0 }
        if abs(actualUltraWide - desiredUltraWide) < 0.01 {
            return 1.0
        }
        
        return max(1.0, actualUltraWide / desiredUltraWide)
    }
    
    /// (광각 지원하는 경우) 보이는 줌 기준 1x로 강제 줌 해버림. default가 1x로 보이게
    private func applyDefaultZoomIfNeeded() {
        guard !didApplyDefaultZoom else { return }
        guard viewModel.cameraManager.videoDeviceInput?.device != nil else { return }
        guard let defaultStop = zoomStops.first(where: { abs($0.displayValue - 1.0) < 0.01 }) else { return }
        if abs(currentDisplayZoom - defaultStop.displayValue) <= 0.05 {
            didApplyDefaultZoom = true
            return
        }
        viewModel.setZoom(factor: defaultStop.value)
    }
    
    /// 실제 디바이스 줌을 표시용 배율 기준으로 환산
    private var currentDisplayZoom: CGFloat {
        let scale = viewModel.cameraPosition == .back ? zoomValueScale : 1.0
        let currentActualZoom = viewModel.cameraManager.videoDeviceInput?.device.videoZoomFactor ?? viewModel.currentZoomFactor
        guard scale > 0 else { return currentActualZoom }
        return currentActualZoom / scale
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
