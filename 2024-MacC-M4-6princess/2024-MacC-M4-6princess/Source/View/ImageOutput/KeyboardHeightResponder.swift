//
//  KeyboardHeightResponder.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 5/1/25.
//

import SwiftUI
import Combine

class KeyboardHeightResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                return max(keyboardRect.height - safeAreaBottom, 0)
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
