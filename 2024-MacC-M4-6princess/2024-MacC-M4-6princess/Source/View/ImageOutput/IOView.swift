//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos
import FirebaseAnalytics
import UIKit
import LinkPresentation
import GoogleMobileAds
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
//                    Spacer()
                    HStack(alignment: .center, spacing: 14) {
                        Text("갤러리에 저장되었습니다")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
                    .padding(.vertical,10)
                    
                 
                    Spacer()
                    
                }
                else{
                    HStack(alignment: .center, spacing: 14) {
                        Text("갤러리에 저장되었습니다")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
//                    .padding(.top, 26)
                }
                
                // 후보정 레이어 편집 뷰
                canvasView
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3)
                    .onAppear{
                        viewModel.currentOrientation = motionManager.currentOrientation
                        viewModel.renderAndSaveViewImage(content: canvasView, motionManager: motionManager, orientation: viewModel.currentOrientation) // 사진을 그리면서 동시에 저장
                        motionManager.stopDeviceMotionUpdates()
                        viewModel.saveAnimate = true
                        print("canvasView onAppear")
                    }
//                    .applyIf(motionManager.currentOrientation != .portrait && motionManager.currentOrientation != .portraitUpsideDown) { original in
//                        original.modifier(
//                            RotatedAndScaledEffect(
//                                angle: motionManager.rotationAngleCanvasView(for: motionManager.currentOrientation),
//                                scale: 0.75  //하드코딩 수정필요
//                            )
//                        )
//                    }
                    .scaledToFit()
                
                
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                  
                    VStack(alignment: .center, spacing: 8){
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
                                
                                //                                viewModel.showShareButton.toggle()
                                viewModel.changeOverlay = true
                            }) {
                                Image("share.icon")
                                    .resizable()
                                    .frame(width:60,height: 60)
                                
                                
                            }
                        }
                        .frame(maxWidth: .infinity)
                        //                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        .padding(.vertical,10)
                      
                        IOBottomBannerAdMob(currentOrientationAnchoredAdaptiveBanner(width:UIScreen.main.bounds.width))
                            .ignoresSafeArea(.all)
                        
                        
                        
                    }
                   
                }
                else{
                    VStack(alignment: .center, spacing: 8){
//                        Text("저장된 사진은 갤러리에서 확인해주세요.")
//                            .font(.system(size:12))
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.gray01)
//                            .padding(5)
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
                                viewModel.showShareButton = true
                            }
                            ) {
                                Image("share.icon")
                                    .resizable()
                                    .frame(width:40,height: 40)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        //                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        IOBottomBannerAdMob(currentOrientationAnchoredAdaptiveBanner(width:UIScreen.main.bounds.width))
                        Spacer()
                        
                        
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
        .sheet(isPresented: $viewModel.showShareButton) {
            BottomSheetWrapper(viewModel: viewModel)
                .presentationDetents([.height(200)])
        }
        .onChange(of: viewModel.showShareButton) {
            if viewModel.showShareButton == false && viewModel.showAcitivity == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.changeOverlay = true
                }
            }
        }


        .overlay(
            Group {
                
                if viewModel.changeOverlay, let photo = viewModel.compositeImage {
                    IOShareSheet(isPresented: $viewModel.changeOverlay, shareData: (photo, "title", "Frameet으로 사진 찍어왔음"))
                        .onAppear{
                            print("sharesheet start")
                        }
                }
            }
        )
        .navigationBarBackButtonHidden()
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
    }
}
import UIKit

extension UIApplication {
    /// 현재 포그라운드에 활성화된 씬의 keyWindow를 반환
    var keyWindowInForeground: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
