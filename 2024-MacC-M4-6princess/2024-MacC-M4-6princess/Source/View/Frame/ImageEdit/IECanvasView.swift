//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//

import SwiftUI

// 배경이미지 + 아이돌 이미지를 후보정(편집)하는 뷰
struct IECanvasView: View {
    @ObservedObject var viewModel: IEViewModel
    @GestureState var startLocation: CGPoint? = nil
    @Binding var bgImg: UIImage
    @Binding var idolImg: UIImage
    @State var scale: CGFloat = 1.0
    
    // TODO: Angle 변화 속도를 늦추기
    var rotationGesture: some Gesture{
        RotationGesture()
            .onChanged { angle in
                viewModel.rotationAngle = angle
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
    }
    // 아이돌 이미지 확대/축소 제스쳐
    var magnifyGesture: some Gesture{
        MagnifyGesture()
            .onChanged{ value in
                scale = value.magnification
                
                // 확대/축소가 한번에 변할 수 있는 최대/최소값 지정
                if scale >= 1{
                    scale = min((scale - 1) * 0.01 + 1,1.3) // 한번에 최대 확대는 1.3배까지만 가능(미세조정 기능)
                }
                else{
                    scale = max((scale - 1) * 0.1 + 1,0.5) // 한번에 축소는 절반이 이하로 되지않음
                }
                //                print("scale:\(scale)")
                let newWidth = viewModel.frameIdolSize.width * scale
                viewModel.frameIdolSize = CGSize(width:  newWidth, height: newWidth * viewModel.idolRatio)
                
            }
    }
    
    
    var body: some View {
        ZStack {
            // 배경 이미지
            if let outputImage = viewModel.applyColorFilter(originalImage: bgImg) {
                
                Image(uiImage: outputImage)
                    .resizable()
            }
            // 아이돌 이미지
            Image(uiImage: idolImg)
                .resizable()
                .scaledToFit()
                .rotationEffect(viewModel.rotationAngle)
                .frame(width: viewModel.frameIdolSize.width, height: viewModel.frameIdolSize.height)
                .position(viewModel.location)
                .gesture(dragGesture
                    .simultaneously(with: magnifyGesture)
                    .simultaneously(with: rotationGesture)
                )
            
        }
        .onAppear {
            viewModel.canvasOnAppear(bgImg: bgImg, idolImg: idolImg, bounds: UIScreen.main.bounds.size)
        }
        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
        //        .background(Color.red)
        
    }
    
    
}
