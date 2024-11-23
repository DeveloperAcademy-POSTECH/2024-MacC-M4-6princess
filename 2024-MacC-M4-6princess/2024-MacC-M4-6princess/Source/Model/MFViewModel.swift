//
//  MFViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/19/24.
//

import SwiftUI
import CoreData

class MFViewModel: ObservableObject {
    @Published var imageDataArray: [(id: UUID, data: Data, isLoaded: Bool)] = []
    @Published var isShowPhotosPicker: Bool = false
    @Published var isEditing: Bool = false
    @Published var selectedImageIds: Set<UUID> = []
    
    private var viewContext: NSManagedObjectContext
    private var imageCache: [UUID: Data] = [:]
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
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
            return downsampleImage(UIImage(data: imageData)!,
                                   to: CGSize(width: UIScreen.main.bounds.width / 3,
                                              height: (UIScreen.main.bounds.width / 3) * (4 / 3)))?.jpegData(compressionQuality: 0.5)
        } catch {
            print("Failed to fetch image: \(error)")
            return nil
        }
    }
    
    func deleteSelectedImages() {
        let request = StoreImages.fetchRequest()
        request.predicate = NSPredicate(format: "uuid IN %@", selectedImageIds)
        
        do {
            let imagesToDelete = try viewContext.fetch(request)
            for image in imagesToDelete {
                viewContext.delete(image)
            }
            try viewContext.save()
            loadImages()
            selectedImageIds.removeAll()
            isEditing = false
        } catch {
            print("Failed to delete images: \(error)")
        }
    }
    
    func downsampleImage(_ image: UIImage, to pointSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let data = image.jpegData(compressionQuality: 1.0),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
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
    
    func toggleSelection(for id: UUID) {
        DispatchQueue.main.async {
            if self.selectedImageIds.contains(id) {
                self.selectedImageIds.remove(id)
            } else {
                self.selectedImageIds.insert(id)
            }
        }
    }
    
}
