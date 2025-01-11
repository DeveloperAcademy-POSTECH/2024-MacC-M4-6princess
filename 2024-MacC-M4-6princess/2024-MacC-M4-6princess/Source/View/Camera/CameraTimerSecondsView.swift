import SwiftUI
import Combine

struct CameraTimerSecondsView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            if viewModel.remainingTime > 0 {
                Text("\(Int(viewModel.remainingTime))")
                    .font(.system(size: 200))
                    .foregroundColor(.white)
                    .opacity(viewModel.opacity)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.opacity)
                    .shadow(color: Color.black.opacity(0.4), radius: 10)
            }
        }
        .onAppear {
            startTimer()
        }
        .onChange(of: viewModel.remainingTime, initial: false) { oldValue, newValue in
            if newValue < viewModel.delayTime && newValue >= 0 {
                viewModel.showCountdown = true
                viewModel.opacity = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewModel.opacity = 0
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        viewModel.remainingTime = viewModel.delayTime
        
        timer = timerPublisher()
            .sink { [self] _ in
                if viewModel.remainingTime > 0 {
                    viewModel.remainingTime -= 1
                    viewModel.backgroundOpacity += (0.6 / viewModel.delayTime)
                    print("-1초 : 현재 남은 시간은 \(viewModel.remainingTime)")
                }
                if viewModel.remainingTime <= 0 {
                    timer?.cancel()
                    timer = nil
                    viewModel.opacity = 0
                    viewModel.backgroundOpacity = 0
                    viewModel.isTakePic = false
                }
            }
    }
    
    private func timerPublisher() -> AnyPublisher<Date, Never> {
        return Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
}
