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
            if let originalImage = viewModel.applyColorFilter(originalImage: viewModel.bgImg),
               let croppedImage = originalImage.cropToAspectRatio(3.0 / 4.0) {
                Image(uiImage: croppedImage)
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
                .scaleEffect(zoomFactor * currentScale)
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


extension UIImage {
    func cropToAspectRatio(_ targetAspectRatio: CGFloat) -> UIImage? {
        let originalWidth = size.width
        let originalHeight = size.height
        let originalAspectRatio = originalWidth / originalHeight
        
        var cropRect: CGRect
        
        if originalAspectRatio > targetAspectRatio {
            // 이미지가 너무 넓은 경우, 너비를 줄여서 크롭
            let newWidth = originalHeight * targetAspectRatio
            let xOffset = (originalWidth - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalHeight)
        } else {
            // 이미지가 너무 높은 경우, 높이를 줄여서 크롭
            let newHeight = originalWidth / targetAspectRatio
            let yOffset = (originalHeight - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalWidth, height: newHeight)
        }
        
        // 크롭 영역을 설정하여 CGImage로 변환
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        
        // 크롭된 CGImage를 UIImage로 변환
        return UIImage(cgImage: cgImage)
    }
}
