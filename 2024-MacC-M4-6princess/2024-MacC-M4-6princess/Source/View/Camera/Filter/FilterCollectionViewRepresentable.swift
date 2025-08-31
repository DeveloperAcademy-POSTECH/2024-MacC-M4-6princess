//
//  FilterCollectionViewRepresentable.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import SwiftUI
import CoreData

struct FilterCollectionViewRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var frameManager: FrameManager
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: StoreImages.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.createdDate, ascending: true)])
    var filterImages: FetchedResults<StoreImages>
    let viewModel: CameraViewModel
    
        func makeUIViewController(context: Context) -> FilterCollectionViewController {
        // UUID가 nil이 아닌 프레임만 필터링
        let validImages = filterImages.filter { $0.uuid != nil }
        let reversedImages = Array(validImages.reversed())
//        print("📱 makeUIViewController - 총 프레임 수: \(reversedImages.count)")
//        for (index, image) in reversedImages.enumerated() {
//            print("📱 프레임 \(index): \(image.uuid?.uuidString ?? "nil") - 생성일: \(image.createdDate?.description ?? "nil")")
//        }
        
        // frameManager에 선택된 프레임이 있지만 resultImage가 없으면 로드
        if frameManager.selectedFrame != nil && frameManager.resultImage == nil {
            loadSelectedFrameFromCoreData()
        }
        
        return FilterCollectionViewController(
            filterImages: reversedImages,
            selectedFilter: { [viewContext] uuid in
                // 선택된 필터의 이미지 데이터를 가져와서 설정
                if let uuid = uuid {
                    let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let results = try viewContext.fetch(fetchRequest)
                        if let storedImage = results.first,
                           let imageData = storedImage.image,
                           let uiImage = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                frameManager.selectedFrame = uuid
                                frameManager.resultImage = uiImage
                            }
                        }
                    } catch {
                        print("❌ 프레임 로딩 에러: \(error)")
                    }
                } else {
                    DispatchQueue.main.async {
                        frameManager.selectedFrame = nil
                        frameManager.resultImage = nil
                    }
                }
            },
            initialFilter: frameManager.selectedFrame,
            viewModel: viewModel,
            frameManager: frameManager
        )
    }
    
    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
        // 데이터가 있는지 확인
        guard !uiViewController.filterImages.isEmpty && !filterImages.isEmpty else {
            return // 데이터가 없으면 아무것도 하지 않음
        }
        
        // createdDate가 nil이 아닌 필터만 추출하여 정렬(프레임이 아무것도 없을 때)
        let currentFiltersWithDates = uiViewController.filterImages.filter { $0.createdDate != nil }
        let newFiltersWithDates = Array(filterImages.reversed()).filter { $0.createdDate != nil }
        
        // 날짜가 있는 필터가 하나도 없으면 비교하지 않음(프레임이 아무것도 없을 때)
        guard !currentFiltersWithDates.isEmpty && !newFiltersWithDates.isEmpty else {
            return
        }
        
        // 날짜로 정렬
        let sortedCurrentFilters = currentFiltersWithDates.sorted {
            guard let date1 = $0.createdDate, let date2 = $1.createdDate else { return false }
            return date1 > date2
        }
        
        let sortedNewFilters = newFiltersWithDates.sorted {
            guard let date1 = $0.createdDate, let date2 = $1.createdDate else { return false }
            return date1 > date2
        }
        
        // 날짜만 추출하여 비교
        let currentDates = sortedCurrentFilters.compactMap { $0.createdDate }
        let newDates = sortedNewFilters.compactMap { $0.createdDate }
        
        // 날짜 배열이 다르면 업데이트
        if currentDates != newDates {
            uiViewController.filterImages = Array(filterImages.reversed())
            uiViewController.collectionView.reloadData()
        }

        // 선택된 필터 변경됐을 때만 업데이트
        if uiViewController.currentSelectedFilter != frameManager.selectedFrame {
            uiViewController.currentSelectedFilter = frameManager.selectedFrame
            uiViewController.scrollToSelectedFilter(animated: false)
        }
    }
    
    // CoreData에서 프레임 로딩 함수
    private func loadSelectedFrameFromCoreData() {
        guard let frameId = frameManager.selectedFrame else {
            frameManager.resultImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let storedImage = results.first, let imageData = storedImage.image {
                frameManager.resultImage = UIImage(data: imageData)
//                print("✅ 프레임 로딩 성공: \(frameId)")
            } else {
                frameManager.resultImage = nil
                print("❌ 프레임 데이터 없음: \(frameId)")
            }
        } catch {
            print("❌ 프레임 로딩 에러: \(error)")
            frameManager.resultImage = nil
        }
    }
}
