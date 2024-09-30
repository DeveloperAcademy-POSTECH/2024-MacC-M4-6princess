//
//  CameraService.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation

class CameraService {
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping(Error?) -> ()){
        self.delegate = delegate // 권한을 확인하려고함
        checkPermission(completion: completion)
    }
    
    ///카메라 권한 함수
    private func checkPermission(completion: @escaping(Error?)->()){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
        case .notDetermined:
            // 권한을 요청함
            AVCaptureDevice.requestAccess(for: .video){ [weak self] granted in // 백그라운드 스레드 내부에 있기에 weak self 추가
                guard granted else { return }
                // 권한설정이 true면 아래의 코드 실행
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            // 승인된 상태일때 카메라 시작
            setupCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping(Error?)->()){
        // 전체 적용 세션에 담기 위한 작업들
        let session = AVCaptureSession()
        // 기기 기본값이 존재하면 실행
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                    /*
                     입력 구성
                     var inputs: [AVCaptureInput]
                     캡처 세션에 미디어 데이터를 제공하는 입력입니다.
                     func canAddInput(AVCaptureInput) -> Bool
                     세션에 입력을 추가할 수 있는지 여부를 결정합니다.
                     func addInput(AVCaptureInput)
                     세션에 캡처 입력을 추가합니다.
                     func removeInput(AVCaptureInput)
                     세션에서 입력을 제거합니다.
                     */
                }else {return}
                
                if session.canAddOutput(output){
                    session.addOutput(output)
                    /*
                     출력 구성
                     var outputs: [AVCaptureOutput]
                     캡처 세션이 데이터를 보내는 출력 대상입니다.
                     func canAddOutput(AVCaptureOutput) -> Bool
                     세션에 출력을 추가할 수 있는지 여부를 결정합니다.
                     func addOutput(AVCaptureOutput)
                     캡처 세션에 출력을 추가합니다.
                     func removeOutput(AVCaptureOutput)
                     캡처 세션에서 출력을 제거합니다.
                     */
                }
                
                
                // previewLayer 의 크기를 설정
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                // session을 실행시킨다.
                session.startRunning()
                // 전체 session에 담는다.
                self.session = session
                
            }catch{
                completion(error)
            }
        }
    }
    func capturePhoto(with settings : AVCapturePhotoSettings = AVCapturePhotoSettings()){
            // 기본 셋팅과 대리인을 전달한다
            output.capturePhoto(with: settings, delegate: delegate!)
        }
        // 카메라 버튼을 눌렀을때 실행되는 함수
}
