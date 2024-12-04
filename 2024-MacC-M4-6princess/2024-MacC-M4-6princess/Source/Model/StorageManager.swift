//
//  StorageManager.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/4/24.
//

import Firebase
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference() // Firebase Storage 기본 참조
    
    private init() {}
    
    /// 이미지를 Firebase Storage에 업로드합니다.
    /// - Parameters:
    ///   - image: 업로드할 UIImage
    ///   - completion: 업로드 완료 핸들러 (URL 또는 에러)
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
           guard let imageData = image.jpegData(compressionQuality: 0.8) else {
               completion(.failure(NSError(domain: "StorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터 변환 실패"])))
               return
           }
        let deviceName = UIDevice.current.name.replacingOccurrences(of: " ", with: "") // 공백을 "_"로 대체
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmssSSS" // 년월일시분초밀리초
            let timestamp = dateFormatter.string(from: Date())
           
//           let path = "showcase2024/\(UUID().uuidString).jpeg"
        let path = "showcase2024/\(timestamp)_\(deviceName).jpeg"
           let storageRef = storage.child(path)
           
           storageRef.putData(imageData, metadata: nil) { _, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               storageRef.downloadURL { url, error in
                   if let error = error {
                       completion(.failure(error))
                   } else if let url = url {
                       completion(.success(url))
                   }
               }
           }
       }
 


    /// 이미지를 Firebase Storage에서 삭제
        /// - Parameters:
        ///   - path: 삭제할 이미지의 경로
        ///   - completion: 삭제 완료 핸들러
        func deleteImage(path: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let reference = storage.child(path)
            reference.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
}

import CoreImage.CIFilterBuiltins
import UIKit

final class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private init() {}
    
    /// 문자열을 기반으로 QR 코드를 생성합니다.
    /// - Parameter string: QR 코드에 포함될 문자열
    /// - Returns: QR 코드 이미지
    func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}
