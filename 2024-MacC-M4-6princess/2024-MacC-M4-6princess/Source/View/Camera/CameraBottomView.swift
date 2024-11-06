//
//  CameraBottomView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/4/24.
//

import SwiftUI

//메인뷰 하단 뷰(셔터버튼, 기타 버튼 등)
struct CameraBottomView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    var body: some View {
        VStack{
            HStack (alignment: .center){
                
                //프레임 불러오기 버튼
                Button {
                    viewModel.isFrameSelect.toggle()
                    print("프레임 버튼 눌림")
                } label: {
                    VStack(alignment: .center, spacing: 4) {
                        Image(viewModel.firstTime ? "frameLoadPink" : "frameLoad")
                            .resizable()
                            .frame(width: 40, height: 40)
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
                    if viewModel.isFrameSelected {
                        self.viewModel.isTakePic = true
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + viewModel.delayTime) {
                            viewModel.takePic()
                            viewModel.cameraManager.stopSession()
                        }
                    } else {
                        viewModel.showAlert = true
                    }
                } label: {
                    Image("shutterImage")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                }
                .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.showAlert) {
                    Button("닫기", role: .cancel) { }
                } message: {
                    Text("")
                }
                
                Spacer()
                
                //타이머 설정 버튼
                CameraTimerView(delayTime: $viewModel.delayTime, isPushed: $viewModel.isPushedTimer)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        
        .frame(width: UIScreen.main.bounds.width, height: 132)
        .background(.white)
    }
}

