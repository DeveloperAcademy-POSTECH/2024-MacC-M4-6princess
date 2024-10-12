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
    @State var delayTime: TimeInterval = 0.0
    @State var isPushed = false
    @State var isFrameSelect = false
    //    @State var takePicCount: Int = 1
    //    @State var isCountPushed = false
    @State private var rotation: Double = 0
    @State var selectedFrame: String = ""
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            Image(selectedFrame) //뷰에 프레임 띄우기
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack {
                
                if camera.isTaken {
                    
                    HStack {
                        Spacer()
                        
                        
                        
                        Button {
                            camera.reTake()
                        } label: {
                            Text("재촬영")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                    }
                }else {
                    Button {
                        camera.changeCamera()
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        
                    }.padding(.trailing, 20)
                    
                }
                
                Spacer()
                
                HStack {
                    
                    if camera.isTaken {
                        Button {
                            if !camera.isSaved{
                                camera.savePic()
                                
                            }
                        } label: {
                            Text(camera.isSaved ? "저장됨!" : "저장하기")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                    }else {
                        Button {
                            isFrameSelect = true
                        } label: {
                            Text("불러오기")
                        }
                        
                        Button {
                            isPushed.toggle()
                        } label: {
                            Image(systemName: "timer")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }.padding(.trailing, 20)
                        if isPushed {
                            CameraTimerView(delayTime: $delayTime)
                        }
                        //                      찍는 횟수 버튼 잠시 주석처리 - sprint2때 복구 예정
                        //                        VStack {
                        //                            if isCountPushed {
                        //                                CameraTakepicCountView(takePicCount: $takePicCount)
                        //                            }
                        //                            Button {
                        //                                isCountPushed.toggle()
                        //                            } label: {
                        //                                Text("찍는횟수")
                        //                                    .foregroundColor(.black)
                        //                                    .padding()
                        //                                    .background(Color.white)
                        //                                    .clipShape(Circle())
                        //                            }
                        //                        }
                        Spacer()
                        
                        Button{
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                                camera.takePic()
                            }
                            
                            //                            if takePicCount == 1 {
                            //                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                            //                                    camera.takePic()
                            //                                }
                            //                            }else {
                            //                                for i in 0..<takePicCount {
                            //                                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime * Double(i)) {
                            //                                        camera.takeManyPic()
                            //                                    }
                            //                                    DispatchQueue.global(qos: .background).async {
                            //                                        camera.session.stopRunning()
                            //                                    }
                            //                                }
                            //                                DispatchQueue.main.async {
                            //                                    withAnimation {
                            //                                        camera.isTaken.toggle()
                            //                                        camera.isAllTaken.toggle()
                            //                                        print("isTaken 값 토글됨")
                            //                                    }
                            //                                }
                            //                            }
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                    
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.checkVideoAuthorizaion()
        })
        .sheet(isPresented: $isFrameSelect) {
            CameraFrameSelectView(selectedFrame: $selectedFrame)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            
        }
    }
}
