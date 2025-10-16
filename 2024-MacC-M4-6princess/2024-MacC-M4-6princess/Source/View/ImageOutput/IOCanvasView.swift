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
            if let originalImage = viewModel.bgImg {
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onChange(of: geo.size) { newSize in
                                if viewModel.frameBGSize != newSize {
                                    viewModel.frameBGSize = newSize
                                }
                            }
                        }
                    )
            }
            
            // 아이돌 이미지 (마스크 적용)
            if let idolImg = viewModel.idolImg {
                Image(uiImage: idolImg)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(currentScale)
                    .position(viewModel.location)
                    .mask(
                        Group {
                            if viewModel.frameBGSize.width > 0 {
                                Rectangle()
                                    .frame(width: viewModel.frameBGSize.width,
                                           height: viewModel.frameBGSize.height)
                            } else {
                                Rectangle().opacity(1) // fallback mask
                            }
                        }
                    )
            }
            
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Image("logo.output")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding()
                }
            }
        }
        .onAppear {
            if let bg = viewModel.bgImg, let idol = viewModel.idolImg {
                viewModel.canvasOnAppear(bgImg: bg, idolImg: idol, bounds: UIScreen.main.bounds.size)
            }
            // else: images not ready yet
        }
    }
}

