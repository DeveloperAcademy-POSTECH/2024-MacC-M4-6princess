//
//  OnboardingView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 1/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var naviManager: NavigationManager
    @State var isScreenUp: Bool = false
    var body: some View {
        VStack {
            Image("onboardingLogo")
                .resizable()
                .frame(width: 285, height: 348)
                .padding(.bottom, 123)
            
            Text("최애의 사진으로\n나만의 프레임을 만들어보세요")
                .font(.body)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 28)
            
            Button {
                naviManager.push(screen: Screen.photoPicker)
                
            } label: {
                Text("시작하기")
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 89)
                    .padding(.vertical, 19)
            }
            .background(Color.pointPink)
            .cornerRadius(10)
            
        }
        
    }
    
}

