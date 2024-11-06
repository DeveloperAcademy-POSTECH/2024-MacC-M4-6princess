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
    
    init(session: AVCaptureSession = AVCaptureSession(),
         videoDeviceInput: AVCaptureDeviceInput? = nil,
         output: AVCapturePhotoOutput = AVCapturePhotoOutput()) {
        self.session = session
        self.videoDeviceInput = videoDeviceInput
        self.output = output
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
    
    // In CameraManager.swift, modify checkVideoAuthorizaion():
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
        
        self.session.automaticallyConfiguresCaptureDeviceForWideColor = false
            
            // 이미 실행 중이면 중단
//            if self.session.isRunning {
//                return
//            }
            
            // 세션 구성 시작
            self.session.beginConfiguration()
            
            // 기존 입력/출력 모두 제거
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
            
            do {
                // 카메라 디바이스 설정
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                    print("카메라를 찾을 수 없습니다")
                    return
                }
                
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
                
//                // 메인 큐에서 세션 시작
                DispatchQueue.main.async {
                    self.startSession()
                }
            } catch {
                print("카메라 설정 오류: \(error)")
            }
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
        DispatchQueue.main.async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.main.async {
            self.session.stopRunning()
        }
    }
    
    func takePicture(delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: delegate)
    }
}
