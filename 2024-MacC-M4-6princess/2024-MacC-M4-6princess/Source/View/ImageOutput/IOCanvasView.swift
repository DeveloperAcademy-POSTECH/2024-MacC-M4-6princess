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
    var widthSize:CGFloat = 80
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
                            Color.clear.onAppear {
                                viewModel.frameBGSize = geo.size // 배경 이미지의 실제 표시 크기 저장
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
                        Rectangle()
                            .frame(width: viewModel.frameBGSize.width,
                                   height: viewModel.frameBGSize.height)
                    )
                    .zIndex(1)
            }
            
            // Portrait 또는 PortraitUpsideDown일 때
            if viewModel.currentOrientation == .portrait || viewModel.currentOrientation == .portraitUpsideDown  {
                VStack{
                    Spacer() // 상단 여백
                    HStack {
                        Spacer() // 좌측 여백
                        Image("logo.output")
                            .resizable()
                            .scaledToFit()
                            .frame(width: widthSize)
                            .padding()
                    }
                }
            }
            // Landscape일 때
            else if viewModel.currentOrientation == .landscapeLeft {
                VStack{
                    Spacer() // 상단 여백
                    HStack {
                        
                        Image("logo.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: widthSize)
                            .padding()
                        Spacer() // 좌측 여백
                    }
                }
                
            }
            // Landscape일 때
            else if  viewModel.currentOrientation == .landscapeRight {
                
                HStack {
                    Spacer()
                    VStack {
                        Image("logo.left")
                            .resizable()
                            .scaledToFit()
                        //                                .rotationEffect(rotationAngle(for: viewModel.initialOrientation))
                            .frame(height:widthSize)
                            .padding()
                        Spacer()
                        
                    }
                    
                }
                
            }
            
            //            VStack{
            //                Spacer()
            //                HStack{
            //                    Spacer()
            //                    Image("logo.output")
            //                        .resizable()
            //                        .scaledToFit()
            //                        .frame(width: 100)
            //                        .padding()
            //                }
            //            }
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: viewModel.bgImg!, idolImg: viewModel.idolImg!, bounds: UIScreen.main.bounds.size)
        }
    }
}
