//
//  Camera+iPad.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/12/24.
//

import Foundation
import SwiftUI
extension CameraBottomView {
    
    // iPad 전용 뷰 변수
    var cameraIPadBottomView: some View {
        VStack{
            HStack (){
                //프레임 불러오기 버튼
                Button {
                    //                    viewModel.isShowMFView.toggle()
                    frameManager.showMFView = true
                    print("프레임 버튼 눌림")
                } label: {
                    VStack(alignment: .center, spacing: 4) {
                        Image("frameLoad")
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
            .padding(.top,10)
            Spacer()
            
        }
        .padding(.horizontal, 20)
        .frame(width: UIScreen.main.bounds.width, height: 132)
        .background(.white)
    }
    
}
extension CameraTopView{
    var cameraIPadBottomView: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack {
                Spacer()
                Button {
                    viewModel.changeCamera()
                } label: {
                    Image("cameraReverseIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                    
                }
                .padding(.trailing, 20)
                //                    Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 94)
        .background(.white)
    }
}
