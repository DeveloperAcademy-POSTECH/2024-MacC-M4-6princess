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
    @State var takePicCount: Int = 1
    @State var isCountPushed = false
//    var takePicCountDefault: Int = 1
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            Image("testFrame") //뷰에 프레임 띄우기
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
                        VStack {
                            if isCountPushed {
                                CameraTakepicCountView(takePicCount: $takePicCount)
                            }
                            Button {
                                isCountPushed.toggle()
                            } label: {
                                Text("찍는횟수")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            
                        }
                        Spacer()
                        
                        Button{
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
//                                camera.takePic()
//                            }
                            if takePicCount == 1 {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                                    camera.takePic()
                                }
                            }else {
                                for i in 0..<takePicCount {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime * Double(i)) {
                                            camera.takeManyPic()
                                        }
                                    }
                                camera.isTaken = true
                            }
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
        
    }
}
