//
//  TextRenderView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import SwiftUI

struct TextRenderView: View {
    let style: TextStyle
    
    var body: some View {
        Text(style.rawText)
            .font(style.font.applyFont(size: 20))
            .foregroundColor(style.color)
            .multilineTextAlignment(style.alignment)
            .lineSpacing(5)
    }
}

struct TextStyle {
    var rawText: String
    var font: FontStyle
    var color: Color
    var alignment: TextAlignment
}
