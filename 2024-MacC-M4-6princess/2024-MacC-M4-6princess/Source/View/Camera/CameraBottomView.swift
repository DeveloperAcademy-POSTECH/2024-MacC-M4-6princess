//
//  CameraBottomView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/4/24.
//

import SwiftUI
import FirebaseAnalytics

//메인뷰 하단 뷰(셔터버튼, 기타 버튼 등)
struct CameraBottomView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    // ✅ 여기서 미리 생성해두고 재사용하기!
        private var filteredImageView : some View {
            FilteredImageView(viewModel: viewModel)
                .environmentObject(frameManager)
                .environmentObject(imageModel)
        }
    
    var body: some View {
        
            if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                VStack{
                    Spacer()
                    ZStack {
                        filteredImageView
                        HStack {
                            //새 프레임 만들기 버튼
                            Button {
                                naviManager.push(screen: Screen.photoPicker)
                                
                            } label: {
                                VStack(alignment: .center, spacing: 4) {
                                    Image("newFrameIcon")
                                        .resizable()
                                        .frame(width: 50, height: 50)
//                                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
//                                        .animation(.easeInOut, value: motionManager.currentOrientation)
                                    Text("새 프레임")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.leading, 20)
                            .frame(width: 80, height: 80)
                            .background(.white)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 132)
                .background(.white)
            }
            else {
                cameraIPadBottomView
            }
        }
}

