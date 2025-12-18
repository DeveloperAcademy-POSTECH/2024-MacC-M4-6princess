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
    
    private let backDevicePriority: [AVCaptureDevice.DeviceType] = [
        .builtInTripleCamera,
        .builtInDualWideCamera,
        .builtInDualCamera,
        .builtInTelephotoCamera,
        .builtInWideAngleCamera,
        .builtInUltraWideCamera
    ]
    
    private let frontDevicePriority: [AVCaptureDevice.DeviceType] = [
        .builtInTrueDepthCamera,
        .builtInWideAngleCamera
    ]
    
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
            self.session.sessionPreset = preset
            
            guard let device = defaultDevice(for: .back) else {
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
                        let preferredZoom = preferredDefaultZoom(for: device)
                        device.videoZoomFactor = preferredZoom
                        device.unlockForConfiguration()
                    } catch {
                        print("초기 줌 설정 오류: \(error)")
                    }
                }
                
                if self.session.canAddOutput(self.output) {
                    self.output.isHighResolutionCaptureEnabled = true
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

    private func defaultDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceTypes = position == .back ? backDevicePriority : frontDevicePriority
        for type in deviceTypes {
            if let device = AVCaptureDevice.default(type, for: .video, position: position) {
                return device
            }
        }
        return nil
    }
    
    
    //기기의 카메라 렌즈 사양에 따라 카메라(비디오렌즈)를 선택
    func getBestCamera(from devices: [AVCaptureDevice]) -> AVCaptureDevice? {
        // 우선순위에 따라 카메라 선택
        if let dualWideCamera = devices.first(where: { $0.deviceType == .builtInDualWideCamera }) {
            return dualWideCamera
        }
        if let tripleCamera = devices.first(where: { $0.deviceType == .builtInTripleCamera }) {
            return tripleCamera
        }
        if let dualCamera = devices.first(where: { $0.deviceType == .builtInDualCamera }) {
            return dualCamera
        }
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
        
        guard let newDevice = defaultDevice(for: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else {
            if session.canAddInput(currentInput) {
                session.addInput(currentInput)
            }
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            self.videoDeviceInput = newInput
            self.deviceType = newDevice.deviceType
            
            do {
                try newDevice.lockForConfiguration()
                let preferredZoom = preferredDefaultZoom(for: newDevice)
                newDevice.videoZoomFactor = preferredZoom
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
    @discardableResult
    func applyZoomFactor(_ factor: CGFloat) -> CGFloat? {
        guard let device = self.videoDeviceInput?.device else { return nil }
        
        do {
            try device.lockForConfiguration()
            
            let minZoom = device.minAvailableVideoZoomFactor
            let maxZoom = min(device.maxAvailableVideoZoomFactor, 10.0)
            var finalZoom = min(max(factor, minZoom), maxZoom)
            
            let zoomFactors = device.virtualDeviceSwitchOverVideoZoomFactors as? [NSNumber] ?? []
            if !zoomFactors.isEmpty {
                for factor in zoomFactors {
                    let zoomFactor = CGFloat(truncating: factor)
                    if abs(finalZoom - zoomFactor) < 0.1 {
                        finalZoom = zoomFactor
                        break
                    }
                }
            }
            
            let rate: Double = finalZoom <= 2.0 ? 40.0 : 100.0
            device.ramp(toVideoZoomFactor: finalZoom, withRate: Float(rate))
            
            device.unlockForConfiguration()
            return finalZoom
        } catch {
            print("줌 설정 오류: \(error.localizedDescription)")
            return nil
        }
    }
    
    var minAvailableZoomFactor: CGFloat {
        videoDeviceInput?.device.minAvailableVideoZoomFactor ?? 1.0
    }
    
    var maxAvailableZoomFactor: CGFloat {
        videoDeviceInput?.device.maxAvailableVideoZoomFactor ?? 3.0
    }
    
    private var activeLensTypes: [AVCaptureDevice.DeviceType] {
        guard let device = videoDeviceInput?.device else { return [] }
        let constituents = device.constituentDevices
        if constituents.isEmpty {
            return [device.deviceType]
        }
        return constituents.map { $0.deviceType }
    }
    
    var hasUltraWideLens: Bool {
        guard let device = videoDeviceInput?.device else { return false }
        return deviceHasUltraWide(device)
    }
    
    var hasTelephotoLens: Bool {
        if activeLensTypes.contains(.builtInTelephotoCamera) {
            return true
        }
        guard let deviceType = videoDeviceInput?.device.deviceType else { return false }
        switch deviceType {
        case .builtInTripleCamera, .builtInDualCamera, .builtInTelephotoCamera:
            return true
        default:
            return false
        }
    }
    
    var ultraWideZoomFactor: CGFloat {
        hasUltraWideLens ? 0.5 : minAvailableZoomFactor
    }
    
    var telephotoZoomFactor: CGFloat {
        if hasTelephotoLens {
            return min(2.0, maxAvailableZoomFactor)
        }
        return min(2.0, maxAvailableZoomFactor)
    }
    
    private func deviceHasUltraWide(_ device: AVCaptureDevice) -> Bool {
        let constituents = device.constituentDevices
        if !constituents.isEmpty {
            return constituents.contains { $0.deviceType == .builtInUltraWideCamera }
        }
        
        switch device.deviceType {
        case .builtInTripleCamera, .builtInDualWideCamera, .builtInUltraWideCamera:
            return true
        default:
            return false
        }
    }
    
    private func preferredDefaultZoom(for device: AVCaptureDevice) -> CGFloat {
        let minZoom = device.minAvailableVideoZoomFactor
        let maxZoom = min(device.maxAvailableVideoZoomFactor, 10.0)
        
        guard deviceHasUltraWide(device) else {
            return min(maxZoom, max(1.0, minZoom))
        }
        
        let desired = max(1.0, minZoom * 2.0)
        return min(maxZoom, desired)
    }
}
