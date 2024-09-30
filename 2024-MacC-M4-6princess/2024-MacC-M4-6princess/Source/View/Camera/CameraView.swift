//
//  CameraView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
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
                        Button(action: camera.takePic, label: {
                            
                            ZStack {
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        })
                    }
                    
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            camera.Check()
        })
        
    }
}
