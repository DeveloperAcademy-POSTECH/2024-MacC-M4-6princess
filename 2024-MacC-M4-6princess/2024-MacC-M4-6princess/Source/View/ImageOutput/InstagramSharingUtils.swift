//
//  InstagramSharingUtils.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 2/12/25.
//


import Foundation
import SwiftUI

struct InstagramSharingUtils {
    
    // 인스타 스토리를 열 수 있으면 해당 URL 반환하고, 아님 nil 반환
    private static var instagramStoriesUrl: URL? {
        if let bundleID = Bundle.main.bundleIdentifier,
           let url = URL(string: "instagram-stories://share?source_application=\(bundleID)") {
            if UIApplication.shared.canOpenURL(url) {
                return url
            }
        }
        return nil
    }
    
    
    // Convenience wrapper to return a boolean for `instagramStoriesUrl`
    static var canOpenInstagramStories: Bool {
        return instagramStoriesUrl != nil
    }
    // 인스타 스토리를 이용가능하면 이미지를 제공한 뒤 인스타그램을 연다.
    static func shareToInstagramStories(_ image: UIImage) {
        
        // 인스타그램 스토리를 이용가능한지 확인
        guard let instagramStoriesUrl = instagramStoriesUrl else {
            return
        }
        
        // 이미지를 붙여쓰기 할 수 있는 png or jpeg로 변환해야함
        let imageDataOrNil = UIImage.pngData(image)
        guard let imageData = imageDataOrNil() else {
            print("🙈 Image data not available.")
            return
        }
        let pasteboardItem = ["com.instagram.sharedSticker.backgroundImage": imageData]
        let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
        
        // Add the image to the pasteboard. Instagram will read the image from the pasteboard when it's opened.
        UIPasteboard.general.setItems([pasteboardItem], options: pasteboardOptions)
        
        // Open Instagram.
        UIApplication.shared.open(instagramStoriesUrl, options: [:], completionHandler: nil)
    }
}
// X 공유를 위한 유틸리티
struct XSharingUtils {
    // X 앱을 열 수 있는지 확인
    static var canOpenX: Bool {
        guard let url = URL(string: "twitter://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // 기본 텍스트 공유
    static func shareToX(text: String, completion: ((Bool) -> Void)? = nil) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "twitter://post?message=\(encodedText)"
        
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url) { success in
            completion?(success)
        }
    }
    
    // 이미지와 텍스트 함께 공유 (웹 링크를 통해)
    static func shareToXWithImage(text: String, image: UIImage) {
        // 이미지를 PNG로 저장
        guard let imageData = image.pngData(),
              let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // X 웹 공유 URL 사용 (앱이 설치되어 있으면 앱으로 리다이렉션 됨)
        let webUrlString = "https://x.com/intent/tweet?text=\(encodedText)"
        guard let webUrl = URL(string: webUrlString) else { return }
        
        UIApplication.shared.open(webUrl)
    }
}
