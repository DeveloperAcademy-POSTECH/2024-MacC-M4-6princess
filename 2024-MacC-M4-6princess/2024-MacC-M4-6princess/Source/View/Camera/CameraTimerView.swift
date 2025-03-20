import SwiftUI

struct CameraTimerView: View {
    @ObservedObject var viewModel: CameraViewModel
    @ObservedObject var motionManager: MotionManager
    @State private var isExpanded = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(isExpanded ? Color.black : Color.white)
                .frame(width: isExpanded ? 185 : 60, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .inset(by: 0.5)
                        .stroke(isExpanded ? Color.clear : Color.gray01, lineWidth: 1)
                )
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isExpanded)
            
            if isExpanded {
                // 확장 시 타이머 옵션들
                HStack(spacing: 16) {
                    Image("timerWhite")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                        .padding(.leading, 5) // 아이콘의 leading 패딩값
                    
                    Button("Off") {
                        viewModel.delayTime = 0
                        withAnimation(.spring(response: 0.2)) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    
                    Button("3초") {
                        viewModel.delayTime = 3
                        withAnimation(.spring(response: 0.2)) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    
                    Button("5초") {
                        viewModel.delayTime = 5
                        withAnimation(.spring(response: 0.2)) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    
                    Button("7초") {
                        viewModel.delayTime = 7
                        withAnimation(.spring(response: 0.2)) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                }
            } else {
                // 축소 뷰
                HStack(spacing: 8) {
                    Image("timerBlack")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                    
                    Text(viewModel.delayTime == 0 ? "Off" : "\(Int(viewModel.delayTime))초")
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                }
                .padding(5)
            }
        }
        // 왼쪽으로만 확장되도록 offset 적용
        .frame(width: isExpanded ? 185 : 60, height: 30, alignment: .leading)
        .contentShape(Capsule())
//        .offset(x: isExpanded ? -16 : 0)
        .onTapGesture {
            if !isExpanded {
                withAnimation(.spring(response: 0.2)) {
                    isExpanded = true
                }
            }
        }
    }
}
