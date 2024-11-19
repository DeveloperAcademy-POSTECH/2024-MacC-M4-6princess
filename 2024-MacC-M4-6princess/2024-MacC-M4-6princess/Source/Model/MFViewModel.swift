//
//  MFViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 11/19/24.
//

import SwiftUI

class MFViewModel: ObservableObject {
    @Published var imageDataArray: [(id: UUID, data: Data)] = []
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)],
        animation: .default
    ) var storedImages: FetchedResults<StoreImages>
    @Published var isShowPhotosPicker: Bool = false
    @Published var isEditing: Bool = false
    @Published var selectedImageIds: Set<UUID> = []
    
    func loadImages() {
        imageDataArray = storedImages.compactMap { storeImage -> (id: UUID, data: Data)? in
            guard let imageData = storeImage.image,
                  let id = storeImage.uuid,
                  let uiImage = UIImage(data: imageData),
                  let downsampledImage = downsampleImage(uiImage, to: CGSize(width: UIScreen.main.bounds.width / 3, height: (UIScreen.main.bounds.width / 3) * (598 / 375))) else {
                return nil
            }
            return (id: id, data: downsampledImage.jpegData(compressionQuality: 0.5) ?? imageData)
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
        if selectedImageIds.contains(id) {
            selectedImageIds.remove(id)
        } else {
            selectedImageIds.insert(id)
        }
    }
    
    func deleteSelectedImages() {
        viewContext.performAndWait {
            for id in selectedImageIds {
                if let imageToDelete = storedImages.first(where: { $0.uuid == id }) {
                    viewContext.delete(imageToDelete)
                }
            }
            try? viewContext.save()
        }
        loadImages()
        selectedImageIds.removeAll()
        isEditing = false
    }
}
