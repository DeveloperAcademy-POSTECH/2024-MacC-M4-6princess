//
//  DFTextViewWrapper.swift
//  2024-MacC-M4-6princess
//
//  Created by 잠만보김쥬디 on 10/18/25.
//
import SwiftUI
import UIKit

struct DFTextViewWrapper: UIViewControllerRepresentable {
    @ObservedObject var modiViewModel: DFModifyViewModel
    let viewModel: DFTextViewModel
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = DFTextViewController(
            viewModel: viewModel,
            modiViewModel: modiViewModel
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 필요한 경우 업데이트 로직 추가
    }
}

// MARK: - SwiftUI에서 사용 예시

extension View {
    func presentDFTextView(
        isPresented: Binding<Bool>,
        viewModel: DFTextViewModel,
        modiViewModel: DFModifyViewModel
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            DFTextViewWrapper(
                modiViewModel: modiViewModel,
                viewModel: viewModel
            )
            .ignoresSafeArea()
        }
    }
}
