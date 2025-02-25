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
