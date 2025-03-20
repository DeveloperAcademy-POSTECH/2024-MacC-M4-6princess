//
//  HomeViewmodel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/1/25.
//

import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    @Published var imageDataArray: [(id: UUID, data: Data, isLoaded: Bool)] = []
    private var viewContext: NSManagedObjectContext
    private var imageCache: [UUID: Data] = [:]

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Core Data에서 이미지 ID를 가져옴
    func loadImages() {
        let request = StoreImages.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)]
        
        do {
            let storedImages = try viewContext.fetch(request)
            imageDataArray = storedImages.compactMap { storeImage in
                guard let id = storeImage.uuid else { return nil }
                return (id: id, data: Data(), isLoaded: false)
            }
        } catch {
            print("이미지 로드 실패: \(error)")
        }
    }

    /// 특정 이미지가 필요할 때 로드 (해당 ID가 없을 때만 로드)
    func loadImageIfNeeded(for id: UUID) -> Data? {
        if let cached = imageCache[id] {
            return cached
        }
        
        if let imageData = loadImageData(for: id) {
            imageCache[id] = imageData
            return imageData
        }
        return nil
    }
    func loadImageData(for id: UUID) -> Data? {
        let request = StoreImages.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            guard let storeImage = try viewContext.fetch(request).first,
                  let imageData = storeImage.image else {
                return nil
            }

            let image = UIImage(data: imageData)!
            let targetSize = CGSize(width: UIScreen.main.bounds.width / 3,
                                    height: (UIScreen.main.bounds.width / 3) * (4 / 3))

            if let downsampledImage = downsampleImage(image, to: targetSize) {
                return convertToJPEGWithWhiteBackground(image: downsampledImage)  // ✅ 흰색 배경으로 변환 후 JPEG 변환
            }
            return nil
        } catch {
            print("이미지 로딩 실패: \(error)")
            return nil
        }
    }

    /// 이미지를 다운샘플링하여 메모리 사용량 줄이기
    func downsampleImage(_ image: UIImage, to pointSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageData = image.pngData(),  // ✅ PNG로 변환하여 투명도 유지
              let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
    func convertToJPEGWithWhiteBackground(image: UIImage) -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true  // ✅ 투명 배경을 없애고 불투명한 배경을 설정

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let newImage = renderer.image { context in
            UIColor.white.setFill()  // ✅ 흰색 배경 설정 (검정색이 아니라 흰색으로 변경)
            context.fill(CGRect(origin: .zero, size: image.size))
            image.draw(at: .zero)
        }

        return newImage.jpegData(compressionQuality: 0.5)
    }

}

