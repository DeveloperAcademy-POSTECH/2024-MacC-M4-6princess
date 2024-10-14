//
//  IEViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/10/24.
//
import SwiftUI
import UIKit
//TODO: 아이돌 이미지가 바깥으로 가지못하게하기
class IEViewModel: ObservableObject {
    @Published var imageScale: CGFloat = 1.0
    @Published var startScale: CGFloat = 1.0
    @Published var dragOffset: CGSize = .zero
    @Published var startOffset: CGSize = .zero
    @Published var isSelected: Bool = false
    @Published var rotationAngle: Angle = .zero
    @Published var isModal = false
    @Published var sliderValues: [Float] = [0.0, 1.0, 1.0]
    @Published var selectedIndex: Int? = nil // 선택된 인덱스를 저장
    var idolRatio:CGFloat = .zero
    @Published var rendered:UIImage?
    @Published var screenSize: CGSize = .zero // bgImg 뷰의 크기를 저장할 State 변수
    @Published var bgRatio: CGFloat = .zero
    @Published var location: CGPoint = CGPoint(x: 100, y: 100)
    
//    @Published var frameScale:CGPoint = .zero
    
    // 이미지에 색상 조정하는 객체,변수
    var ciContext = CIContext()
    var filter = CIFilter.colorControls()
    
    let baseWidth: CGFloat = 100
    
    
    // 편집 옵션 배열
    let colorEdit: [EditingOption] = [
        EditingOption(name: "밝기", icon: "sun.max.fill",range:-1...1,step: 0.1),
        EditingOption(name: "채도", icon: "cloud.rainbow.half",range: 0...2,step: 0.1),
        EditingOption(name: "대비", icon: "circle.lefthalf.fill",range: 0...2,step: 0.1)
    ]
    
    // 이미지 스케일 업데이트 함수
    func updateImageScale(with value: CGFloat) {
        imageScale = max(0.2, min(2, startScale + (value-2) / 10))
    }
    
    // 드래그 제스처 처리 함수
    func updateDragOffset(with translation: CGSize) {
        dragOffset = CGSize(
            width: startOffset.width + translation.width,
            height: startOffset.height + translation.height
        )
        //        dragOffset = translation
    }
    
    // 회전 제스처 처리 함수
    func updateRotationAngle(with angle: Angle) {
        rotationAngle = angle
    }
    
    // 선택 상태 토글 함수
    func toggleSelection() {
        isSelected.toggle()
    }
    
    // 스케일 종료 시 처리 함수
    func endScaling() {
        startScale = imageScale
    }
    
    // 드래그 종료 시 처리 함수
    func endDragging() {
        startOffset = dragOffset
    }
    
    // 배경이미지에 아이돌이미지를 적절한 위치에 올려서 합성사진을 저장하는 함수
    func renderAndSaveImage(backgroundImage: UIImage, idolImage: UIImage) -> UIImage? {
        let backgroundSize = backgroundImage.size
        
        // 배경 이미지의 크기 기준으로 렌더링할 새로운 컨텍스트 생성
        UIGraphicsBeginImageContextWithOptions(backgroundSize, false, 0.0)
        
        // 배경 이미지 그리기
        backgroundImage.draw(in: CGRect(origin: .zero, size: backgroundSize))
        
        // 아이돌 이미지 크기 조정
        let idolSize = CGSize(width: idolImage.size.width * imageScale, height: idolImage.size.height * imageScale)
        
        // 아이돌 이미지의 위치를 중심으로 변경하여 변환 설정
        let idolRect = CGRect(x: (backgroundSize.width - idolSize.width) / 2 + dragOffset.width,
                              y: (backgroundSize.height - idolSize.height) / 2 + dragOffset.height,
                              width: idolSize.width, height: idolSize.height)
        
        // 필터 적용된 아이돌 이미지 가져오기
        guard let filteredIdolImage = applyColorFilter(originalImage: idolImage) else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 현재 그래픽 컨텍스트 가져오기
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 변환 적용 (회전, 위치 변경)
        context.translateBy(x: idolRect.midX, y: idolRect.midY)  // 아이돌 이미지의 중심으로 이동
        context.rotate(by: rotationAngle.radians)                // 회전 적용
        context.translateBy(x: -idolRect.midX, y: -idolRect.midY) // 다시 원점으로 이동
        
        // 필터 적용된 아이돌 이미지 그리기
        filteredIdolImage.draw(in: idolRect)
        
        // 새로 그린 이미지 가져오기
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 컨텍스트 종료
        UIGraphicsEndImageContext()
        
        // 이미지를 저장하고 싶다면 아래 코드 추가
        if let imageToSave = renderedImage {
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
            isModal = true
        }
        
        return renderedImage
    }

