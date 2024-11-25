//
//  CamSaveView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/24/24.
//

import SwiftUI

struct CamSaveView: View {
    var bg: UIImage
    var idol: UIImage
    @StateObject var viewModel: CameraViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var isSave = false
    
    var body: some View {
        VStack {
            // 촬영된 이미지 표시
            if let compositeImage = viewModel.takenImg {
                Image(uiImage: compositeImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            
            if viewModel.saveComplete {
                CamSaveProgressView(isSave: $isSave, viewModel: viewModel)
            }
            
            
        }
//        .navigationBarBackButtonHidden()
    }
}

