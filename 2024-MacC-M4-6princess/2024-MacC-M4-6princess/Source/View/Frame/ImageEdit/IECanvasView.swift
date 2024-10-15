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
    
    @State private var scale: CGFloat = 1.0
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? viewModel.location
            }
    }
    
    // TODO: Angle 변화 속도를 늦추기
    var rotationGesture: some Gesture{
        
        RotationGesture()
            .onChanged { angle in
                viewModel.rotationAngle = angle
                print("angle:\(angle.degrees)")
            }
        
    }
    
    var magnifyGesture: some Gesture{
        MagnifyGesture()
            .onChanged{ value in
                scale = value.magnification
                
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
            Image(uiImage: bgImg)
                .resizable()
                .scaledToFit()
            
            // 아이돌 이미지
            if let outputImage = viewModel.applyColorFilter(originalImage: idolImg) {
                Image(uiImage: outputImage)
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
        }
        .onAppear {
            // 배경 이미지의 aspectRatio를 구함
            viewModel.bgRatio = bgImg.size.height / bgImg.size.width
            print(viewModel.bgRatio)
            
            // 아이돌 이미지의 aspectRatio를 구함
            viewModel.idolRatio = idolImg.size.height / idolImg.size.width
            print(bgImg.size)
            
            // IECanvasView의 프레임 크기를 구함 for 이미지 저장
            viewModel.screenSize = UIScreen.main.bounds.size
            print(viewModel.screenSize)
            
            // 화면에 보여줄 이미지 크기를 지정
            viewModel.frameBGSize = CGSize(width: viewModel.screenSize.width, height: viewModel.bgRatio * viewModel.screenSize.width) // 가로로 꽉차도록 지정,세로는 비율에 맞게 계산함
            viewModel.frameIdolSize = CGSize(width: viewModel.baseWidth, height: viewModel.bgRatio * viewModel.screenSize.width) // baseWidth를 100으로 지정,세로는 계산
            
            // 뷰생성시 아이돌 이미지 위치 지정
            viewModel.location = CGPoint(x: viewModel.frameBGSize.width / 3 * 2, y: viewModel.frameBGSize.height / 2)
            
            
        }
        .frame(width: viewModel.frameBGSize.width, height: viewModel.frameBGSize.height)
        .background(Color.red)
    }
    
    
}
