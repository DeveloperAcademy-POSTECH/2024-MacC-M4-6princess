//
//  KeyboardHeightResponder.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 5/1/25.
//

import SwiftUI
import Combine

final class KeyboardHeightResponder: ObservableObject {
    @Published private(set) var currentHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeKeyboardNotifications()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return keyboardFrame.height
            }
            .sink { [weak self] height in
                self?.currentHeight = height
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.currentHeight = 0
            }
            .store(in: &cancellables)
    }
}
