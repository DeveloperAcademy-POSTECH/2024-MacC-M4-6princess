//
//  CameraModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/1/24.
//

import SwiftUI
import AVFoundation
import Photos

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    //온보딩 확인용
//    @State var firstTime = false
    @AppStorage("openFirstTime") var firstTime = false
//    @ObservedObject var frameManager = FrameManager()
    
    @Published var isTakenPhoto = false
    @Published var isAllTakenPhoto = false
    @Published var isSavedPhotoData = false
    @Published var picData = Data(count: 0)
    @Published var takenImg: UIImage?
    @Published var nextView = false
    @Published var saveComplete = false
    @Published var frameSize = CGRect(origin: .zero, size: .zero)
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // 프레임 관련 상태
    @Published var frameRatio: CGFloat = 4/3
    
    // 타이머 관련 상태
    @Published var delayTime: TimeInterval = 0.0
    @Published var isPushedTimer = 0
    @Published var isTakePic = false
    
    // 프레임 선택 관련 상태
    @Published var isShowAlert = false //프레임 없을 때 alert
    @Published var inputImage: UIImage?
    
    //줌 관련
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0
    
    //카메라 화면전환 관련
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    
    // 이미지 관련
    @Published var idolImg: UIImage
    let defaultImg: UIImage
    var ScreenSize:CGSize = UIScreen.main.bounds.size
    let cameraManager: CameraManager
    
    //저장 관련
    @Published var frameBGSize: CGSize = .zero
    @Published var compositeImage:UIImage?

    init(cameraManager: CameraManager = CameraManager()) {
        self.cameraManager = cameraManager
        self.idolImg = UIImage(named: "Felix") ?? UIImage()
        self.defaultImg = UIImage(named: "whiteBG") ?? UIImage()
        super.init()
        setupPreviewLayer()
        
        if cameraManager.deviceType == .builtInWideAngleCamera {
            self.currentZoomFactor = 2.0
        }
        else {
            self.currentZoomFactor = 1.0
        }
    }
    
    private func setupPreviewLayer() {
        preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        preview.videoGravity = .resizeAspectFill
    }
    
    
    //    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    //        print("카메라 셔터음 무음으로 변경됨")
    //        AudioServicesDisposeSystemSoundID(1108)
    //
    //    }
    //    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    //        AudioServicesDisposeSystemSoundID(1108)
    //    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 처리 중 에러 발생: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              var image = UIImage(data: imageData) else {
            print("이미지를 생성할 수 없습니다.")
            return
        }
        
        // 전면 카메라일 경우 좌우 반전 처리
        if self.cameraManager.videoDeviceInput?.device.position == .front {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        }
        
        // 이미지의 방향을 .up으로 수정
        image = fixOrientation(image)
        
        // 원하는 비율로 이미지 크롭
        let croppedImage = cropToAspectRatio(image: image)
        
        // 합성 이미지 생성
        let renderer = UIGraphicsImageRenderer(size: frameSize.size)
        let compositeImage = renderer.image { context in
            // 크롭된 이미지 그리기
            croppedImage.draw(in: CGRect(origin: .zero, size: frameSize.size))
            
            // 프레임 이미지 합성
            frameImage.draw(in: CGRect(origin: .zero, size: frameSize.size))
        }
        
        DispatchQueue.main.async {
            self.picData = croppedImage.jpegData(compressionQuality: 1.0) ?? Data()
            self.takenImg = compositeImage
            self.nextView = true
            self.saveImageToAlbum(uiImage: compositeImage)
            print("nextView:\(self.nextView)")
            print("이미지 사이즈: \(croppedImage.size)")
            print("사진이 성공적으로 처리되었습니다")
        }
    }
    
    func cropToAspectRatio(image: UIImage) -> UIImage  {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        
        let cropRect: CGRect = CGRect(x: 0, y: (height - (width * 4/3))/2 - 3
                                      , width: width, height: width * frameRatio)
        
        print("높이는 \((height - (width * 4/3))/2 - 3)")
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func takePic() {
        // 메인 큐에서 실행
        DispatchQueue.main.async {
            self.cameraManager.takePicture(delegate: self)
            self.isTakenPhoto.toggle()
        }
    }
    
    func changeCamera() {
        cameraManager.changeCamera()
        cameraPosition = cameraManager.videoDeviceInput?.device.position ?? .back
        
        // 카메라 전환 시 적절한 초기 줌 팩터 설정
        if cameraPosition == .back {
            if cameraManager.deviceType == .builtInUltraWideCamera {
                currentZoomFactor = 2.0
            } else {
                currentZoomFactor = 1.0
            }
        } else {
            currentZoomFactor = 1.0
        }
        
        lastScale = 1.0
    }
    
    func fixOrientation(_ image: UIImage) -> UIImage {
        // 이미지의 방향이 이미 .up이면 그대로 반환
        if image.imageOrientation == .up {
            return image
        }
        
        // 그래픽 컨텍스트 생성
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        // 새로운 UIImage 생성
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func zoom(factor: CGFloat) {
        let delta = factor / lastScale
        lastScale = factor
        
        // 현재 줌 상태에서 변화량을 적용
        var newZoomFactor = currentZoomFactor * delta
        
        // 최소/최대 줌 팩터 제한
        if let device = cameraManager.videoDeviceInput?.device {
            let minZoom: CGFloat = 1.0
            let maxZoom: CGFloat = device.deviceType == .builtInUltraWideCamera ? 4.0 : 3.0
            newZoomFactor = min(max(newZoomFactor, minZoom), maxZoom)
            
            // 줌 적용
            cameraManager.zoom(newZoomFactor)
            
            // currentZoomFactor 실시간 업데이트
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                currentZoomFactor = newZoomFactor
            }
        }
    }

    
    private func mapToNearestZoomFactor(_ factor: CGFloat) -> CGFloat {
        let zoomFactors: [CGFloat] = cameraPosition == .back ?
            [0.5, 1.0, 2.0, 3.0] : [1.0, 2.0, 3.0]
        
        return zoomFactors.min(by: { abs($0 - factor) < abs($1 - factor) }) ?? factor
    }

    func setZoom(factor: CGFloat) {
        guard let device = cameraManager.videoDeviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            let actualZoomFactor = if device.position == .back {
                if cameraManager.deviceType == .builtInUltraWideCamera {
                    factor
                } else {
                    factor * 2
                }
            } else {
                factor
            }
            
            device.ramp(toVideoZoomFactor: actualZoomFactor, withRate: 100.0)
            device.videoZoomFactor = actualZoomFactor
            device.unlockForConfiguration()
            currentZoomFactor = factor // 실제 줌 팩터 저장
        } catch {
            print("줌 설정 오류: \(error.localizedDescription)")
        }
    }

    func zoomInitialize() {
        lastScale = 1.0  // 제스처를 위한 scale만 초기화
        print("lastScale 초기화됨")
    }

    func getZoomRange(for device: AVCaptureDevice) -> ClosedRange<CGFloat> {
        if device.position == .back {
            switch device.deviceType {
            case .builtInUltraWideCamera:
                return 2.0...4.0
            case .builtInWideAngleCamera:
                return 1.0...3.0
            default:
                return 1.0...device.maxAvailableVideoZoomFactor
            }
        } else {
            // 전면 카메라는 1.0...3.0 범위 사용
            return 1.0...3.0
        }
    }
    
    //MARK: 실험 함수
