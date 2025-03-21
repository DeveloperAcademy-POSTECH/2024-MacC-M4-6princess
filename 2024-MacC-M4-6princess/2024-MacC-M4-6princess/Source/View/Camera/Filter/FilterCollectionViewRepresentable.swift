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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: StoreImages.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)] // 빈 배열 전달

    ) var filterImages: FetchedResults<StoreImages>
    let viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> FilterCollectionViewController {
        return FilterCollectionViewController(
            filterImages: Array(filterImages),
            selectedFilter: { uuid in
                frameManager.selectedFrame = uuid
            },
            initialFilter: frameManager.selectedFrame,
            viewModel: viewModel,
            frameManager: frameManager
        )
    }
    
    func updateUIViewController(_ uiViewController: FilterCollectionViewController, context: Context) {
        uiViewController.filterImages = Array(filterImages.reversed())
        uiViewController.collectionView.reloadData()
        
        if uiViewController.currentSelectedFilter != frameManager.selectedFrame {
            uiViewController.currentSelectedFilter = frameManager.selectedFrame
            uiViewController.scrollToSelectedFilter(animated: false)
        }
    }
}
