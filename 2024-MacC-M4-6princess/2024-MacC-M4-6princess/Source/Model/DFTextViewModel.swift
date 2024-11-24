//
//  DFTextViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//

import Foundation
import SwiftUI

//MARK: ViewModel 만드는 대신 extension으로 함수만 따로 뺌
extension DFTextView{
    @MainActor
    func renderTextImage(text: String){
        let renderer = ImageRenderer(
            content: TextRenderView(
                text: text,
                selectedFont: selectedFont,
                selectedColor: fontColor,
                selectedAlignment: textAlignment
            )
        )
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            
        }
        else{
            print("render 실패")
        }
    }
    // 정렬 상태 변경 함수
    func computeNextAlignment(for current: TextAlignment, direction: SwipeDirection) -> TextAlignment {
        switch (current, direction) {
            case (.center, .left): return .leading
            case (.center, .right): return .trailing
            case (.leading, .right): return .center
            case (.trailing, .left): return .center
            case (.leading, .left): return .leading // 유지
            case (.trailing, .right): return .trailing // 유지
//            default: return .center
        }
    }
}