    // 이미지에 색상 조정을 적용하는 함수
    func applyColorFilter(originalImage:UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        
        filter.inputImage = ciImage
        filter.brightness = sliderValues[0] //밝기
        filter.saturation = sliderValues[1] //채도
        filter.contrast = sliderValues[2] //대비
        
        guard let outputCIImage = filter.outputImage,
              let cgImage = ciContext.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
}

//extension TestPositionView{
//    func saveCompositeImage() {
//        // 배경 이미지 비율 계산
////        let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
//        let backgroundWidth = backgroundImg.size.width
//        let backgroundHeight = backgroundImg.size.height
//        
//        // 비트맵 그래픽 컨텍스트 생성
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: backgroundWidth, height: backgroundHeight))
//        
//        let compositeImage = renderer.image { context in
//            // 배경 이미지 그리기
//            backgroundImg.draw(in: CGRect(x: 0, y: 0, width: backgroundWidth, height: backgroundHeight))
//            
//            // 아이돌 이미지 크기 계산
//            let idolWidth = baseWidth * imageScale
//            let idolHeight = (baseWidth / imageAspectRatio) * imageScale
//            
//            // 아이돌 이미지 그리기 위치 계산
////            let idolX = idolPosition.x
////            let idolY = idolPosition.y
//
//            // 현재 회전을 적용하여 아이돌 이미지를 그립니다.
////            context.cgContext.saveGState()
////            context.cgContext.translateBy(x: idolX + (idolWidth / 2), y: idolY + (idolHeight / 2))
//            context.cgContext.rotate(by: CGFloat(rotationAngle.radians))
//            idolImg.draw(in: CGRect(x: idolPosition.x, y: idolPosition.y, width: idolWidth*5, height: idolHeight*5))
//            context.cgContext.restoreGState()
//        }
//        
//        // 포토 라이브러리에 이미지 저장
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAsset(from: compositeImage)
//        }) { success, error in
//            DispatchQueue.main.async {
//                if success {
//                    showingSavedAlert = true
//                } else {
//                    saveError = true
//                }
//            }
//        }
//    }
//
//}
//
// 맨초기버전
//func saveCompositeImage() {
//    // 배경 이미지 비율 계산
//    let backgroundAspectRatio = backgroundImg.size.width / backgroundImg.size.height
//    let backgroundWidth = backgroundImg.size.width
//    let backgroundHeight = backgroundWidth / backgroundAspectRatio
//    
//    // 비트맵 그래픽 컨텍스트 생성
//    let renderer = UIGraphicsImageRenderer(size: CGSize(width: backgroundWidth, height: backgroundHeight))
//    
//    let compositeImage = renderer.image { context in
//        // 배경 이미지 그리기
//        backgroundImg.draw(in: CGRect(x: 0, y: 0, width: backgroundWidth, height: backgroundHeight))
//        
//        // 아이돌 이미지 크기 계산
//        let idolWidth = baseWidth * imageScale
//        let idolHeight = (baseWidth / imageAspectRatio) * imageScale
//        
//        // 아이돌 이미지 그리기 위치 계산
//        let idolX = dragOffset.width + (backgroundWidth / 2) - (idolWidth / 2)
//        let idolY = dragOffset.height + (backgroundHeight / 2) - (idolHeight / 2)
//
//        // 현재 회전을 적용하여 아이돌 이미지를 그립니다.
//        context.cgContext.saveGState()
//        context.cgContext.translateBy(x: idolX + (idolWidth / 2), y: idolY + (idolHeight / 2))
//        context.cgContext.rotate(by: CGFloat(rotationAngle.radians))
//        idolImg.draw(in: CGRect(x: -idolWidth / 2, y: -idolHeight / 2, width: idolWidth, height: idolHeight))
//        context.cgContext.restoreGState()
//    }
//    
//    // 포토 라이브러리에 이미지 저장
//    PHPhotoLibrary.shared().performChanges({
//        PHAssetChangeRequest.creationRequestForAsset(from: compositeImage)
//    }) { success, error in
//        DispatchQueue.main.async {
//            if success {
//                showingSavedAlert = true
//            } else {
//                saveError = true
//            }
//        }
//    }
//}
//
