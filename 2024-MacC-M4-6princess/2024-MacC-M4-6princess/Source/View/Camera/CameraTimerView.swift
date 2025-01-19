////
////  CameraTimerView.swift
////  2024-MacC-M4-6princess
////
////  Created by 김이예은 on 10/4/24.
////
//
import SwiftUI
//
struct CameraTimerView: View {
    @StateObject var motionManager = MotionManager()
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Button {
                viewModel.isPushedTimer = (viewModel.isPushedTimer + 1) % 4
                
                if let timerState = TimerState(rawValue: viewModel.isPushedTimer) {
                    viewModel.delayTime = timerState.duration
                }
            } label: {
                let currentState = TimerState(rawValue: viewModel.isPushedTimer) ?? .off
                
                ZStack {
                    Image(currentState.icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    if let text = currentState.displayText {
                        Text(text)
                            .font(.system(size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.gray01)
                    }
                }
                .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                .animation(.easeInOut, value: motionManager.currentOrientation)
            }
            
            Text("타이머")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray01)
        }
    }
}
