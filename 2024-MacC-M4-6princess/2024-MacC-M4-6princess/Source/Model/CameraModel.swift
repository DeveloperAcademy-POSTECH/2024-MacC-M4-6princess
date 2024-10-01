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
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    @Published var output = AVCapturePhotoOutput()
    
    //프리뷰에 쓰임
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    //이미지 데이터
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    ///비디오 권한 체크
    func Check() {
        
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
            self.alert.toggle()
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
            
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            //입력값, 출력값 체크하고 세션에 추가
            if self.session.canAddInput(input) {
                self.session.addInput(input)
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
            
            let settings = AVCapturePhotoSettings()
            self.output.capturePhoto(with: settings, delegate: self)

            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                }
            }
        }
    }
    ///사진 재촬영 함수
    func reTake() {
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                }
                //변수 초기화
                self.isSaved = false
                self.picData = Data(count: 0) // picData 초기화
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
        
        // 메인 스레드에서 picData 업데이트
        DispatchQueue.main.async {
            self.picData = imageData
            print("사진이 성공적으로 처리되었습니다")
            self.isTaken = true  // 여기서 사진이 찍혔음을 UI에 반영
            
            // 사진 저장 로직 실행
//            self.savePic()
        }
    }
    
    //    func requestAlbumAccess() {
    //        Task {
    //            switch await PHPhotoLibrary.requestAuthorization(for: .readWrite) {
    //            case .authorized:
    //                //세션 세팅
    //                savePic()
    //            case .notDetermined:
    //                //권한 재요청
    //                PHPhotoLibrary.requestAuthorization(for: .readWrite) {
    //                    (status) in
    //                    if status.rawValue == 0 {
    //                        savePic()
    //                    }
    //                }
    //            case .denied:
    //                print("앨범에 저장할 수 없음. 권한 deny됨")
    //                return
    //            default:
    //                return
    //            }
    //    }
    ///사진 저장 함수
    //UIImage로 바로 넘겨주는 방법 고안해야 함
    func savePic() {
        guard let image = UIImage(data: self.picData)
        else {
            print("이미지를 저장할 수 없습니다. picData가 유효하지 않습니다.")
            return
        }
        
        //이건 그냥 갤러리에 잘 저장되는지 확인용
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        DispatchQueue.main.async {
            self.isSaved = true
            print("성공적으로 사진이 저장되었습니다.")
        }
    }
    
    
}




