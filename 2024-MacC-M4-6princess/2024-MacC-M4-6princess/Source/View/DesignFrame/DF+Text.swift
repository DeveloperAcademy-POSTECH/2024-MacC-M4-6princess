//
//  DF+Text.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//

import Foundation
import SwiftUI

extension NSTextAlignment {
    init(_ alignment: TextAlignment) {
        switch alignment {
        case .leading:
            self = .left
        case .center:
            self = .center
        case .trailing:
            self = .right
        }
    }
}
extension UIColor {
    convenience init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1] // 기본값: 검정색
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}
