//
//  DF+Text.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//

import Foundation
import SwiftUI

extension DFTextView{
    @MainActor
    func renderImage(text: String = ""){
        let renderer = ImageRenderer(
            content: RenderView(
                text: text,
                selectedFont: selectedFont,
                color: fontColor,
                textAlignment: textAlignment
            )
        )
        
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
        }
    }
    // 정렬 방향 정의
    enum SwipeDirection {
        case left, right
    }
    
    // 정렬 상태 변경 함수
   func nextAlignment(for current: TextAlignment, direction: SwipeDirection) -> TextAlignment {
        switch (current, direction) {
            case (.center, .left): return .leading
            case (.center, .right): return .trailing
            case (.leading, .right): return .center
            case (.trailing, .left): return .center
            case (.leading, .left): return .leading // 유지
            case (.trailing, .right): return .trailing // 유지
            default: return .center
        }
    }
}
struct RenderView: View {
    let text: String
    let selectedFont: FontStyle
    let color: Color
    let textAlignment: TextAlignment
    
    var body: some View {
        Text(text)
        //            .font(Font.custom(fontType,  size: 200))
            .font(selectedFont.applyFont(size: 20))
            .foregroundColor(color)
            .multilineTextAlignment(textAlignment)
        
    }
}