//    @MainActor
//    func capturePreview<T: View>(content: T) { //Content라는 타입을 찾을 수 없어서, 제너릭 타입으로 진행
//        let renderedImage = ImageRenderer(
//            content: content
//                .frame(width: frameBGSize.width, height: frameBGSize.width * 4/3)
//        )
//        // 해상도
//        renderedImage.scale = 8.0
//        
//        if let uiImage = renderedImage.uiImage {
//            self.compositeImage = uiImage
//            saveImageToAlbum(uiImage: uiImage)
//        } else {
//            print("렌더링 실패: 이미지 생성 실패")
//        }
//    }
    
    // CameraViewModel에 추가
    func processCapturedImage(_ photo: AVCapturePhoto) {
        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else { return }
        
        let renderer = UIGraphicsImageRenderer(size: frameSize.size)
        
        let compositeImage = renderer.image { context in
            // 캡처된 사진을 프레임 크기에 맞게 그리기
            capturedImage.draw(in: CGRect(origin: .zero, size: frameSize.size))
            
            // 프레임 이미지 합성
            if let frameImage = frameManager.resultImage {
                frameImage.draw(in: CGRect(origin: .zero, size: frameSize.size))
            }
        }
        
        self.takenImg = compositeImage
        saveImageToAlbum(uiImage: compositeImage)
        self.nextView = true
        self.cameraManager.stopSession()
    }
    
    func saveImageToAlbum(uiImage: UIImage) {
        // 앨범 이름 설정
        let albumName = "Frameet"
        
        // 1. 앨범 가져오기 또는 생성하기
        func getAlbum(completion: @escaping (PHAssetCollection?) -> Void) {
            // 앨범이 이미 존재하는지 확인
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let album = fetchResult.firstObject {
                // 앨범이 이미 존재하면 반환
                completion(album)
            } else {
                // 앨범이 존재하지 않으면 생성
                var albumPlaceholder: PHObjectPlaceholder?
                PHPhotoLibrary.shared().performChanges({
                    let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                    albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }) { success, error in
                    if success, let placeholder = albumPlaceholder {
                        let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                        completion(fetchResult.firstObject)
                    } else {
                        print("앨범 생성 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                        completion(nil)
                    }
                }
            }
        }
        
        // 2. 사진 저장 및 앨범에 추가
        func saveImageToAlbum(album: PHAssetCollection?) {
            guard let album = album else {
                print("앨범을 찾을 수 없습니다.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                // 이미지 저장
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                
                // 앨범에 추가하기 위한 요청
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
                        print("사진 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            }
        }
        
        // 앨범 가져오기 또는 생성 후 사진 저장
        getAlbum { album in
            saveImageToAlbum(album: album)
        }
    }
}

