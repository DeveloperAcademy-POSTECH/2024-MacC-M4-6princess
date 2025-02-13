//
//  IOViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/28/24.
//

import SwiftUI
import Photos

class IOViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var frameBGSize: CGSize = .zero // 프레임상의 축소된 배경 이미지 크기
    @Published var compositeImage:UIImage?
    @Published var bgImg: UIImage?
    @Published var idolImg: UIImage?
    @Published var frameIdolSize: CGSize = .zero // 프레임상 아이돌 이미지 크기
    @Published var location: CGPoint = CGPoint(x: 100, y: 100)
    @Published var screenSize: CGSize = .zero
    /// for 이미지 저장
    @Published var savePhoto = false
    @Published var saveAnimate = false
    
    //    /// 사진 저장 함수
    //    @MainActor
    //    func saveRenderedView<T: View>(content: T, motionManager: MotionManager) {
    //        let renderedImage = ImageRenderer(
    //            content: content
    //                .frame(width: frameBGSize.width, height: frameBGSize.width * 4/3)
    //        )
    //        // 해상도
    //        renderedImage.scale = 10.0
    //
    //        if var uiImage = renderedImage.uiImage {
    //            // 기기 방향에 따라 이미지 회전
    //            let orientation = motionManager.imageRotate()
    //            if orientation != .up {
    //                if let cgImage = uiImage.cgImage {
    //                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: orientation)
    //                }
    //            }
    //
    //            self.compositeImage = uiImage
    //            saveImageToAlbum(uiImage: uiImage)
    //        } else {
    //            showAlert(message: "렌더링 실패: 이미지 생성에 문제가 발생했습니다.")
    //        }
    //    }
    
    // 배경 이미지와 프레임 이미지를 합성하여 저장
    func combineAndSave(bgImage: UIImage, frameImage: UIImage, scaleFactor: CGFloat) {
        // 원본 이미지 크기 가져오기
        let originalSize = bgImage.size
        
        // 스케일링된 크기 계산 (10배)
        let targetSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        
        // UIGraphicsImageRendererFormat으로 스케일 설정
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // 픽셀 단위 작업 (스케일은 렌더링 크기에서 이미 반영됨)
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let combinedImage = renderer.image { context in
            // 배경 이미지 그리기
            bgImage.draw(in: CGRect(origin: .zero, size: targetSize))
            
            // 프레임 이미지 크기 계산 (스케일 적용)
            let scaledFrameSize = CGSize(width: frameImage.size.width * scaleFactor, height: frameImage.size.height * scaleFactor)
            
            // 프레임 이미지 중앙 정렬
            let frameRect = CGRect(
                x: (targetSize.width - scaledFrameSize.width) / 2,
                y: (targetSize.height - scaledFrameSize.height) / 2,
                width: scaledFrameSize.width,
                height: scaledFrameSize.height
            )
            frameImage.draw(in: frameRect, blendMode: .normal, alpha: 1.0)
        }
        
        // 합성된 이미지를 저장
        saveImageToAlbum(uiImage: combinedImage)
        
        // 합성된 이미지 설정
        DispatchQueue.main.async {
            self.compositeImage = combinedImage
        }
    }
    
    
    func saveImageToAlbum(uiImage: UIImage) {
        let albumName = "Frameet"
        
        func getAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = fetchResult.firstObject {
                completion(album)
            } else {
                var albumPlaceholder: PHObjectPlaceholder?
                PHPhotoLibrary.shared().performChanges({
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }) { success, error in
                    if success, let placeholder = albumPlaceholder {
                        let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                        completion(fetchResult.firstObject)
                    } else {
                        self.showAlert(message: "앨범 생성 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                        completion(nil)
                    }
                }
            }
        }
        
        func saveImageToAlbum(album: PHAssetCollection?) {
            guard let album = album else {
                self.showAlert(message: "앨범을 찾을 수 없습니다.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset,
                   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    let fastEnumeration = NSArray(array: [assetPlaceholder])
                    albumChangeRequest.addAssets(fastEnumeration)
                }
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("사진이 앨범 '\(albumName)'에 성공적으로 저장되었습니다.")
                    } else {
                        self.showAlert(message: "사진 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            }
        }
        
        getAlbum { album in
            saveImageToAlbum(album: album)
        }
    }
    
    //    func canvasOnAppear(bgImg:UIImage,idolImg:UIImage,bounds:CGSize){
    //        self.screenSize = bounds
    //
    //        // 배경 이미지의 가로가 세로보다 긴 경우
    //        if bgImg.size.width / bgImg.size.height > 1 {
    //            // 가로가 더 긴 이미지의 경우, 화면 너비를 기준으로 높이 계산
    //            self.frameBGSize = CGSize(
    //                width: screenSize.width,
    //                height: screenSize.width * (bgImg.size.height / bgImg.size.width)
    //            )
    //        } else {
    //            // 세로가 더 긴 이미지의 경우, 기존 로직 유지
    //            self.frameBGSize = CGSize(
    //                width: screenSize.width,
    //                height: screenSize.width * (bgImg.size.height / bgImg.size.width)
    //            )
    //        }
    //
    //        // 아이돌 이미지 크기 조정
    //        self.frameIdolSize = CGSize(
    //            width: frameBGSize.width,
    //            height: frameBGSize.width * (idolImg.size.height / idolImg.size.width)
    //        )
    //
    //        // 뷰 생성 시 아이돌 이미지 위치 지정
    //        self.location = CGPoint(
    //            x: frameBGSize.width / 2,
    //            y: self.frameBGSize.height / 2
    //        )
    //    }
    func canvasOnAppear(bgImg: UIImage, idolImg: UIImage, bounds: CGSize) {
        let screenWidth = bounds.width
        let bgImageRatio = bgImg.size.height / bgImg.size.width
        
        // 가로/세로 비율에 따른 동적 크기 계산
        if bgImg.size.width > bgImg.size.height {
            // 가로가 긴 이미지의 경우
            self.frameBGSize = CGSize(
                width: screenWidth,
                height: screenWidth * bgImageRatio
            )
        } else {
            // 세로가 긴 이미지의 경우 (기존 로직)
            self.frameBGSize = CGSize(
                width: screenWidth,
                height: screenWidth * bgImageRatio
            )
        }
        
        // 아이돌 이미지 크기도 동일한 비율로 조정
        self.frameIdolSize = CGSize(
            width: frameBGSize.width,
            height: frameBGSize.width * (idolImg.size.height / idolImg.size.width)
        )
        
        // 중앙 위치 지정
        self.location = CGPoint(
            x: frameBGSize.width / 2,
            y: frameBGSize.height / 2
        )
    }
    
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }
}
