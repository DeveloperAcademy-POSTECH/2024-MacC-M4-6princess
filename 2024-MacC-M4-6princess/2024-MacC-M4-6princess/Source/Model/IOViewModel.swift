//
//  IOViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/28/24.
//
// TODO: ImageRenererService 생성
// PhotoLibraryService에서 사진 권한/저장
//
import SwiftUI
import Photos

class IOViewModel: ObservableObject {
    /// for 에러 알림창
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var frameBGSize: CGSize = .zero // 프레임상의 축소된 배경 이미지 크기
    var compositeImage:UIImage?
    var bgImg: UIImage?
    var idolImg: UIImage?
    @Published var frameIdolSize: CGSize = .zero // 프레임상 아이돌 이미지 크기
    @Published var location: CGPoint = CGPoint(x: 100, y: 100)
    //    @Published var screenSize: CGSize = .zero
    /// for 이미지 저장
    //    @Published var savePhoto = false
    @Published var saveAnimate = false
    
    @Published var showShareButton = false
    @Published var showAcitivity = false
    @Published var changeOverlay = false
    var currentOrientation:UIDeviceOrientation = .portrait
    
    
    /// 뷰를 이미지로 변환 후 저장
    @MainActor
    func renderAndSaveViewImage<T: View>(content: T, motionManager: MotionManager,orientation:UIDeviceOrientation) {
        guard frameBGSize.width > 0 , frameBGSize.height > 0 else {
            showAlert(message: "화면 초기화 전입니다. 잠시 후 다시 시도해 주세요")
            return
        }
        guard let uiImage = renderImage(content, motionManager) else {
            showAlert(message: "렌더링 실패: 다시 시도해주세요.\n에러가 반복될 시 캡쳐후 제보부탁드립니다.")
            return
        }

        self.compositeImage = uiImage
        requestPhotoLibraryPermission { granted in
            if granted {
                self.saveImageToAlbum(uiImage: uiImage)
            }
            else{
                self.showAlert(message: "사진 저장 권한이 필요합니다.\n 설정에서 권한 설정을 해주세요.")
            }
        }
        /// 뷰를 uiImage로 변환
        @MainActor
        func renderImage<Content: View>(_ content: Content, _ motionManager: MotionManager) -> UIImage? {
            // 원본 크기의 2배로 렌더링
            let renderWidth = frameBGSize.width * 2
            let renderHeight = renderWidth * 4/3
            
            let renderer = ImageRenderer(
                content: content
                    .frame(width: renderWidth, height: renderHeight)
            )
            
            // 해상도 설정 (디바이스 스케일 유지)
            renderer.scale = UIScreen.main.scale
            
            // 렌더링된 이미지를 원본 크기로 리사이징
            if let renderedImage = renderer.uiImage {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: frameBGSize.width, height: frameBGSize.width * 4/3), false, UIScreen.main.scale)
                renderedImage.draw(in: CGRect(x: 0, y: 0, width: frameBGSize.width, height: frameBGSize.width * 4/3))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return resizedImage
            }
            return nil
        }
//        /// 기기의 방향에 따른 이미지 회전을 재조정하여 .up 회전으로 모두 통일
//        func applyOrientationToImage(uiImage:UIImage,motionManager: MotionManager) -> UIImage {
//            
//            let orientation = motionManager.imageRotate()
//            if orientation == .up {return uiImage} // 정방형일 때 그대로 내보냄
//            guard let cgImage = uiImage.cgImage else { return uiImage } // cgImage로 변환 실패시 그대로 내보냄
//            
//            return UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: orientation)
//            
//        }
        
        func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        completion(true)
                    case .denied, .restricted:
                        self.showAlert(message: "갤러리 접근이 거부되어 저장할 수 없습니다.\n설정에서 권한을 허용해주세요.")
                        completion(false)
                    case .notDetermined:
                        self.showAlert(message: "갤러리 권한을 확인 중입니다.")
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        }
        
    }
    
    
    
    
    /// 앨범에 이미지를 저장
    func saveImageToAlbum(uiImage: UIImage) {
        let albumName = "Frameet"
        
        getAlbum { album in
            saveImageToAlbum(album: album)
        }
        
        func getAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
            
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
                        let errorMessage = error?.localizedDescription ?? "알 수 없는 오류"
                        self.showAlert(message: "사진 저장 실패: \(errorMessage)")
                    }
                }
            }
        }
        
    }
    
    /// 뷰가 생성될 때 화면을 초기화하는 함수
    func canvasOnAppear(bgImg: UIImage, idolImg: UIImage, bounds: CGSize) {
        let screenWidth = bounds.width
        let bgImageRatio = bgImg.size.height / bgImg.size.width
        
        self.frameBGSize = CGSize(width: screenWidth, height: screenWidth * bgImageRatio)
        
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
    
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }
}

