//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos

// 이미지 편집 메인 화면
struct IOView: View {
    var bg:UIImage
    var idol:UIImage
    @StateObject var viewModel = IEViewModel()
    @GestureState var pinchState = 1.0 // 핀치 제스쳐를 위한 State 변수
    @State var isAnimating = false
    @State var isSave = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack{
            Spacer()
            // 후보정 레이어 편집 뷰
            canvasView
                .onAppear{
                    isAnimating = true
                    viewModel.saveRenderedView(content: canvasView)
                    viewModel.saveAnimate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        //                                viewModel.savePhoto = true
                        isSave = true
                    }
                    print("canvasView onAppear")
                }
            //                    Spacer()
            //                    if isSave {
            //                        Image("check.save")
            //                            .resizable()
            //                            .scaledToFit()
            //                            .frame(width: 40, height: 40)
            //                            .padding()
            //                            .onAppear{
            //                                isAnimating = false
            //                            }
            //                        Text("갤러리에 저장완료!")
            //                            .foregroundColor(.pointPink)
            //                            .fontWeight(.bold)
            //
            //                    } else {
            //                        Circle()
            //                            .strokeBorder(style: StrokeStyle(lineWidth: 7, dash: [5]))
            //                            .frame(width: 40, height: 40)
            //                            .foregroundColor(.pointPink)
            //                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            //                            .animation(
            //                                Animation.linear(duration: 2)
            //                                    .repeatForever(autoreverses: false),
            //                                value: isAnimating
            //                            )
            //                            .padding()
            //                        Text("저장 중..")
            //                            .foregroundColor(.pointPink)
            //                            .fontWeight(.bold)
            //                    }
            
            VStack{
                Text("저장된 사진은 갤러리에서 확인해주세요.")
                    .font(.system(size:12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray01)
                    .padding()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 335, height: 60)
                        .background(Color.pointPink)
                        .cornerRadius(10)
                        .overlay(
                            Text("카메라로 이동")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        )
                }
                
                
            }
            .frame(height: (UIScreen.main.bounds.height-(UIScreen.main.bounds.width*4/3))/2)
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
            print("body onAppear")
        }
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
    }
}
