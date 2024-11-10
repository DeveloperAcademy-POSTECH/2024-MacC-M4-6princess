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
        HStack(alignment: .bottom) {
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
                    
                }.padding(.trailing, 20)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 94)
//        .background(.white)
        .background(.black)
    }
}

