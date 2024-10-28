//
//  IEProgressView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/16/24.
//

import SwiftUI

struct IEProgressView: View {
    @State var isAnimating = false
    @Binding var isSave:Bool
    
    var body: some View {
        VStack{
            if isSave {
                Image("check.save")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding()
                    .onAppear{
                        isAnimating = false
                    }
                Text("저장완료!")
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
                Text("저장중..")
                    .foregroundColor(.pointPink)
                    .fontWeight(.bold)
            }
        }
        .onAppear{
            isAnimating = true
            isSave = false
        }
        
        
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    var alpha: CGFloat = 0.5 // 기본 알파 값 설정
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView()
        return visualEffectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
        uiView.alpha = alpha // 알파 값 설정
    }
}

