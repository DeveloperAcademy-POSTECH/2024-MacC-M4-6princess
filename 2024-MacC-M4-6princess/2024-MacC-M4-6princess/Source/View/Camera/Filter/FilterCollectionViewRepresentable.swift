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
    @Binding var selectedFilter: UUID?
    let viewModel: CameraViewModel

    func makeUIViewController(context: Context) -> FilterCollectionViewController {
        return FilterCollectionViewController(
            filterImages: filterImages,
            selectedFilter: { uuid in
                selectedFilter = uuid
            },
            initialFilter: selectedFilter ?? filterImages.first?.uuid ?? UUID(),
            viewModel: viewModel,
            frameManager: frameManager
        )
    }

    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
        // collectionView의 reloadData() 호출
        uiViewController.collectionView.reloadData()
        
        // 선택된 필터를 스크롤로 중앙에 위치시키기
        if let selectedFilter = selectedFilter,
           let index = uiViewController.filterImages.firstIndex(where: { $0.uuid == selectedFilter }) {
            uiViewController.collectionView.scrollToItem(
                at: IndexPath(item: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
}
