//
//  IOShareSheet.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/5/25.
//
import SwiftUI
import UIKit
import LinkPresentation

struct IOShareSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var shareData: (image: UIImage, title: String, content: String)
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            DispatchQueue.global(qos: .userInitiated).async {
                let fileURL = saveImageAsFile(image: shareData.image)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // 0.1초 지연 후 실행하여 UI 블로킹 방지
                    var items: [Any] = []
                    
                    if let fileURL = fileURL {
                        items.append(fileURL) // 이미지 파일 URL 추가
                    }
                    
                    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    activityVC.completionWithItemsHandler = { _, _, _, _ in
                        DispatchQueue.main.async {
                            self.isPresented = false
                        }
                        //                        if let fileURL = fileURL {
                        //                            deleteFile(at: fileURL)
                        //                        }
                    }
                    uiViewController.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    /// 이미지를 PNG 파일로 저장하고 URL을 반환하는 함수
    private func saveImageAsFile(image: UIImage) -> URL? {
        guard let data = image.pngData() else { return nil }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("shared_image.png")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image to file: \(error)")
            return nil
        }
    }
}

final class SharePinNumberActivityItemSource: NSObject, UIActivityItemSource {
    private var title: String
    private var content: String
    private var image: UIImage
    
    init(title: String, content: String, photo: UIImage) {
        self.title = title
        self.content = content
        self.image = photo
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image.pngData() ?? content
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = content
        metaData.iconProvider = NSItemProvider(object: image)
        metaData.originalURL = URL(string: "https://apps.apple.com/kr/app/frameet-%ED%94%84%EB%A0%88%EC%9E%84%EB%B0%8B-%EC%B5%9C%EC%95%A0%EC%99%80-%ED%95%A8%EA%BB%98-%ED%8A%B9%EB%B3%84%ED%95%9C-%EC%9D%BC%EC%83%81/id6737822930")
        return metaData
    }
}
