//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//

import SwiftUI

// 배경이미지 + 아이돌 이미지를 후보정(편집)하는 뷰
struct IECanvasView: View {
    @ObservedObject var ievm: IEViewModel
    @GestureState var startLocation: CGPoint? = nil
    
    @Binding var bgImg: UIImage
    @Binding var idolImg: UIImage
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                updateLocation(with: value.translation, startLocation: startLocation)
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? ievm.location
            }
    }
    
    var body: some View {
        ZStack {
            // 배경 이미지
            Image(uiImage: bgImg)
                .resizable()
                .scaledToFit()
            
            // 아이돌 이미지
            if let outputImage = ievm.applyColorFilter(originalImage: idolImg) {
                Image(uiImage: outputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: ievm.frameIdolSize.width, height: ievm.frameIdolSize.height)
                    .rotationEffect(ievm.rotationAngle)
                    .position(ievm.location)
                    .gesture(dragGesture)
                    .offset(ievm.dragOffset)
            }
        }
        .onAppear {
            // 배경 이미지의 aspectRatio를 구함
            ievm.bgRatio = bgImg.size.height / bgImg.size.width
            print(ievm.bgRatio)
            
            // 아이돌 이미지의 aspectRatio를 구함
            ievm.idolRatio = idolImg.size.height / idolImg.size.width
            print(bgImg.size)
            
            // IECanvasView의 프레임 크기를 구함 for 이미지 저장
            ievm.screenSize = UIScreen.main.bounds.size
            print(ievm.screenSize)
            
            // 화면에 보여줄 이미지 크기를 지정
            ievm.frameBGSize = CGSize(width: ievm.screenSize.width, height: ievm.bgRatio * ievm.screenSize.width) // 가로로 꽉차도록 지정,세로는 비율에 맞게 계산함
            ievm.frameIdolSize = CGSize(width: ievm.baseWidth, height: ievm.bgRatio * ievm.screenSize.width) // baseWidth를 100으로 지정,세로는 계산
            
            ievm.location = CGPoint(x: ievm.screenSize.width / 3 * 2, y: ievm.screenSize.width * ievm.bgRatio / 2)
            
            
        }
        .frame(width: ievm.frameBGSize.width, height: ievm.frameBGSize.height)
        .background(Color.red)
    }
    
    func updateLocation(with translation: CGSize, startLocation: CGPoint?) {
        var newLocation = startLocation ?? ievm.location
        newLocation.x += translation.width
        newLocation.y += translation.height
        ievm.location = newLocation
    }
    
}
