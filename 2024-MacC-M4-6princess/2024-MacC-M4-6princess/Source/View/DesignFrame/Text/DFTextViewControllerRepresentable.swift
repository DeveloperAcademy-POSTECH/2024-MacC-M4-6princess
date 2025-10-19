//
//  DFTextViewControllerRepresentable.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import SwiftUI

struct DFTextViewControllerRepresentable: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: DFTextViewModel
    @ObservedObject var modiViewModel: DFModifyViewModel
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var frameManager: FrameManager
    @Environment(\.displayScale) var displayScale
    
    private let editMode: TextEditMode
    private let initialStyle: TextStyle?
    
    // MARK: - Initializers
    
    /// 새 텍스트 생성 모드로 초기화
    init(
        viewModel: DFTextViewModel,
        modiViewModel: DFModifyViewModel
    ) {
        self.viewModel = viewModel
        self.modiViewModel = modiViewModel
        self.editMode = .create
        self.initialStyle = nil
    }
    
    /// 기존 텍스트 수정 모드로 초기화
    init(
        viewModel: DFTextViewModel,
        modiViewModel: DFModifyViewModel,
        textStyle: TextStyle
    ) {
        self.viewModel = viewModel
        self.modiViewModel = modiViewModel
        self.editMode = .edit
        self.initialStyle = textStyle
    }
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = DFTextViewController(
            viewModel: viewModel,
            modiViewModel: modiViewModel,
            imageModel: imageModel,
            frameManager: frameManager,
            displayScale: displayScale,
            editMode: editMode,
            initialStyle: initialStyle
        )
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // SwiftUI 상태가 변경되어도 UIKit 뷰컨트롤러는 재생성하지 않음
        // 필요한 경우 여기서 업데이트 로직 추가 가능
    }
}
