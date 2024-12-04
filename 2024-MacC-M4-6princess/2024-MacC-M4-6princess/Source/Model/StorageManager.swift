//
//  StorageManager.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/4/24.
//
import Firebase
import FirebaseStorage
import UIKit
import FirebaseCore
final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference() // Firebase Storage 기본 참조
    
    private init() {}
    
    /// 이미지를 Firebase Storage에 업로드합니다.
    /// - Parameters:
    ///   - image: 업로드할 UIImage
    ///   - metadata: 업로드할 이미지의 메타데이터 (기본값: nil)
    /// - Returns: 업로드된 이미지의 경로와 이름을 반환
    func uploadImage(image: UIImage, metadata: StorageMetadata? = nil) async throws -> (path: String, name: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터 변환 실패"])
        }
        
        let meta = metadata ?? {
            let defaultMeta = StorageMetadata()
            defaultMeta.contentType = "image/jpeg"
            return defaultMeta
        }()
        
        let path = "images/\(UUID().uuidString).jpeg"
        
        let returnedMetadata = try await storage.child(path).putDataAsync(imageData, metadata: meta)
        
        guard let returnedPath = returnedMetadata.path, let returnedName = returnedMetadata.name else {
            throw URLError(.badServerResponse)
        }
        
        return (path: returnedPath, name: returnedName)
    }
}

//import Foundation
//import FirebaseStorage
//
//final class StorageManager{
//    static let shared = StorageManager()
//    private let storage = Storage.storage().reference()
//    private init() {}
//    func saveImages(data: Data) async throws -> (path: String, name: String) {
//        let meta = StorageMetadata()
//        meta.contentType = "image/jpeg"
//        
//        let path = "\(UUID().uuidString).jpeg"
//        let returnedMetaData = try await storage.child(path).putDataAsync(data,metadata:meta)
//        
//        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
//            throw URLError(.badServerResponse)
//        }
//        return (returnedPath,returnedName)
//    }
//    
//    
//}

