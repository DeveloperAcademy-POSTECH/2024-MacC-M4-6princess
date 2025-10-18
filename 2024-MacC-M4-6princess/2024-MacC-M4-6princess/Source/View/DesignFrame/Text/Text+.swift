//
//  TextAlignment+Extension.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import SwiftUI
import UIKit

extension TextAlignment {
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .leading:
            return .left
        case .center:
            return .center
        case .trailing:
            return .right
        }
    }
}

extension UIButton {
    func setTitle(_ title: String, size: CGFloat) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: size)
    }
}
