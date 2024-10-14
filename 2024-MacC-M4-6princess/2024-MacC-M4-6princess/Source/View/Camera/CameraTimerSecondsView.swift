import SwiftUI
import Combine

struct CameraTimerSecondsView: View {
    @Binding var delayTime: TimeInterval
    @Binding var isTakePic : Bool
    @State private var remainingTime: TimeInterval = 0
    @State private var backgroundOpacity: Double = 0
    @State private var opacity: Double = 1
    @State private var showCountdown: Bool = true
    @State private var timer: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
            
            if remainingTime > 0 {
                Text("\(Int(remainingTime))")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .opacity(opacity) // 텍스트의 투명도 설정
                    .animation(.easeInOut(duration: 0.2), value: opacity) // opacity 애니메이션
            }
            
            
        }
        .onAppear {
            startTimer()
        }
        .onChange(of: remainingTime) { newValue in
            if newValue < delayTime && newValue >= 0 {
                showCountdown = true
                opacity = 1 // 매 초마다 opacity를 1로 초기화
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return } // 이미 타이머가 실행 중이면 종료
        remainingTime = delayTime
        
        timer = timerPublisher()
            .sink { [self] _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                    backgroundOpacity += (0.6 / delayTime) // 배경 투명도 증가
                    print("-1초 : 현재 남은 시간은 \(remainingTime)")
                }
                if remainingTime <= 0 {
                    timer?.cancel() // 남은 시간이 0 이하일 때 타이머를 취소
                    timer = nil // 타이머를 nil로 설정
                    opacity = 0 // 카운트다운 숨기기
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

