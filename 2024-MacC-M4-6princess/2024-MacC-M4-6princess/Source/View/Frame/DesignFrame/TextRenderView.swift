//
//  TextRenderView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import SwiftUI

struct TextRenderView: View {
    let text: String
    let selectedFont: FontStyle
    let selectedColor: Color
    let selectedAlignment: TextAlignment
    
    var body: some View {
        Text(text)
            .font(selectedFont.applyFont(size: 20))
            .foregroundColor(selectedColor)
            .multilineTextAlignment(selectedAlignment)
            .lineSpacing(5)
        
    }
}
