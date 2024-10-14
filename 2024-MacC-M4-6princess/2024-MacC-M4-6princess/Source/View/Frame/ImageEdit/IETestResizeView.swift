//
//  IETestResizeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/9/24.
//
//TODO: 세부작업,뷰모델 작업,색감조정 함수 넣고, 제인이랑 뷰연결 -> 이미지 저장
//TODO: 위치 저장
//TODO: 언두,리두

import SwiftUI

struct IETestResizeView: View {
    @ObservedObject var ievm: IEViewModel
    @GestureState var startLocation: CGPoint? = nil
    
    
    @Binding var bgImg: UIImage
    @Binding var idolImg: UIImage
    
    
    
    var simpleDrag: some Gesture {
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
                    .frame(width: ievm.baseWidth, height: ievm.baseWidth * ievm.idolRatio)
                    .rotationEffect(ievm.rotationAngle)
                    .position(ievm.location)
                    .gesture(simpleDrag)
                    .offset(ievm.dragOffset)
            }
        }
        .onAppear {
            // 이미지 초기화 로직
            guard let backgroundCGImage = bgImg.cgImage,
                  let idolCGImage = idolImg.cgImage else {
                fatalError("이미지 로드 실패")
            }
            bgImg = UIImage(cgImage: backgroundCGImage, scale: 1.0, orientation: .up)
            idolImg = UIImage(cgImage: idolCGImage, scale: 1.0, orientation: .up)
            ievm.idolRatio = idolImg.size.height / idolImg.size.width
            print(bgImg.size)
            ievm.bgRatio = bgImg.size.height / bgImg.size.width
            print(ievm.bgRatio)
            ievm.screenSize = UIScreen.main.bounds.size
            print(ievm.screenSize)
                ievm.location = CGPoint(x: ievm.screenSize.width / 3 * 2, y: ievm.screenSize.width * ievm.bgRatio / 2)
            
        }
        .frame(width: ievm.screenSize.width, height: ievm.screenSize.width * ievm.bgRatio)
        .background(Color.red)
    }
    
    func updateLocation(with translation: CGSize, startLocation: CGPoint?) {
        var newLocation = startLocation ?? ievm.location
        newLocation.x += translation.width
        newLocation.y += translation.height
        ievm.location = newLocation
    }
    
}
