//
//  IEIntroView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/16/24.
//

import SwiftUI

struct IEIntroView: View {
    var bg: UIImage
    var idol: UIImage
    var splash = UIImage(named: "imageEditSplash")!
    @State var isMain = false
    @StateObject var viewModel = IEViewModel()
    var body: some View {
        VStack {
            ZStack{
                if !viewModel.saveAnimate{
                    IEMainView(bg: bg, idol: idol, viewModel: viewModel)
                    //                                    Image(uiImage: bg)
                    //                                        .resizable()
                    
                    if !isMain{ // 온보딩
                        ZStack{
                            Color.black.opacity(0.7)
                            //                                    .blur(radius: 5)
                            //                            VisualEffectView(effect: UIBlurEffect(style: .light))
                            VisualEffectView(effect: UIBlurEffect(style: .dark), alpha: 0.6)
                                .ignoresSafeArea()
                            VStack{
                                Image(uiImage: splash)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .aspectRatio(contentMode: .fill)
                                
                                Button(action: {
                                    isMain = true
                                }) {
                                    Text("닫기")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal,40)
                                        .padding(.vertical,8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 17)
                                                .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                            
                                        )
                                    
                                        .cornerRadius(17)
                                }
                                .padding(.vertical,30)
                                
                            }
                        }
                        .ignoresSafeArea(.all)
                        .navigationBarHidden(true)
                    }
                }
                else{ // 저장시 애니매이션 뷰
                    IEProgressView(isSave: $viewModel.savePhoto)
                }
            }
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
