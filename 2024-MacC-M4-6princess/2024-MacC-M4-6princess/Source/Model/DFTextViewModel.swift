//
//  DFTextViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI

class DFTextViewModel: ObservableObject {
    @Published var txt = ""
    @Published var selectedFont: NewFontStyle = .modern
    @Published var fontSize: Double = 20
    @Published var selectedColor: Color = ColorPreset.colorPallete[0]
    @Published var selectedUIColor: UIColor = UIColor(ColorPreset.colorPallete[0])
    @Published var renderedImage: UIImage?
    @Published var keyboardHeight: CGFloat = 0
    @Published var tab = 0
    @Published var colorNum = 0
    @Published var textAlignment: TextAlignment = .center
    
    let colorChip: [Color] = ColorPreset.colorPallete
    let colorChipUIColor: [UIColor] = ColorPreset.colorPallete.map { UIColor($0) }
    
    @Published var attributedTxt: NSAttributedString?
    @Published var captureSize: CGSize = .zero
    
    enum SwipeDirection {
        case left, right
    }
    
    func computeNextAlignment(for current: TextAlignment, direction: SwipeDirection) -> TextAlignment {
        switch (current, direction) {
        case (.center, .left): return .leading
        case (.center, .right): return .trailing
        case (.leading, .right): return .center
        case (.trailing, .left): return .center
        case (.leading, .left): return .leading
        case (.trailing, .right): return .trailing
        }
    }
    
    func imageForAlignment(_ alignment: TextAlignment) -> String {
        switch alignment {
        case .leading:
            return "df.alignment.leading"
        case .center:
            return "df.alignment.center"
        case .trailing:
            return "df.alignment.trailing"
        }
    }
    
    func toggleTextAlignment() {
        switch textAlignment {
        case .leading:
            textAlignment = .center
        case .center:
            textAlignment = .trailing
        case .trailing:
            textAlignment = .leading
        }
    }
    
    @MainActor
    func captureTextView(from textView: UITextView) {
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            return
        }
        
        let inset = textView.textContainerInset
        let linePadding = textView.textContainer.lineFragmentPadding
        
        let maxWidth = textView.bounds.width
            - inset.left - inset.right
            - linePadding * 2
        
        let bounding = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let extraPadding: CGFloat = 0
        
        let contentSize = CGSize(
            width: bounding.width
                   + inset.left + inset.right
                   + linePadding * 2
                   + extraPadding * 2,
            height: bounding.height
                   + inset.top + inset.bottom
                   + extraPadding * 2
        )
        
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: contentSize))
        context.setShouldAntialias(true)
        context.interpolationQuality = .high
        context.setRenderingIntent(.perceptual)
        
        let drawRect = CGRect(
            x: inset.left + linePadding + extraPadding,
            y: inset.top + extraPadding,
            width: bounding.width,
            height: bounding.height
        )
        attributedText.draw(
            with: drawRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.renderedImage = image
    }
    
    @MainActor
    func renderTextImage(text: String, style: TextStyle) {
        let renderer = ImageRenderer(
            content: TextRenderView(style: style)
        )
        renderer.scale = 10
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
        } else {
            print("render 실패")
        }
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
