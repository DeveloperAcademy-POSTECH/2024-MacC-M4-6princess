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
    @State var currentScale: CGFloat = 1.0
    @GestureState var zoomFactor: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 배경 이미지
            if let originalImage = viewModel.applyColorFilter(originalImage: viewModel.bgImg)
            //                ,let croppedImage = originalImage.cropToAspectRatio(8.5 / 5.5)
            {
                Image(uiImage: originalImage)
                    .resizable()
                    .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                    .aspectRatio(contentMode: .fit)
            }
            
            // 아이돌 이미지
            Image(uiImage: viewModel.idolImg)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .rotationEffect(viewModel.rotationAngle)
                .frame(width: viewModel.frameIdolSize.width, height: viewModel.frameIdolSize.height)
                .scaleEffect(currentScale)
                .position(viewModel.location)
                .gesture(dragGesture
                    .simultaneously(with: magnifyGesture)
                    .simultaneously(with: rotationGesture)
                    .simultaneously(with: rawImageUnrock)
                )
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: viewModel.bgImg, idolImg: viewModel.idolImg, bounds: UIScreen.main.bounds.size)
            print("image: \(viewModel.bgImg.size.width) \(viewModel.bgImg.size.height)")
        }
        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
    }
}

