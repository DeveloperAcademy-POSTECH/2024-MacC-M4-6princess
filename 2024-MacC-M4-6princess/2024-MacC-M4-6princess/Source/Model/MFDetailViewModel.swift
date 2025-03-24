//
//  MFDetailViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/23/25.
//


//
//  MFDetailViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/15/25.
//
import SwiftUI
import CoreData

class MFDetailViewModel: ObservableObject {
    @Published var selectedImageId: UUID?
    @Published var isDeleteAlertDetail = false
    @Published var imageDataArray: [(id: UUID, data: Data)] = []
    private var viewContext: NSManagedObjectContext?

    init() {
    }

    func configure(context: NSManagedObjectContext, selectedId: UUID?) {
        self.viewContext = context
        self.selectedImageId = selectedId
        loadImages() // Core Data에서 이미지 로드
    }
    
    /// Core Data에서 이미지 데이터를 로드하여 imageDataArray를 채움
        func loadImages() {
            guard let context = viewContext else { return }
            let request = StoreImages.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)]

            do {
                let storedImages = try context.fetch(request)
                imageDataArray = storedImages.compactMap { storeImage in
                    guard let id = storeImage.uuid, let imageData = storeImage.image else { return nil }
                    return (id: id, data: imageData)
                }
            } catch {
                print("이미지 로드 실패:", error)
            }
        }

    func loadOriginalImageData() -> Data? {
        guard let context = viewContext, let id = selectedImageId else { return nil }

        let request = StoreImages.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            return try context.fetch(request).first?.image
        } catch {
            print("이미지 로딩 실패:", error)
            return nil
        }
    }

    func deleteSelectedImage(completion: @escaping () -> Void) {
        guard let context = viewContext, let id = selectedImageId else { return }

        let request = StoreImages.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", id as CVarArg)

        do {
            if let imageToDelete = try context.fetch(request).first {
                context.delete(imageToDelete)
                try context.save()
                loadImages()
                completion()
            }
        } catch {
            print("삭제 실패:", error)
        }
    }
    /// 선택된 이미지의 인덱스를 반환
        func indexOfSelectedImage() -> Int? {
            guard let selectedId = selectedImageId else { return nil }
            return imageDataArray.firstIndex(where: { $0.id == selectedId }).map { $0 + 1 }
        }

        /// 전체 이미지 개수를 반환
        func totalImageCount() -> Int {
            return imageDataArray.count
        }
}
