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
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var naviManager:NavigationManager
    @EnvironmentObject var frameManager:FrameManager
    var body: some View {
        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
            //        if horizontalSizeClass == .regular{
            VStack{
                Spacer()
                HStack (){
                    
                    //프레임 불러오기 버튼
                    Button {
//                        viewModel.isShowMFView.toggle()
                        frameManager.showMFView = true
                        viewModel.cameraManager.stopSession()
                        print("프레임 버튼 눌림")
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image(viewModel.firstTime ? "frameLoadPink" : "frameLoad")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(5)
                                .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                .animation(.easeInOut, value: motionManager.currentOrientation)
                            Text("불러오기")
                                .font(.system(size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                        }
                    }
                    
                    Spacer()
                    
                    //셔터 버튼
                    Button {
                        if frameManager.resultImage != nil{
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
                            .frame(width: 80, height: 80)
                            .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                            .animation(.easeInOut, value: motionManager.currentOrientation)
                    }
                    .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.isShowAlert) {
                        Button("닫기", role: .cancel) { }
                    } message: {
                        Text("")
                    }
                    
                    Spacer()
                    
                    //타이머 설정 버튼
                    CameraTimerView(viewModel: viewModel)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.width, height: 132)
            .background(.white)
        }
        else {
            cameraIPadBottomView
        }
    }
}

