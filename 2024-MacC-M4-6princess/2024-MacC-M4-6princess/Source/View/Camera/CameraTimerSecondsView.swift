import SwiftUI
import Combine

struct CameraTimerSecondsView: View {
    @Binding var delayTime: TimeInterval
    @Binding var isTakePic: Bool
    @State private var remainingTime: TimeInterval = 0
    @State private var backgroundOpacity: Double = 0
    @State private var opacity: Double = 1
    @State private var showCountdown: Bool = true
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            if remainingTime > 0 {
                Text("\(Int(remainingTime))")
                    .font(.system(size: 200))
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 0.2), value: opacity)
                    .shadow(color: Color.black.opacity(0.4), radius: 10)
            }
        }
        .onAppear {
            startTimer()
        }
        .onChange(of: remainingTime, initial: false) { oldValue, newValue in
            if newValue < delayTime && newValue >= 0 {
                showCountdown = true
                opacity = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        remainingTime = delayTime
        
        timer = timerPublisher()
            .sink { [self] _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                    backgroundOpacity += (0.6 / delayTime)
                    print("-1초 : 현재 남은 시간은 \(remainingTime)")
                }
                if remainingTime <= 0 {
                    timer?.cancel()
                    timer = nil
                    opacity = 0
                    backgroundOpacity = 0
                    isTakePic = false
                }
            }
    }
    
    private func timerPublisher() -> AnyPublisher<Date, Never> {
        return Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
}
