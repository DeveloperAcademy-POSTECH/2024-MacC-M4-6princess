//
//  CamZoomButtonView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/12/24.
//

import SwiftUI

struct CamZoomButtonView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject var motionManager = MotionManager()
    
    var body: some View {
        Button {
            //만약 viewModel의 cameraPosition이 .back이라면
            //viewModel의 currentZoomFactor를 0.5, 1, 2, 3으로 바꿔주는 함수
            //cameraPosition이 .front라면
            //viewModel의 currentZoomFactor를 0.8(기본), 그리고 더 줄여서 0.5까지 줄일 수 있도록
            
        } label: {
            
        }

    }
}
