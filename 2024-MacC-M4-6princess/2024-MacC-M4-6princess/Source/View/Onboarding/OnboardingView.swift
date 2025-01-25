//
//  OnboardingView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 1/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStepIndex = 0
    @State private var dragOffset: CGSize = .zero
    @ObservedObject var viewModel : CameraViewModel
    private let steps = OnboardingStep.allCases
    
    enum OnboardingStep: Int, CaseIterable {
        case first, second, third, fourth
        
        var titleAndDescription: (String, String) {
            switch self {
            case .first:
                return ("최애와 함께 사진찍기", "불러오기 버튼을 이용해\n최애의 프레임을 선택해주세요.")
            case .second:
                return ("자동 배경 제거", "최애 사진을 불러오면 자동으로\n배경을 제거해줘요.")
            case .third:
                return ("다양한 꾸미기 기능", "꾸미기 기능을 이용하여 자유롭게\n프레임을 꾸며보세요.")
            case .fourth:
                return ("찍은 사진은 갤러리에 저장", "촬영된 사진은 갤러리로 이동합니다.\n갤러리를 확인해주세요.")
            }
        }
        
        var imageName: String {
            switch self {
            case .first:
                return "onboarding1"
            case .second:
                return "onboarding2"
            case .third:
                return "onboarding3"
            case .fourth:
                return "onboarding4"
            }
        }
    }
    var body: some View {
        let step = steps[currentStepIndex]
        let (title, description) = step.titleAndDescription
        
        ZStack {
            Image(step.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.2), value: currentStepIndex)
            
            VStack() {
                VStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.system(size: 24).weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(description)
                        .font(.system(size: 16).weight(.regular))
                        .multilineTextAlignment(.center)
                }
                .animation(.easeInOut(duration: 0.2), value: currentStepIndex)
                .padding(.top, 57)
                
                Spacer()
                
                // 점4개
                VStack(alignment: .center, spacing: 60) {
                    HStack(spacing: 15) {
                        ForEach(0..<steps.count) { index in
                            Rectangle()
                                .fill(index == currentStepIndex ? Color.gray01 : Color.gray10)
                                .cornerRadius(50)
                                .frame(width: index == currentStepIndex ? 14 : 8,
                                       height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentStepIndex)
                        }
                    }
                    
                    Button{
                        if currentStepIndex < steps.count - 1 {
                            currentStepIndex += 1
                        } else {
                            viewModel.firstTime = true
                            print("firstTime이 true 처리됨")
                        }
                    } label: {
                        Text("다음")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.pointPink)
                    .foregroundColor(.white)
                    .onTapGesture {
                        if currentStepIndex < steps.count - 1 {
                            currentStepIndex += 1
                        } else {
                            viewModel.firstTime = true
                            print("firstTime이 true 처리됨")
                        }
                    }
                }
            }
        }
        .background(Color.bgGray)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    
                    // 페이지 넘김 처리 임계값 결정
                    let threshold: CGFloat = 30
                    
                    if horizontalAmount < -threshold && currentStepIndex < steps.count - 1 {
                        // 왼쪽으로 스와이프(다음으로)
                        currentStepIndex += 1
                    } else if horizontalAmount > threshold && currentStepIndex > 0 {
                        // 오른쪽으로 스와이프(이전으로)
                        currentStepIndex -= 1
                    }
                    
                    dragOffset = .zero
                }
        )
    }
}

