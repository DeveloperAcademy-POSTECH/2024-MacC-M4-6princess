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
    
    
    @Published var scale: CGFloat = 1.0
    @Published var savePhoto = false
    @Published var saveAnimate = false
    @Published var pinchScale = 1.0 // 전체 보기를 위한 초기 비율을 1.0으로 설정
    @Published var pinchValue = 1.0 // 수동 확대/축소를 위한 상태 변수
    @Published var isRawImage = false
    @Published var bgImg = UIImage(named: "6princess")!
    @Published var idolImg = UIImage(named: "Felix")!
    
    @Published var isAppend = false
    
    @Published var undoHistory:[History] = []
    @Published var redoHistory:[History] = []
    @Published var recentPop:History = History(size: .zero, loc: .zero, ang: .zero, sliderValues: [0.0, 1.0, 1.0]) // 바뀌기전 현재 정보
    @Published var firstOne:History = History(size: .zero, loc: .zero, ang: .zero, sliderValues: [0.0, 1.0, 1.0]) // 원본
    @Published var temp = History(size: .zero, loc: .zero, ang: .zero, sliderValues: [0.0, 1.0, 1.0]) // 원본보기 클릭시 데이터 저장용
    
    @Published var showRawAlert = false
    private var cancellables = Set<AnyCancellable>()
    
    // 편집 옵션 배열
    let colorEditOptions: [IEEditingOption] = [
        IEEditingOption(name: "밝기", icon: "luminosity",range:-0.1...0.1,step: 0.001),
        IEEditingOption(name: "채도", icon: "saturation",range: 0...2,step: 0.01),
        IEEditingOption(name: "대비", icon: "contrast",range: 0.9...1.1,step: 0.001)
    ]
    
    
    func canvasOnAppear(bgImg:UIImage,idolImg:UIImage,bounds:CGSize){
        
        // 배경 이미지의 aspectRatio를 구함
        self.bgRatio = bgImg.size.height / bgImg.size.width
        
//        print("bgRatio:\(self.bgRatio)")
        
        // 아이돌 이미지의 aspectRatio를 구함
        self.idolRatio = idolImg.size.height / idolImg.size.width
//        print("bgImg.size:\(bgImg.size)")
        
        // IECanvasView의 프레임 크기를 구함 for 이미지 저장
        self.screenSize = bounds
        
        // 배경이미지를 scaleToFit하게 만듬
//        let newHeight = self.screenSize.height * 0.68
        // 0.75 0.6
//        self.frameBGSize = CGSize(width: newHeight * (bgImg.size.width / bgImg.size.height), height: newHeight)
        self.frameBGSize = CGSize(width: screenSize.width, height: screenSize.width / 3 * 4 )
        
        self.frameIdolSize = CGSize(width: frameBGSize.width, height: frameBGSize.width * (idolImg.size.height / idolImg.size.width)) // baseWidth를 100으로 지정,세로는 계산
        
        // 뷰생성시 아이돌 이미지 위치 지정
        self.location = CGPoint(x: frameBGSize.width/2, y: self.frameBGSize.height / 2)
        
        self.recentPop = History(size: self.frameIdolSize, loc: self.location, ang: .zero, sliderValues: [0.0, 1.0, 1.0])
        self.firstOne = History(size: self.frameIdolSize, loc: self.location, ang: .zero, sliderValues: [0.0, 1.0, 1.0])
        
        print("idolsize:\(self.frameIdolSize)")
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
        
    }
   
    
    /// 사진 저장 함수
    @MainActor
    func saveRenderedView<T: View>(content: T) { //Content라는 타입을 찾을 수 없어서, 제너릭 타입으로 진행
        // ImageRenderer를 이용해서 합성 이미지 생성
        let renderedImage = ImageRenderer(content: content.frame(width: frameBGSize.width, height: frameBGSize.height))
        
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
        } else {
            print("렌더링 실패: 이미지 생성 실패")
        }
    }
}
