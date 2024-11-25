//
//  CamSaveProgressView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/24/24.
//

import SwiftUI

struct CamSaveProgressView: View {
    @State var isAnimating = false
    @Binding var isSave: Bool
    @StateObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            if isSave {
                Image("check.save")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding()
                Text("갤러리에 저장완료!")
                    .foregroundColor(.pointPink)
                    .fontWeight(.bold)
            } else {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 7, dash: [5]))
                    .frame(width: 50, height: 50)
                    .foregroundColor(.pointPink)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .padding()
                Text("저장 중..")
                    .foregroundColor(.pointPink)
                    .fontWeight(.bold)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
