//
//  CameraTimerView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/4/24.
//

import SwiftUI

struct CameraTimerView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            // 배경 캡슐 - 확장 시 검정, 축소 시 흰색
            Capsule()
                .fill(isExpanded ? Color.black : Color.white)
                .frame(width: isExpanded ? 200 : 60, height: 30)
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
                    
                    Button("Off") {
                        viewModel.delayTime = 0
                        withAnimation(.spring(response: 0.2)) {
                            isExpanded = false
                        }
                    }
                    .font(.system(size: 13, weight: viewModel.delayTime == 0 ? .bold : .regular))
                    .foregroundColor(.white)
                    
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
                .padding(.horizontal, 16)
            } else {
                // 축소 시 기본 뷰
                HStack(spacing: 8) {
                    Image("timerBlack")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text(viewModel.delayTime == 0 ? "Off" : "\(Int(viewModel.delayTime))초")
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                }
                //                .padding(.horizontal, 16)
            }
        }
        .frame(width: isExpanded ? 200 : 100, height: 30)
        
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
