//
//  Color.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 10/11/24.
//

import Foundation
import UIKit
import SwiftUICore

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexColor = hexColor.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgb)
        
        r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        b = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Color {
    init?(hex: String) {
        if let uiColor = UIColor(hex: hex) {
            self = Color(uiColor)
        } else {
            return nil
        }
    }
}
