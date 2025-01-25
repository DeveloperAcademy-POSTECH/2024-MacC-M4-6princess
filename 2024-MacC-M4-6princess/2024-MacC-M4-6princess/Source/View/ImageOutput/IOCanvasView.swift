//
//  IOCanvasView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//


import SwiftUI

// 배경이미지 + 아이돌 이미지를 후보정(편집)하는 뷰
struct IOCanvasView: View {
    @StateObject var viewModel: IOViewModel
    @GestureState var startLocation: CGPoint? = nil
    @State var currentScale: CGFloat = 1.0
    @GestureState var zoomFactor: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 배경 이미지
            if let originalImage = viewModel.bgImg{
                Image(uiImage: originalImage)
                    .resizable()
//                    .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
            }
            
            // 아이돌 이미지
            if let idolImg = viewModel.idolImg {
                Image(uiImage: idolImg)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: viewModel.frameIdolSize.width, height: viewModel.frameIdolSize.height)
                    .scaleEffect(currentScale)
                    .position(viewModel.location)
            }
            
               
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: viewModel.bgImg!, idolImg: viewModel.idolImg!, bounds: UIScreen.main.bounds.size)
        }
    }
}

