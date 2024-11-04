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

    func checkVideoAuthorizaion() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                setUp()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        self?.setUp()
                    }
                }
            case .denied:
                return
            case .restricted:
                return
            @unknown default:
                return
            }
        }
    
    func setUp() {
        do {
            //config 세팅
            self.session.beginConfiguration()
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            //입력값, 출력값 체크하고 세션에 추가
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoDeviceInput = input
            }
            
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func changeCamera() {
        guard let currentInput = self.session.inputs.first as? AVCaptureDeviceInput else {
            print("현재 입력을 찾을 수 없습니다.")
            return
        }
        
        let currentPosition = currentInput.device.position
        let preferredPosition: AVCaptureDevice.Position
        
        switch currentPosition {
        case .unspecified, .front:
            print("후면 카메라로 전환합니다.")
            preferredPosition = .back
            
        case .back:
            print("전면 카메라로 전환합니다.")
            preferredPosition = .front
            
        @unknown default:
            print("알 수 없는 포지션. 후면 카메라로 전환합니다.")
            preferredPosition = .back
        }
        
        // 새로운 카메라 장치 가져오기
        guard let newVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferredPosition) else {
            print("카메라 장치를 찾을 수 없습니다.")
            return
        }
        
        do {
            let newVideoDeviceInput = try AVCaptureDeviceInput(device: newVideoDevice)
            self.session.beginConfiguration()
            
            // 기존 입력 제거
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            
            // 새로운 입력 추가
            if self.session.canAddInput(newVideoDeviceInput) {
                self.session.addInput(newVideoDeviceInput)
                self.videoDeviceInput = newVideoDeviceInput // 새로운 입력 저장
            } else {
                print("새로운 입력을 추가할 수 없습니다.")
                self.session.addInput(currentInput) // 기존 입력 복원
            }
            
            // 새로운 카메라의 활성 포맷 확인
            let activeFormat = newVideoDevice.activeFormat
            let maxDimensions = activeFormat.highResolutionStillImageDimensions
            
            // 비디오 안정화 설정
            if let connection = self.output.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            
            // 출력 설정
            output.maxPhotoDimensions = maxDimensions
            output.maxPhotoQualityPrioritization = .quality
            
            self.session.commitConfiguration()
        } catch {
            print("카메라 전환 중 오류 발생: \(error)")
        }
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
