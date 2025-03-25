//
//  TextRenderView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import SwiftUI
import PhotosUI

struct TextRenderView: View {
    let style: TextStyle
    
    var body: some View {
        Text("없어짐")
            .foregroundColor(style.color)
            .multilineTextAlignment(style.alignment)
            .lineSpacing(5)
            .padding(.vertical,3)
    }
}

struct TextStyle {
    var attributedString: NSAttributedString{
        didSet{
            print("TextStyle:\(attributedString)")
        }
    }
    var txt:String
    var font: NewFontStyle
    var color: Color
    var alignment: TextAlignment
}
