//
//  CameraModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/1/24.
//

import SwiftUI
import AVFoundation
import Photos

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var isAllTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isAlert = false
    
    @Published var output = AVCapturePhotoOutput()
    
    //프리뷰에 쓰임
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    //이미지 데이터
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    //    @Published var picData: [Data] = []
    //    @Published var imageViews: [UIImage] = [] // UIImageView 배열
    
    @Published var takenImg: UIImage?
    
    @Published var nextView = false
//    
    
    ///비디오 권한 체크
    func checkVideoAuthorizaion() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                //세션 세팅
                setUp()
            case .notDetermined:
                //권한 재요청
                AVCaptureDevice.requestAccess(for: .video) {
                    (status) in
                    if status {
                        self.setUp()
                    }
                }
            case .denied:
                self.isAlert.toggle()
                return
            default:
                return
        }
    }
    
    ///카메라 세팅
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
    
    ///사진 찍는 함수
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                    
                    print("isTaken 값 토글됨")
                }
            }
            
        }
    }
    
    ///이후 찍는 횟수 기능에 쓰이는 사진 촬영 함수
    func takeManyPic() {
        DispatchQueue.global(qos: .background).async {
            
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            
        }
    }
    
    ///사진 재촬영 함수
    func reTake() {
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken = false
                }
                //변수 초기화
                self.isSaved = false
                self.picData = Data(count: 0) //picData 초기화
                //                self.imageViews = []
                //                self.picData = [] // picData 초기화
            }
        }
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
        //여기 imageData를 그냥 변수가 아니라 배열로 바꿔서 저장해야 여러 사진을 저장할 수 있을듯
        
        // 메인 스레드에서 picData 업데이트
        DispatchQueue.main.async {
            self.picData = imageData
            //            self.imageViews.append(UIImage(data: self.picData)!)
            self.takenImg = self.dataToUIImage()
            
//            self.session.stopRunning()
            self.nextView = true
            print("nextView:\(self.nextView)")
            print("사진이 성공적으로 처리되었습니다")
            
            
            
        }
    }
    
    ///picData를 UIImage로 바꿔주는 함수
    func dataToUIImage() -> UIImage? {
        guard let image = UIImage(data: self.picData) else{
            print("이미지를 저장할 수 없습니다. picData가 유효하지 않습니다.")
            return nil
        }
        print("이미지가 UIImage로 변환되었습니다.")
        
        return image
    }
    
    ///사진 저장 함수
    func savePic() {
        guard let image = UIImage(data: self.picData) else{
            print("이미지를 저장할 수 없습니다. picData가 유효하지 않습니다.")
            return
        }
        
        //갤러리에 잘 저장되는지 확인용
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        DispatchQueue.main.async {
            self.isSaved = true
            print("성공적으로 사진이 저장되었습니다.")
        }
    }
    
    ///전후면 카메라 전환 함수
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
    
}
