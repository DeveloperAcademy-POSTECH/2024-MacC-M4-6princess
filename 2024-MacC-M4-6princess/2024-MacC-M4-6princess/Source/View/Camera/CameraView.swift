//
//  CameraView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject var camera = CameraModel()
    @StateObject var motionManager = MotionManager()
    @State var delayTime: TimeInterval = 0.0
    @State var isPushed = 0
    @State var isFrameSelect = false
    @State var selectedFrame: String? = nil
    @AppStorage("openFirstTime") private var firstTime = false
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            Image(selectedFrame ?? "") //뷰에 프레임 띄우기
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack {
                        Spacer()
                        Button {
                            camera.changeCamera()
                        } label: {
                            Image("cameraReverseIcon")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                .animation(.easeInOut, value: motionManager.currentOrientation)
                            
                        }.padding(.trailing, 20)
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 82)
                .background(.white)
                
                Spacer()
                Spacer()
                HStack (alignment: .center){
                    //프레임 불러오기 버튼
                    Button {
                        isFrameSelect = true
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image("frameLoad")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                .animation(.easeInOut, value: motionManager.currentOrientation)
                            Text("불러오기")
                                .font(Font.custom("SF Pro", size: 13))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                        }
                    }
                    
                    Spacer()
                    
                    //셔터 버튼
                    Button{
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                            camera.takePic()
                        }
                    } label: {
                        Image("shutterImage")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                            .animation(.easeInOut, value: motionManager.currentOrientation)
                    }
                    
                    Spacer()
                    
                    //타이머 설정 버튼
                    CameraTimerView(delayTime: $delayTime, isPushed: $isPushed)
                    
                    
                }.padding(.horizontal, 20)
                    .frame(width: UIScreen.main.bounds.width, height: 132)
                    .background(.white)
                
            }
            //처음 실행했을 때
            if !firstTime  {
                CameraOnboardingView(firstTime: $firstTime)
                    .ignoresSafeArea(.all, edges: .all)
                    .zIndex(1)
            }
        }.ignoresSafeArea(.all, edges: .all)
        //home indicator 잠깐 숨겨봤는데.. 잘 모르겠네요
            .persistentSystemOverlays(.hidden)
            .onAppear(perform: {
                camera.checkVideoAuthorizaion()
                motionManager.startDeviceMotionUpdates()
            })
            .sheet(isPresented: $isFrameSelect) {
                CameraFrameSelectView(selectedFrame: $selectedFrame)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
            .statusBar(hidden: true)
        
    }
    
}


#Preview {
    CameraView(camera: CameraModel(), delayTime: 0, isPushed: 0, isFrameSelect: false, selectedFrame: "")
}
