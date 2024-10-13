//
//  CameraTimerView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/4/24.
//

import SwiftUI

struct CameraTimerView: View {
    @StateObject var motionManager = MotionManager()
    @Binding var delayTime: Double
    @Binding var isPushed: Int
    var body: some View {
        VStack(alignment: .center, spacing: 4)  {
            Button {
                isPushed = (isPushed + 1) % 4
            } label: {
                switch isPushed {
                case 0:
                    Image("timerIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                        .onAppear {
                            self.delayTime = 0
                            print("타이며 0초 설정됨")
                        }
                case 1:
                    ZStack {
                        Image("timerSecondBGIcon")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("3")
                            .font(Font.custom("SF Pro", size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                    }.rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                    .onAppear {
                        self.delayTime = 3
                        print("타이며 3초 설정됨")
                    }
                case 2:
                    ZStack {
                        Image("timerSecondBGIcon")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("5")
                            .font(Font.custom("SF Pro", size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                    }.rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                    .onAppear {
                        self.delayTime = 5
                        print("타이며 5초 설정됨")
                    }
                case 3:
                    ZStack {
                        Image("timerSecondBGIcon")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("7")
                            .font(Font.custom("SF Pro", size: 17))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                    }.rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                        .animation(.easeInOut, value: motionManager.currentOrientation)
                    .onAppear {
                        self.delayTime = 7
                        print("타이며 7초 설정됨")
                    }
                default:
                    Text("잘못된 값")
                    
                    
                }
                
            }
            Text("타이머")
                .font(Font.custom("SF Pro", size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
        }
    }
}


