//
//  FrameManager.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/20/24.
//

import SwiftUI
import CoreData

public final class FrameManager: ObservableObject {
    // 뷰 간 데이터를 공유하기 위한 변수들
    @Published var pickedImage: UIImage? = nil // PhotosPickerView에서 선택된 이미지
    @Published var resultImage: UIImage? = nil // DFFrameEditView에서 편집된 결과 이미지
    @Published var showMFView = false //@@변수명이 뭘하는지 알수없음 showFrameSelect
    // 데이터를 가지고 있으면 의존성이 생김 따른 환경변수 생성 고려
    
    @Published var selectedFrame: UUID? = nil //CoreData에서 선택한 프레임 id 받아옴
    @Published var isFrameLoading: Bool = false
    
    func updateSelectedFrame(id: UUID, image: UIImage, context: NSManagedObjectContext) {
            self.selectedFrame = id
            self.pickedImage = image
            self.resultImage = loadSelectedFrameImage(context: context)
            self.isFrameLoading = false
        }
    
    func loadSelectedFrameImage(context: NSManagedObjectContext) -> UIImage? {
            guard let selectedFrameId = selectedFrame else { return nil }
            
            let request = StoreImages.fetchRequest()
            request.predicate = NSPredicate(format: "uuid == %@", selectedFrameId as CVarArg)
            
            do {
                guard let storeImage = try context.fetch(request).first,
                      let originalImageData = storeImage.image,
                      let originalImage = UIImage(data: originalImageData) else {
                    return nil
                }
                
                // 이미지 로드 완료 후 resultImage 설정
                self.resultImage = originalImage
                self.isFrameLoading = false
                return originalImage
            } catch {
                print("프레임 이미지 로드 실패: \(error)")
                self.isFrameLoading = false
                return nil
            }
        }
}
