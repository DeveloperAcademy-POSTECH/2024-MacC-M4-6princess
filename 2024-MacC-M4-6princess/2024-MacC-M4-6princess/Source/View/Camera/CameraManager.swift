//
//  CameraModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/26/24.
//

import SwiftUI
import AVFoundation
import Photos

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didCapturePhoto photo: AVCapturePhoto)
    func cameraManager(_ manager: CameraManager, didFailWithError error: Error)
}

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate {
    weak var delegate: CameraManagerDelegate?
    @Published var session: AVCaptureSession
    @Published var videoDeviceInput: AVCaptureDeviceInput?
    @Published var output: AVCapturePhotoOutput
    @Published var startFactor: CGFloat = 2.0
    @Published var device: AVCaptureDevice.DeviceType
    
    init(session: AVCaptureSession = AVCaptureSession(),
         videoDeviceInput: AVCaptureDeviceInput? = nil,
         output: AVCapturePhotoOutput = AVCapturePhotoOutput()) {
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.output = output
        self.device = .builtInWideAngleCamera
        super.init()
    }
    
    enum AuthorizationStatus {
        case authorized
        case notDetermined
        case denied
        case restricted
        
        static func fromAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> AuthorizationStatus {
            switch status {
            case .authorized: return .authorized
            case .notDetermined: return .notDetermined
            case .denied: return .denied
            case .restricted: return .restricted
            @unknown default: return .denied
            }
        }
    }
    
    enum SetupResult {
        case success
        case failed(Error)
        case notAuthorized
    }
    
    func checkVideoAuthorizaion() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setUp()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setUp()
                    }
                }
            }
        case .denied:
            print("카메라 접근권한 denied")
        case .restricted:
            print("카메라 접근권한 restricted")
        @unknown default:
            print("카메라 접근권한 알 수 없는 상태")
        }
    }
    
    func setUp() {
        do {
            // 세션 구성 시작
            self.session.beginConfiguration()
            
            // 사용 가능한 카메라 확인
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInUltraWideCamera,
                    .builtInWideAngleCamera,
                    .builtInDualCamera,
                    .builtInTripleCamera
                ],
                mediaType: .video,
                position: .back
            )
            
            // 사용 가능한 카메라 중 최적의 카메라 선택
            guard let device = getBestCamera(from: discoverySession.devices) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No available camera"])
            }
            
//            if device.deviceType == .builtInUltraWideCamera {
//                device.videoZoomFactor = 2.0
//            }
//            else if device.deviceType == .builtInWideAngleCamera {
//                device.videoZoomFactor = 1.0
//            }
//            else {
//                device.videoZoomFactor = 1.0
//            }
            // 초기 줌 팩터 설정
            self.startFactor = (device.deviceType == .builtInUltraWideCamera) ? 2.0 : 1.0
            
            print("설정된 렌즈 : \(device.deviceType.rawValue)")
            
            
            // 새 입력 생성
            let input = try AVCaptureDeviceInput(device: device)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoDeviceInput = input
            }
            
            // 출력 설정
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            // 세션 구성 완료
            self.session.commitConfiguration()
            
            // 세션 시작
            startSession()
        } catch {
            print("카메라 설정 오류: \(error)")
        }
    }
    
    func getBestCamera(from devices: [AVCaptureDevice]) -> AVCaptureDevice? {
        // 우선순위에 따라 카메라 선택
        if let ultraWideCamera = devices.first(where: { $0.deviceType == .builtInUltraWideCamera }) {
            return ultraWideCamera
        }
        if let wideAngleCamera = devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
            return wideAngleCamera
        }
        
        // 기본 카메라 반환
        return devices.first
    }

    
    func changeCamera() {
        guard let currentInput = self.session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        
        // 기존 입력 제거
        session.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .front ? .back : .front
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        // 새로운 입력 추가
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            self.videoDeviceInput = newInput
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        Task {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        Task {
            if !self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func takePicture(delegate: AVCapturePhotoCaptureDelegate) {
        guard session.isRunning else {
            print("세션이 실행중이지 않습니다")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        // 메인 스레드에서 실행
        DispatchQueue.main.async {
            self.output.capturePhoto(with: settings, delegate: delegate)
        }
    }
    func zoom(_ zoom: CGFloat) {
        let device = self.videoDeviceInput!.device
        
        // 새로운 줌 팩터 계산
        let factor = zoom < startFactor ? startFactor : zoom
        
        do {
            try device.lockForConfiguration()
            
            // 줌 범위 확인
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = device.maxAvailableVideoZoomFactor
            let finalZoom = min(max(factor, minZoom), maxZoom)
            
            // 부드러운 줌 적용
            device.ramp(toVideoZoomFactor: finalZoom, withRate: 1.0)
            // 또는 즉시 적용하려면: device.videoZoomFactor = finalZoom
            
            device.unlockForConfiguration()
        } catch {
            print("줌 설정 오류: \(error.localizedDescription)")
        }
    }
}


