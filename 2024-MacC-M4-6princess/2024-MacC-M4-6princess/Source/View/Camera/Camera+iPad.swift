//
//  Camera+iPad.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/12/24.
//

import Foundation
import SwiftUI
import FirebaseAnalytics
extension CameraTopView{
    var cameraIPadTopView: some View {
        HStack() {
            Spacer()
            CameraTimerView(viewModel: viewModel, motionManager: motionManager)
            Button {
                viewModel.changeCamera()
            } label: {
                Image("cameraReverseIcon")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                    .animation(.easeInOut, value: motionManager.currentOrientation)
                
            }
            .padding(.trailing, 20)
        }
        .frame(width: UIScreen.main.bounds.width, height: 46)
        .background(.white)
        
    }
}

extension CameraBottomView {
    
    // iPad 전용 뷰 변수
    var cameraIPadBottomView: some View {
        VStack{
            Spacer()
            ZStack {
                FilteredImageView(viewModel: viewModel)
                    .environmentObject(frameManager)
                    .environmentObject(imageModel)
                    .padding(.bottom)
                HStack {
                    //새 프레임 만들기 버튼
                    Button {
                        print("Button tapped")
                        naviManager.push(screen: Screen.photoPicker)
                        
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image("newFrameIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                .animation(.easeInOut, value: motionManager.currentOrientation)
                            Text("새 프레임")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.leading, 20)
//                    .frame(width: 70, height: 70)
                    .background(.white)
                    
                    Spacer()
                }
            }
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: 60)
        .background(.white)
    }
    
}

extension FilteredImageView{
    var filteredIPad: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                FilterCollectionViewRepresentable(
                    filterImages: Array(filterImages),
                    viewModel: viewModel
                )
                .frame(height: 100)
                
                // 투명한 탭 영역
                Color.clear
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                
                Button {
                    if frameManager.resultImage != nil {
                        self.viewModel.isTakePic = true
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + viewModel.delayTime) {
                            viewModel.takePic()
                            viewModel.cameraManager.stopSession()
                            Analytics.logEvent("A1_셔터버튼눌림", parameters: nil)
                        }
                    } else {
                        viewModel.isShowAlert = true
                    }
                } label: {
                    Image("shutterImage")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                .allowsHitTesting(true)
                .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.isShowAlert) {
                    Button("닫기", role: .cancel) { }
                } message: {
                    Text("")
                }
                
                
            }
        }
        .frame(height: 124)
        .onAppear {
            DispatchQueue.main.async {
                //보라색 무시해주세요
                viewModel.cameraManager.session.startRunning()
            }
        }
        .onDisappear {
            viewModel.cameraManager.stopSession()
        }
        .onChange(of: filterImages.count) { _ in
            reloadFilterImages()
        }
    }
}
