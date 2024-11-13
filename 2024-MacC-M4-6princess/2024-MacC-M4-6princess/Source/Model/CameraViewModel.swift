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
    
    @AppStorage("openFirstTime") var firstTime = false
    //        @State var firstTime = false
    
    @Published var isTakenPhoto = false
    @Published var isAllTakenPhoto = false
    @Published var isSavedPhotoData = false
    @Published var picData = Data(count: 0)
    @Published var takenImg: UIImage?
    @Published var nextView = false
    @Published var frameSize = CGRect(origin: .zero, size: .zero)
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // 프레임 관련 상태
    @Published var frameImage: UIImage?
    @Published var frameRatio: CGFloat = 4/3
    
    // 타이머 관련 상태
    @Published var delayTime: TimeInterval = 0.0
    @Published var isPushedTimer = 0
    @Published var isTakePic = false
    
    // 프레임 선택 관련 상태
    @Published var isFrameSelect = false
    @Published var isFullScreenPop: Bool = false
    @Published var selectedFrame: UUID? = nil
    @Published var isFrameSelected: Bool = false
    @Published var showAlert = false
    @Published var isFrameLoading: Bool = false
    @Published var inputImage: UIImage?
    
    //줌 관련
    @Published var currentZoomFactor: CGFloat = 2.0
    @Published var lastScale: CGFloat = 1.0
    
    //카메라 화면전환 관련
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    
    // 이미지 관련
    @Published var idolImg: UIImage
    let defaultImg: UIImage
    var ScreenSize:CGSize = UIScreen.main.bounds.size
    let cameraManager: CameraManager

    init(cameraManager: CameraManager = CameraManager()) {
        self.cameraManager = cameraManager
        self.idolImg = UIImage(named: "Felix") ?? UIImage()
        self.defaultImg = UIImage(named: "whiteBG") ?? UIImage()
        super.init()
        setupPreviewLayer()
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
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("사진 데이터가 유효하지 않음")
            return
        }
        
        guard var image = UIImage(data: imageData) else {
            print("이미지를 생성할 수 없습니다.")
            return
        }
        
        // 전면 카메라일 경우 좌우 반전 처리
        if self.cameraManager.videoDeviceInput?.device.position == .front {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        }
        
        // 이미지 크기를 frameSize로 조정
        //        let renderer = UIGraphicsImageRenderer(size: frameSize.size)
        //        image = renderer.image { _ in
        //            image.draw(in: CGRect(origin: .zero, size: frameSize.size))
        //        }
        
        // 이미지의 방향을 .up으로 수정
        image = fixOrientation(image)
        
        let croppedImage = cropToAspectRatio(image: image)
        
        DispatchQueue.main.async {
            self.picData = croppedImage.jpegData(compressionQuality: 1.0) ?? Data()
            self.takenImg = croppedImage
            self.nextView = true
            print("nextView:\(self.nextView)")
            print("이미지 사이즈: \(image.size)")
            print("사진이 성공적으로 처리되었습니다")
        }
    }
    
    func cropToAspectRatio(image: UIImage) -> UIImage  {
        let originalWidth = image.size.width
        let cropRect: CGRect = CGRect(x: 0, y: 120, width: originalWidth, height: originalWidth * frameRatio)
        
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
        if cameraManager.videoDeviceInput?.device.position == .front {
            cameraPosition = .back
            currentZoomFactor = 1.0
        }
        else {
            cameraPosition = .front
            currentZoomFactor = 0.8
        }
        
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
    
    // 줌 제스처를 위한 함수
    func zoom(factor: CGFloat) {
        let delta = factor / lastScale
        lastScale = factor
        
        // 현재 줌 상태에서 변화량을 적용
        setZoom(factor: currentZoomFactor * delta)
    }

    // 버튼이나 직접 줌 설정을 위한 함수
    func setZoom(factor: CGFloat) {
        guard let device = cameraManager.videoDeviceInput?.device else { return }
        let zoomRange = getZoomRange(for: device)
        let newScale = min(max(factor, zoomRange.lowerBound), zoomRange.upperBound)
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = newScale
            device.unlockForConfiguration()
            currentZoomFactor = newScale  // 현재 줌 상태 업데이트
        } catch {
            print("줌 설정 오류: \(error)")
        }
    }

    func zoomInitialize() {
        lastScale = 1.0  // 제스처를 위한 scale만 초기화
        print("스케일 초기화됨")
    }

    func getZoomRange(for device: AVCaptureDevice) -> ClosedRange<CGFloat> {
        switch device.deviceType {
        case .builtInUltraWideCamera:
            return 2.0...4.0
        case .builtInWideAngleCamera:
            return 1.0...3.0
        default:
            return 1.0...device.maxAvailableVideoZoomFactor
        }
    }
}

