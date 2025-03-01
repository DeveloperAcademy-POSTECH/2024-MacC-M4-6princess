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
        Text("없어짐")
//            .font(style.font.applyFont(size: 20))
            .foregroundColor(style.color)
            .multilineTextAlignment(style.alignment)
            .lineSpacing(5)
            .padding(.vertical,3)
    }
}

struct TextStyle {
    var attributedString: NSAttributedString
    var txt:String
    var font: NewFontStyle
    var color: Color
    {
        didSet {
            // 값이 변경될 때마다 프린트
            print("스타일컬러바뀜: \(color.toHex())")
        }
    }
    var alignment: TextAlignment
}
