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
    @ObservedObject var viewModel: CameraViewModel
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            // 배경 캡슐 - 확장 시 검정, 축소 시 흰색
            Capsule()
                .fill(isExpanded ? Color.black.opacity(0.7) : Color.white)
                .frame(width: isExpanded ? 240 : 100, height: 40)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isExpanded)
            
            HStack(spacing: 8) {
                // 항상 왼쪽에 고정된 타이머 아이콘
                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundColor(isExpanded ? .white : .black)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                
                // 현재 선택된 타이머 설정
                Text(viewModel.delayTime == 0 ? "Off" : "\(Int(viewModel.delayTime))초")
                    .font(.system(size: 13))
                    .foregroundColor(isExpanded ? .white : .black)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                
                if isExpanded {
                    Spacer(minLength: 8)
                    
                    // 타이머 옵션들 (확장 시에만 표시)
                    HStack(spacing: 12) {
                        Button("3초") {
                            viewModel.delayTime = 3
                            withAnimation(.spring(response: 0.2)) {
                                isExpanded = false
                            }
                        }
                        .font(.system(size: 13, weight: viewModel.delayTime == 3 ? .bold : .regular))
                        .foregroundColor(.white)
                        
                        Button("5초") {
                            viewModel.delayTime = 5
                            withAnimation(.spring(response: 0.2)) {
                                isExpanded = false
                            }
                        }
                        .font(.system(size: 13, weight: viewModel.delayTime == 5 ? .bold : .regular))
                        .foregroundColor(.white)
                        
                        Button("7초") {
                            viewModel.delayTime = 7
                            withAnimation(.spring(response: 0.2)) {
                                isExpanded = false
                            }
                        }
                        .font(.system(size: 13, weight: viewModel.delayTime == 7 ? .bold : .regular))
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(width: isExpanded ? 240 : 100, height: 40)
        }
        .contentShape(Capsule())
        .onTapGesture {
            if !isExpanded {
                withAnimation(.spring(response: 0.2)) {
                    isExpanded = true
                }
            }
        }
    }
}
