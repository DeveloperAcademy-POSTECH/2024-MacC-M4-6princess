//
//  FrameManager+.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 3/15/25.
//

import SwiftUI

extension FrameManager {
    func toggleSelection(for id: UUID, in viewModel: MFViewModel) {
        if viewModel.isEditing {
            if viewModel.selectedImageIds.contains(id) {
                viewModel.selectedImageIds.remove(id)
            } else {
                viewModel.selectedImageIds.insert(id)
            }
        } else {
            updateFrame(withId: id, imageData: viewModel.loadOriginalImageData(for: id))
        }
    }


    func updateFrame(withId id: UUID, imageData: Data?) {
        guard let data = imageData, let uiImage = UIImage(data: data) else { return }
        self.updateFrame = id
        self.pickedImage = uiImage
        self.isFrameLoading = true
    }
}
