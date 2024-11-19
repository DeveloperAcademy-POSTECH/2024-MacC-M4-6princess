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
    @StateObject var viewModel:IEViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack{
            topBar
            if let compositeImage = viewModel.compositeImage{
                Image(uiImage: compositeImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            
            
            if isSave {
                Image("check.save")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding()
                    .onAppear{
                        isAnimating = false
                    }
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
            Spacer()
        }
        .navigationBarBackButtonHidden()
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


extension IEProgressView {
    var topBar: some View {
        VStack{
            HStack {
                Spacer()
                    .frame(width: 10)
                Button {
                    // 뒤로가기 버튼
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(alignment: .center, spacing: 4) {
                        Group{
                            Image(systemName: "chevron.backward")
                                .fontWeight(.semibold)
                                .padding(.leading, 10)
                            Text("다시 찍기")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                        }
                        .foregroundColor(.gray01)
                    }
                }
                
                Spacer()
                
                
                
            }
            Spacer()
        }
        .frame(height: 40)
    }
}
