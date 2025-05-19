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
                    viewModel: viewModel
                )
                .frame(height: 100)
                
            }
        }
        .frame(height: 124)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                viewModel.cameraManager.session.startRunning()
                DispatchQueue.main.async {
                    reloadFilterImages()
                }
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
