//
//  FilterCollectionViewRepresentable.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import SwiftUI
//SwiftUI와 UIKit의 연결점...?

struct FilterCollectionViewRepresentable: UIViewControllerRepresentable {
    @EnvironmentObject var frameManager: FrameManager
    let filterImages: [StoreImages]
    let viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> FilterCollectionViewController {
        return FilterCollectionViewController(
            filterImages: filterImages,
            selectedFilter: { uuid in
                frameManager.selectedFrame = uuid
            },
            initialFilter: frameManager.selectedFrame,
            viewModel: viewModel,
            frameManager: frameManager
        )
    }
    
    //    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
    //        uiViewController.collectionView.reloadData()
    //
    //        // 선택된 필터를 스크롤로 중앙에 위치시키기
    //        if let selectedFilter = frameManager.selectedFrame,
    //           let index = uiViewController.filterImages.firstIndex(where: { $0.uuid == selectedFilter }) {
    //            uiViewController.collectionView.scrollToItem(
    //                at: IndexPath(item: index + 1, section: 0),
    //                at: .centeredHorizontally,
    //                animated: true
    //            )
    //        }
    //    }
    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
        // 데이터 변경 시 업데이트 (배열 내용 비교)
        let currentFilters = uiViewController.filterImages.map { $0.uuid }
        let newFilters = filterImages.map { $0.uuid }
        
        if currentFilters != newFilters {
            uiViewController.filterImages = filterImages
            uiViewController.collectionView.reloadData()
        }

        // 선택된 필터 변경됐을 때만 업데이트
        if uiViewController.currentSelectedFilter != frameManager.selectedFrame {
            uiViewController.currentSelectedFilter = frameManager.selectedFrame
            uiViewController.scrollToSelectedFilter(animated: false)
        }
    }

}
