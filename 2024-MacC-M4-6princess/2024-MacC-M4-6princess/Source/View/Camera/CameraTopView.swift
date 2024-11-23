//
//  CameraTopView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/4/24.
//

import SwiftUI

//메인뷰 상단 뷰
struct CameraTopView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    var body: some View {
        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
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
                    Spacer()
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 94)
            .background(.white)
        }
        else{
            cameraIPadBottomView
        }
    }
}


