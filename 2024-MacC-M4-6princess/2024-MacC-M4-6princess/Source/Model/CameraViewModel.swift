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
    var isTakenPhoto = false
    var isAllTakenPhoto = false
    
    var session = AVCaptureSession()
    
    var videoDeviceInput: AVCaptureDeviceInput?
    
    var isAlert = false
    
    var output = AVCapturePhotoOutput()
    
    //프리뷰에 쓰임
    var preview: AVCaptureVideoPreviewLayer!
    
    //이미지 데이터
    var isSavedPhotoData = false
    var picData = Data(count: 0)
    //    @Published var picData: [Data] = []
    //    @Published var imageViews: [UIImage] = [] // UIImageView 배열
    
    //찍힌 사진 넣는 변수
    var takenImg: UIImage?
    
    var nextView = false
    var frameSize = CGRect(origin: .zero, size: .zero)
    
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
                    self.isTakenPhoto.toggle()
                    
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
                    self.isTakenPhoto = false
                }
                //변수 초기화
                self.isSavedPhotoData = false
                self.picData = Data(count: 0) //picData 초기화
                //                self.imageViews = []
                //                self.picData = [] // picData 초기화
            }
        }
    }
    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("사진 처리 중 에러 발생: \(error.localizedDescription)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("사진 데이터가 유효하지 않음")
//            return
//        }
//
//        guard var image = UIImage(data: imageData) else {
//            print("이미지를 생성할 수 없습니다.")
//            return
//        }
//
//        // 전면 카메라일 경우 좌우반전 처리
//        if self.videoDeviceInput?.device.position == .front {
//            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
//        }
//
//        // 메인 스레드에서 picData 업데이트
//        DispatchQueue.main.async {
//            self.picData = image.jpegData(compressionQuality: 1.0) ?? Data()
//            self.takenImg = image
//            self.nextView = true
//            print("nextView:\(self.nextView)")
//            print("이미지 사이즈: \(image.size)")
//            print("사진이 성공적으로 처리되었습니다")
//        }
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
        if self.videoDeviceInput?.device.position == .front {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        }

        // 이미지 크기를 frameSize로 조정
        let renderer = UIGraphicsImageRenderer(size: frameSize.size)
        image = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: frameSize.size))
        }

        // 이미지의 방향을 .up으로 수정
        image = fixOrientation(image)

        // 메인 스레드에서 picData 업데이트
        DispatchQueue.main.async {
            print("[Camera]: Silent sound activated")
            AudioServicesDisposeSystemSoundID(1108)
            self.picData = image.jpegData(compressionQuality: 1.0) ?? Data()
            self.takenImg = image
            self.nextView = true
            print("nextView:\(self.nextView)")
            print("이미지 사이즈: \(image.size)")
            print("사진이 성공적으로 처리되었습니다")
        }

    }

//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("사진 처리 중 에러 발생: \(error.localizedDescription)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("사진 데이터가 유효하지 않음")
//            return
//        }
//
//        guard var image = UIImage(data: imageData) else {
//            print("이미지를 생성할 수 없습니다.")
//            return
//        }
//
//        // 전면 카메라일 경우 좌우 반전 처리
//        if self.videoDeviceInput?.device.position == .front {
//            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
//        }
//
//        // 이미지의 방향을 .up으로 수정
//        image = fixOrientation(image)
//
//        // 메인 스레드에서 picData 업데이트
//        DispatchQueue.main.async {
//            self.picData = image.jpegData(compressionQuality: 1.0) ?? Data()
//            self.takenImg = image
//            self.nextView = true
//            print("nextView:\(self.nextView)")
//            print("이미지 사이즈: \(image.size)")
//            print("사진이 성공적으로 처리되었습니다")
//        }
//    }
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
            self.isSavedPhotoData = true
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

