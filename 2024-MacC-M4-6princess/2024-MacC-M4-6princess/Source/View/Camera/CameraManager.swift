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
    @Published var preset: AVCaptureSession.Preset
    @Published var videoDeviceInput: AVCaptureDeviceInput?
    @Published var output: AVCapturePhotoOutput
    @Published var startFactor: CGFloat = 2.0
    @Published var deviceType: AVCaptureDevice.DeviceType
    
    init(session: AVCaptureSession = AVCaptureSession(),
         videoDeviceInput: AVCaptureDeviceInput? = nil,
         output: AVCapturePhotoOutput = AVCapturePhotoOutput()) {
        self.session = session
        self.preset = .photo
        self.videoDeviceInput = videoDeviceInput
        self.output = output
        self.deviceType = .builtInWideAngleCamera
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
    
    //카메라 접근권한 체크 함수
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
    
    //카메라를 처음에 세팅하는 함수
    func setUp() {
        do {
            self.session.beginConfiguration()
            
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInUltraWideCamera,
                    .builtInWideAngleCamera
                ],
                mediaType: .video,
                position: .back
            )
            
            guard let device = getBestCamera(from: discoverySession.devices) else {
                session.commitConfiguration()
                print("사용 가능한 카메라를 찾을 수 없습니다")
                return
            }
            
            self.deviceType = device.deviceType
            self.startFactor = 1.0

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoDeviceInput = input
                    
                    do {
                        try device.lockForConfiguration()
                        if device.deviceType == .builtInUltraWideCamera {
                            device.videoZoomFactor = 2.0
                        } else {
                            device.videoZoomFactor = 1.0
                        }
                        device.unlockForConfiguration()
                    } catch {
                        print("초기 줌 설정 오류: \(error)")
                    }
                }
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                
                self.session.commitConfiguration()
                startSession()
            } catch {
                session.commitConfiguration()
                print("카메라 입력 설정 오류: \(error)")
            }
        }
    }

    
    //기기의 카메라 렌즈 사양에 따라 카메라(비디오렌즈)를 선택
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

    //카메라 전후면 전환
    func changeCamera() {
        guard let currentInput = self.session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .front ? .back : .front
        
        // 후면 카메라로 전환할 때는 항상 UltraWide 카메라를 먼저 시도
        let targetDeviceType: AVCaptureDevice.DeviceType = (newPosition == .back) ? .builtInUltraWideCamera : .builtInWideAngleCamera
        
        guard let newDevice = AVCaptureDevice.default(targetDeviceType, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            // UltraWide 카메라가 없는 경우 WideAngle로 폴백
            guard let fallbackDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let fallbackInput = try? AVCaptureDeviceInput(device: fallbackDevice) else { return }
            
            if session.canAddInput(fallbackInput) {
                session.addInput(fallbackInput)
                self.videoDeviceInput = fallbackInput
                self.deviceType = .builtInWideAngleCamera
                
                do {
                    try fallbackDevice.lockForConfiguration()
                    // WideAngle 카메라일 때는 1.0으로 설정
                    fallbackDevice.videoZoomFactor = 1.0
                    fallbackDevice.unlockForConfiguration()
                } catch {
                    print("줌 설정 오류: \(error)")
                }
            }
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            self.videoDeviceInput = newInput
            self.deviceType = targetDeviceType
            
            do {
                try newDevice.lockForConfiguration()
                if newPosition == .back {
                    // UltraWide 카메라일 때는 2.0으로 설정
                    let zoomFactor = (newDevice.deviceType == .builtInUltraWideCamera) ? 2.0 : 1.0
                    newDevice.videoZoomFactor = zoomFactor
                    newDevice.ramp(toVideoZoomFactor: zoomFactor, withRate: 1.0)
                } else {
                    newDevice.videoZoomFactor = 1.0
                }
                newDevice.unlockForConfiguration()
            } catch {
                print("카메라 전환 시 줌 설정 오류: \(error)")
            }
        }
        
        session.commitConfiguration()
    }
    
    //카메라 세션 시작
    func startSession() {
        Task {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    //카메라 세션 멈춤
    func stopSession() {
        Task {
            if !self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    //사진 처리를 시작하는 함수
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
    
    //줌 범위를 확인하고 부드럽게 해주는 줌 모션을 관리하는 함수
    func zoom(_ zoom: CGFloat) {
        guard let device = self.videoDeviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            
            // 줌 범위 확인 및 적용
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = device.maxAvailableVideoZoomFactor
            let finalZoom = min(max(zoom, minZoom), maxZoom)
            
            // 부드러운 줌 적용
            device.ramp(toVideoZoomFactor: finalZoom, withRate: 100.0)
            
            device.unlockForConfiguration()
        } catch {
            print("줌 설정 오류: \(error.localizedDescription)")
        }
    }
}


