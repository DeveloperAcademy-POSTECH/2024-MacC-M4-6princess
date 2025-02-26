//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos
import FirebaseAnalytics

// 이미지 편집 메인 화면
struct IOView: View {
    var bg:UIImage
    var idol:UIImage
    let motionManager: MotionManager
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = IOViewModel()
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                    HStack(alignment: .center, spacing: 14) {
                        Text("저장완료")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
                    .padding(.top, 26)
                }
                else{
                    HStack(alignment: .center, spacing: 14) {
                        Text("저장완료")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
                    .padding(.top, 26)
                }
                
                // 후보정 레이어 편집 뷰
                canvasView
                    .onAppear{
                        viewModel.saveRenderedView(content: canvasView, motionManager: motionManager) // 사진을 그리면서 동시에 저장
                        viewModel.saveAnimate = true
                        print("canvasView onAppear")
                    }
                    .applyIf(motionManager.currentOrientation != .portrait && motionManager.currentOrientation != .portraitUpsideDown) { original in
                        original.modifier(
                            RotatedAndScaledEffect(
                                angle: motionManager.rotationAngleCanvasView(for: motionManager.currentOrientation),
                                scale: 0.75  //하드코딩 수정필요
                            )
                        )
                    }
                    .scaledToFit()
                Spacer()
                
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                    VStack(alignment: .center, spacing: 8){
                        Text("저장된 사진은 갤러리에서 확인해주세요.")
                            .font(.system(size:12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                        HStack{
                            // 카메라로 이동 버튼
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 60)
                                    .background(Color.pointPink)
                                    .cornerRadius(10)
                                    .overlay(
                                        Text("카메라로 이동")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    )
                            }
                            Button(action: {
                                viewModel.isShowShareSheet = true
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 60)
                                    .background(Color.pointPink)
                                    .cornerRadius(10)
                                    .overlay(
                                        Text("SNS 공유")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        
                    }
                }
                else{
                    VStack(alignment: .center, spacing: 8){
                        Text("저장된 사진은 갤러리에서 확인해주세요.")
                            .font(.system(size:12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                            .padding(5)
                        HStack{
                            // 카메라로 이동 버튼
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 40)
                                    .background(Color.pointPink)
                                    .cornerRadius(10)
                                    .overlay(
                                        Text("카메라로 이동")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    )
                            }
                            Button(action: {
                                viewModel.isShowShareSheet = true
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 40)
                                    .background(Color.pointPink)
                                    .cornerRadius(10)
                                    .overlay(
                                        Text("SNS 공유")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        
                    }
                }
            }
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
            viewModel.canvasOnAppear(bgImg: bg, idolImg: idol, bounds: UIScreen.main.bounds.size)
            Analytics.logEvent("A6_사진저장", parameters: nil)
            
            print("body onAppear")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        .sheet(isPresented: $viewModel.isShowShareSheet){
            IOSNSView(viewModel: viewModel)
                .presentationDetents([.height(300)])
        }
        
        
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
    }
}




