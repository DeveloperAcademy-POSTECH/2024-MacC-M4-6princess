//
//  DFTextViewControllerRepresentable.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import SwiftUI

struct DFTextViewControllerRepresentable: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: DFTextViewModel
    @ObservedObject var modiViewModel: DFModifyViewModel
    @EnvironmentObject var imageModel: ImageListModel
    @Environment(\.displayScale) var displayScale
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = DFTextViewController(
            viewModel: viewModel,
            modiViewModel: modiViewModel,
            imageModel: imageModel,
            displayScale: displayScale
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 필요시 업데이트 로직 구현
    }
}
