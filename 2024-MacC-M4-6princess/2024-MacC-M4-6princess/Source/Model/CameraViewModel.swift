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

    
    @Published var isTakenPhoto = false
    @Published var isAllTakenPhoto = false
    @Published var isSavedPhotoData = false
    @Published var picData = Data(count: 0)
    @Published var takenImg: UIImage?
    @Published var nextView = false
    @Published var frameSize = CGRect(origin: .zero, size: .zero)
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // 프레임 관련 상태
    @Published var frameRatio: CGFloat = 4/3
    
    // 타이머 관련 상태
    @Published var delayTime: TimeInterval = 0.0
    @Published var isTakePic = false
    @Published var remainingTime: TimeInterval = 0
    @Published var backgroundOpacity: Double = 0
    @Published var opacity: Double = 1
    @Published var showCountdown: Bool = true
    
    // 타이머 관련 상태 - iPad
    @Published var isPushedTimer: Int = 0
    
    // 프레임 선택 관련 상태
    @Published var isShowAlert = false //프레임 없을 때 alert
    @Published var inputImage: UIImage?
    
    //줌 관련
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0
    
    //카메라 화면전환 관련
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    
    @Published var showOrientationAlert: Bool = false
    
    //오류 알림
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    // 이미지 관련
    @Published var idolImg: UIImage
    let defaultImg: UIImage
    var ScreenSize:CGSize = UIScreen.main.bounds.size
    let cameraManager: CameraManager
    let motionManager = MotionManager()
    
    init(cameraManager: CameraManager = CameraManager()) {
        self.cameraManager = cameraManager
        self.idolImg = UIImage(named: "Felix") ?? UIImage()
        self.defaultImg = UIImage(named: "whiteBG") ?? UIImage()
        super.init()
        setupPreviewLayer()
        
        self.currentZoomFactor = 1.0
        _ = motionManager
    }
    
    private func setupPreviewLayer() {
        preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        preview.videoGravity = .resizeAspectFill
    }
    
        //무음으로 작업할때만 사용하는 함수. 지우면 슬퍼요
            func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
                print("카메라 셔터음 무음으로 변경됨")
                AudioServicesDisposeSystemSoundID(1108)
        
            }
            func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
                AudioServicesDisposeSystemSoundID(1108)
            }
    
    
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
        
        // 이미지의 방향을 .up으로 수정. 이미지 프리뷰를 위함
        image = fixOrientation(image)
        
        let croppedImage = cropToAspectRatio(image: image)
        
        DispatchQueue.main.async {
            self.picData = croppedImage.jpegData(compressionQuality: 1.0) ?? Data()
            self.takenImg = croppedImage
            self.nextView = true
            //            print("nextView:\(self.nextView)")
            //            print("이미지 사이즈: \(image.size)")
            print("사진이 성공적으로 처리되었습니다")
        }
    }
    
    // 기기 방향에 따라 이미지 회전하는 함수 추가
    func rotateImage(_ image: UIImage, basedOn orientation: UIDeviceOrientation) -> UIImage {
        switch orientation {
        case .landscapeLeft:
            return image.rotate(radians: .pi/2)  // 오른쪽으로 90도 회전
        case .landscapeRight:
            return image.rotate(radians: -.pi/2)  // 왼쪽으로 90도 회전
        default:
            return image
        }
    }
    
    //이미지를 비율에 맞게 크롭
    func cropToAspectRatio(image: UIImage) -> UIImage  {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        
        let cropRect: CGRect = CGRect(x: 0, y: (height - (width * 4/3))/2 - 3
                                      , width: width, height: width * frameRatio)
        
        //        print("높이는 \((height - (width * 4/3))/2 - 3)")
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    //셔터가 눌리면 실행되는 함수
    func takePic() {
        // 메인 큐에서 실행
        if !self.cameraManager.session.isRunning {
            self.cameraManager.startSession()
            // 세션이 시작될 때까지 잠시 대기
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cameraManager.takePicture(delegate: self)
                self.isTakenPhoto.toggle()
            }
        } else {
            self.cameraManager.takePicture(delegate: self)
            self.isTakenPhoto.toggle()
        }
    }
    
    //카메라 전후면 전환(초기 줌 팩터를 다시 맞춰줌)
    func changeCamera() {
        cameraManager.changeCamera()
        cameraPosition = cameraManager.videoDeviceInput?.device.position ?? .back
        currentZoomFactor = cameraManager.videoDeviceInput?.device.videoZoomFactor ?? 1.0
        
        // 카메라 전환 시 적절한 초기 줌 팩터 설정
        if cameraPosition == .back {
            currentZoomFactor = 1.0
        } else {
            currentZoomFactor = 1.0
        }
        
        lastScale = 1.0
    }
    
    //이미지 방향 수정 함수
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
    
    //메인 줌 함수
    func zoom(factor: CGFloat) {
        let delta = factor / lastScale
        lastScale = factor
        
        // 현재 줌 상태에서 변화량을 적용
        var newZoomFactor = currentZoomFactor * delta
        
        // 최소/최대 줌 팩터 제한
        if let device = cameraManager.videoDeviceInput?.device {
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = device.maxAvailableVideoZoomFactor
            newZoomFactor = min(max(newZoomFactor, minZoom), maxZoom)
            
            // 줌 적용
            if let appliedZoom = cameraManager.applyZoomFactor(newZoomFactor) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    currentZoomFactor = appliedZoom
                }
            }
        }
    }
    
    //해당 factor로 줌을 해주는 함수
    func setZoom(factor: CGFloat) {
        if let appliedZoom = cameraManager.applyZoomFactor(factor) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                currentZoomFactor = appliedZoom
            }
        }
    }
    
    //줌 스케일 초기화
    func zoomInitialize() {
        lastScale = 1.0  // 제스처를 위한 scale만 초기화
        print("lastScale 초기화됨")
    }
    
    //기기에 따른 줌 범위 설정
    func getZoomRange(for device: AVCaptureDevice) -> ClosedRange<CGFloat> {
        let minZoom = device.minAvailableVideoZoomFactor
        let maxZoom = device.maxAvailableVideoZoomFactor
        return minZoom...maxZoom
    }
    
    var minDeviceZoom: CGFloat {
        cameraManager.minAvailableZoomFactor
    }
    
    var maxDeviceZoom: CGFloat {
        cameraManager.maxAvailableZoomFactor
    }


}
