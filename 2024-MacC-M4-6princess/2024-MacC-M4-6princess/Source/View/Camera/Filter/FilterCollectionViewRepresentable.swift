//
//  FilterCollectionViewRepresentable.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import SwiftUI

struct FilterCollectionViewRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var frameManager: FrameManager
    @FetchRequest(entity: StoreImages.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.createdDate, ascending: true)])
    var filterImages: FetchedResults<StoreImages>
    let viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> FilterCollectionViewController {
        return FilterCollectionViewController(
            filterImages: filterImages.reversed(),
            selectedFilter: { uuid in
                frameManager.selectedFrame = uuid
                print("🔥 selectedFilter 클로저 호출됨! uuid: \(uuid?.uuidString ?? "nil")")
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
        let newFiltersWithDates = filterImages.reversed().filter { $0.createdDate != nil }
        
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
            uiViewController.filterImages = filterImages.reversed()
            uiViewController.collectionView.reloadData()
        }

        // 선택된 필터 변경됐을 때만 업데이트
        if uiViewController.currentSelectedFilter != frameManager.selectedFrame {
            uiViewController.currentSelectedFilter = frameManager.selectedFrame
            uiViewController.scrollToSelectedFilter(animated: false)
        }
    }



}
