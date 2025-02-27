//
//  FilterCollectionViewRepresentable.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import SwiftUI
//SwiftUI와 UIKit의 연결점...?

struct FilterCollectionViewRepresentable: UIViewControllerRepresentable {
    let filterImages: [StoreImages]
    @Binding var selectedFilter: UUID?
    let viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> FilterCollectionViewController {
        return FilterCollectionViewController(
            filterImages: filterImages,
            selectedFilter: { uuid in
                selectedFilter = uuid
            },
            initialFilter: selectedFilter ?? filterImages.first?.uuid ?? UUID(), viewModel: viewModel
        )
    }
    
    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
        uiViewController.reloadData()
        
        if let selectedFilter = selectedFilter,
           let index = uiViewController.filterImages.firstIndex(where: { $0.uuid == selectedFilter }) {
            uiViewController.collectionView?.scrollToItem(
                at: IndexPath(item: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
}
