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
            }
            
            
            // Portrait 또는 PortraitUpsideDown일 때
            if viewModel.initialOrientation == .portrait || viewModel.initialOrientation == .portraitUpsideDown  {
                VStack{
                    Spacer() // 상단 여백
                    HStack {
                        Spacer() // 좌측 여백
                        Image("logo.output")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .padding()
                    }
                }
            }
            // Landscape일 때
            else if viewModel.initialOrientation == .landscapeLeft {
                VStack{
                    Spacer() // 상단 여백
                    HStack {
                        
                        Image("logo.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .padding()
                        Spacer() // 좌측 여백
                    }
                }
                
            }
            // Landscape일 때
            else if  viewModel.initialOrientation == .landscapeRight {
                
                HStack {
                    Spacer()
                    VStack {
                        Image("logo.left")
                            .resizable()
                            .scaledToFit()
                        //                                .rotationEffect(rotationAngle(for: viewModel.initialOrientation))
                            .frame(height:100)
                            .padding()
                        Spacer()
                        
                    }
                    
                }
                
            }
            
            
            
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: viewModel.bgImg!, idolImg: viewModel.idolImg!, bounds: UIScreen.main.bounds.size)
        }
    }
    // initialOrientation에 따른 회전 각도를 계산하는 헬퍼 함수
    private func rotationAngle(for orientation: UIDeviceOrientation) -> Angle {
        switch orientation {
            case .portrait:
                return .degrees(0) // 기본 방향
            case .portraitUpsideDown:
                return .degrees(180) // 180도 회전
            case .landscapeLeft:
                return .degrees(90) // 반시계 방향 90도
            case .landscapeRight:
                return .degrees(-90) // 시계 방향 90도
            case .faceUp, .faceDown, .unknown:
                return .degrees(0) // 기본값
            @unknown default:
                return .degrees(0)
        }
    }
}
