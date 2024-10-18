//
//  IEViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/10/24.
//
import SwiftUI
import UIKit
import Photos
import CoreImage.CIFilterBuiltins
import Combine

//TODO: 아이돌 이미지가 바깥으로 가지못하게하기
class IEViewModel: ObservableObject {
    @Published var imageScale: CGFloat = 1.0
    @Published var rotationAngle: Angle = .zero
    @Published var isModal = false
    @Published var sliderValues: [Float] = [0.0, 1.0, 1.0]
    @Published var selectedIndex: Int? = nil // 하단바 색조 조정 인덱스
    
    // 완료 버튼 클릭시 발생되는 최종 이미지를 저장
    @Published var compositeImage:UIImage?
    
    // 뷰생성시 아이돌 이미지의 위치(배경이미지의 좌표상 계산
    @Published var location: CGPoint = CGPoint(x: 100, y: 100)
    
    // 원본/축소된 이미지 크기
    @Published var rawBGSize: CGSize = .zero // 원본 배경이미지의 크기
    @Published var rawIdolSize: CGSize = .zero // 원본 아이돌이미지의 크기
    @Published var frameBGSize: CGSize = .zero // 프레임상의 축소된 배경 이미지 크기
    @Published var frameIdolSize: CGSize = .zero // 프레임상 아이돌 이미지 크기
    var bgRatio: CGFloat = .zero
    var idolRatio:CGFloat = .zero
    
    @Published var screenSize: CGSize = .zero // bgImg 뷰의 크기를 저장할 State 변수
    
    var imgArray:[UIImage] = []
    // 이미지에 색상 조정하는 객체,변수
    var ciContext = CIContext()
    var filter = CIFilter.colorControls()
    let baseWidth: CGFloat = 100
    
    @Published var isAppend = false
    private var cancellables = Set<AnyCancellable>()
    
    // 편집 옵션 배열
    let colorEditOptions: [EditingOption] = [
        EditingOption(name: "밝기", icon: "luminosity",range:-0.1...0.1,step: 0.02),
        EditingOption(name: "채도", icon: "saturation",range: 0...2,step: 0.1),
        EditingOption(name: "대비", icon: "contrast",range: 0.9...1.1,step: 0.01)
    ]
    
    
    @MainActor
    func appendImg<T: View>(content: T) {
        // ImageRenderer를 이용해서 합성 이미지 생성
        let renderedImage = ImageRenderer(content: content.frame(width: screenSize.width, height: screenSize.width * bgRatio))
        
        // 해상도
        renderedImage.scale = 2.0
        
        if let uiImage = renderedImage.uiImage {
            self.imgArray.append(uiImage)
            
        } else {
            print("언두리두이미지생성실패")
        }
        isAppend = false
    }
    
    func canvasOnAppear(bgImg:UIImage,idolImg:UIImage,bounds:CGSize){
        
        // 4:3 사진을 기준
        let normRatio = 4.0 / 3.0
        // 배경 이미지의 aspectRatio를 구함
        self.bgRatio = bgImg.size.height / bgImg.size.width
        let bgWeightRatio = bgImg.size.width / bgImg.size.height
        print("bgRatio:\(self.bgRatio)")
        
        // 아이돌 이미지의 aspectRatio를 구함
        self.idolRatio = idolImg.size.height / idolImg.size.width
        print("bgImg.size:\(bgImg.size)")
        
        // IECanvasView의 프레임 크기를 구함 for 이미지 저장
        self.screenSize = bounds
        
        // 배경이미지를 scaleToFit하게 만듬
        // 세로로 긴 이미지
        let newHeight = self.screenSize.height / 3 * 2 // 화면 높이의 2/3
        self.frameBGSize = CGSize(width: newHeight * (bgImg.size.height/bgImg.size.width), height: newHeight) // 가로로 꽉차도록 지정,세로는 비율에 맞게 계산함
//        if bgRatio > normRatio{
//            // 화면에 보여줄 이미지 크기를 지정
//            let newHeight = self.screenSize.height / 3 * 2 // 화면 높이의 2/3
//            self.frameBGSize = CGSize(width: newHeight * bgWeightRatio, height: newHeight) // 가로로 꽉차도록 지정,세로는 비율에 맞게 계산함
//        }
//        else{
//            self.frameBGSize = CGSize(width: self.screenSize.width, height: self.bgRatio * (self.screenSize.width)) // 가로로 꽉차도록 지정,세로는 비율에 맞게 계산함
//            
//        }
        if idolImg.size.width > idolImg.size.height{
            self.frameIdolSize = CGSize(width: self.frameBGSize.width, height: self.frameBGSize.width * (idolImg.size.height / idolImg.size.width))
        }
        else{
            self.frameIdolSize = CGSize(width: newHeight * (idolImg.size.width / idolImg.size.height), height: newHeight)
        }
        
        
        // 뷰생성시 아이돌 이미지 위치 지정
        self.location = CGPoint(x: self.frameBGSize.width / 2, y: self.frameBGSize.height / 2)
        
    }
    /// 이미지에 색상 조정을 적용하는 함수
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
    
    /// 드래그 제스처 undating 함수
    func updateLocation(with translation: CGSize, startLocation: CGPoint?) {
        var newLocation = startLocation ?? self.location
        newLocation.x += translation.width
        newLocation.y += translation.height
        self.location = newLocation
        print("newLocation:\(newLocation)")
    }
    
    
    /// 사진 저장 함수
    @MainActor
    func saveRenderedView<T: View>(content: T) { //Content라는 타입을 찾을 수 없어서, 제너릭 타입으로 진행
        // ImageRenderer를 이용해서 합성 이미지 생성
        let renderedImage = ImageRenderer(content: content.frame(width: self.frameBGSize.width, height: self.frameBGSize.height))
        
        // 해상도
        renderedImage.scale = 8.0
        
        if let uiImage = renderedImage.uiImage {
            self.compositeImage = uiImage
            
            // 이미지 저장
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("성공")
                    } else {
                        print("실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            }
            // 테스트 모달창
            self.isModal = true
        } else {
            print("렌더링 실패: 이미지 생성 실패")
        }
    }
    
}

//init() {
//    // location 값이 변경될 때마다 출력
//    $location
//        .sink { newLocation in
//            print("location 변경됨: \(newLocation)")
//        }
//        .store(in: &cancellables) // 구독을 cancellables에 저장
//}
