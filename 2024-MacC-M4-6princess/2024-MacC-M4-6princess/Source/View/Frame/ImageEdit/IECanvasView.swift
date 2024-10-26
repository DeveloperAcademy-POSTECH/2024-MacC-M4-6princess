//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//

import SwiftUI

// 배경이미지 + 아이돌 이미지를 후보정(편집)하는 뷰
struct IECanvasView: View {
    @StateObject var viewModel: IEViewModel
    @GestureState var startLocation: CGPoint? = nil
    
    var body: some View {
        ZStack {
            // 배경 이미지
            
            if let outputImage = viewModel.applyColorFilter(originalImage: viewModel.bgImg) {
                Image(uiImage: outputImage)
                    .resizable()
                    
                    .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                    .aspectRatio(contentMode: .fit)
            }
            // 아이돌 이미지
            Image(uiImage: viewModel.idolImg)
                .resizable()
                .scaledToFit()
                .rotationEffect(viewModel.rotationAngle)
                .frame(width: viewModel.frameIdolSize.width, height: viewModel.frameIdolSize.height)
                .position(viewModel.location)
                .gesture(dragGesture
                    .simultaneously(with: magnifyGesture)
                    .simultaneously(with: rotationGesture)
                    .simultaneously(with: rawImageUnrock)
                )
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: viewModel.bgImg, idolImg: viewModel.idolImg, bounds: UIScreen.main.bounds.size)
        }
                .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
    }
}
