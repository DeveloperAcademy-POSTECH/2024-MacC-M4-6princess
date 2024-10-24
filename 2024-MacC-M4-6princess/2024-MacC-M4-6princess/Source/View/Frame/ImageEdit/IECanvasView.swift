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
    
    // TODO: Angle 변화 속도를 늦추기
    var rotationGesture: some Gesture{
        RotationGesture()
            .onChanged { angle in
                viewModel.rotationAngle = angle
            }
            .onEnded{ value in
                viewModel.undoHistory.append(viewModel.recentPop)
                viewModel.recentPop.ang = value
                if !viewModel.redoHistory.isEmpty{
                    viewModel.redoHistory = []
                }
            }
    }
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // 이게 안되는 이유: 드래그 끝나고 위치가 업데이트 됨
                //                viewModel.location=value.location
                viewModel.updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? viewModel.location
            }
            .onEnded{ _ in
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    print("firstOne:\(viewModel.firstOne)")
                    print("recentPop:\(viewModel.recentPop)")
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                else{
                    viewModel.undoHistory.append(viewModel.recentPop)
                    viewModel.recentPop.loc = viewModel.location
                    if !viewModel.redoHistory.isEmpty{
                        viewModel.redoHistory = []
                    }
                }
            }
    }
    // 아이돌 이미지 확대/축소 제스쳐
    var magnifyGesture: some Gesture{
        MagnifyGesture()
            .onChanged{ value in
                viewModel.scale = value.magnification
                
                // 확대/축소가 한번에 변할 수 있는 최대/최소값 지정
                if viewModel.scale >= 1{
                    viewModel.scale = min((viewModel.scale - 1) * 0.01 + 1,1.3) // 한번에 최대 확대는 1.3배까지만 가능(미세조정 기능)
                }
                else{
                    viewModel.scale = max((viewModel.scale - 1) * 0.1 + 1,0.5) // 한번에 축소는 절반이 이하로 되지않음
                }
                let newWidth = viewModel.frameIdolSize.width * viewModel.scale
                
                // 축소된 가로 길이에 사진 비율을 곱해서 새로운 아이돌 이미지의 크기를 수정
                viewModel.frameIdolSize = CGSize(width:  newWidth, height: newWidth * viewModel.idolRatio)
            }
            .onEnded{ value in
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    print("firstOne:\(viewModel.firstOne)")
                    print("recentPop:\(viewModel.recentPop)")
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                else{
                    viewModel.undoHistory.append(viewModel.recentPop)
                    viewModel.recentPop.size = viewModel.frameIdolSize
                    
                    if !viewModel.redoHistory.isEmpty{
                        viewModel.redoHistory = []
                    }
                }
            }
    }
    var rawImageUnrock: some Gesture {
        TapGesture()
            .onEnded{
                if viewModel.isRawImage{
                    
                    let one = viewModel.temp
                    print("firstOne:\(viewModel.firstOne)")
                    print("recentPop:\(viewModel.recentPop)")
                    viewModel.recentPop = one
                    
                    viewModel.frameIdolSize = one.size
                    viewModel.location = one.loc
                    viewModel.rotationAngle = one.ang
                    viewModel.sliderValues = one.sliderValues
                    viewModel.isRawImage = false
                }
                
            }
    }
    
    var body: some View {
        ZStack {
            // 배경 이미지
            if let outputImage = viewModel.applyColorFilter(originalImage: viewModel.bgImg) {
                Image(uiImage: outputImage)
                    .resizable()
                    .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
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
