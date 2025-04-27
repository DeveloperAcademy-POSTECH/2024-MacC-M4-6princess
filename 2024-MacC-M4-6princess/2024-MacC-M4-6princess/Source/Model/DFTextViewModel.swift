//
//  DFTextViewModel.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//

import Foundation
import SwiftUI
import PhotosUI
class DFTextViewModel: ObservableObject {
    @Published var txt = ""
    //    @Published var selectedFont: FontStyle = .modern
    @Published var selectedFont:NewFontStyle = .modern
    @Published var fontSize: Double = 20
    @Published var selectedColor: Color = ColorPreset.colorPallete[0]
    @Published var renderedImage: UIImage?
    @Published var keyboardHeight: CGFloat = 0 // 키보드 높이 상태
    @Published var tab = 0
    @Published var colorNum = 0
    @Published var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorChip: [Color] = ColorPreset.colorPallete
    @Published var attributedTxt: NSAttributedString?
    
    // 캡처 크기를 저장할 변수 추가
    @Published var captureSize: CGSize = .zero // 캡처할 크기 (너비, 높이)
    // 정렬 방향 정의
    enum SwipeDirection {
        case left, right
    }
    // 정렬 상태 변경 함수 -> swift했을 때만
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
    
    /// 정렬 이미지명을 String으로 출력
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
    
    //TODO: 함수명 바꾸기
    /// 누를 때마다 정렬이 바뀜
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
    func captureTextView(from tv: UITextView) -> UIImage? {
        guard let attributedText = tv.attributedText, attributedText.length > 0 else {
            return nil
        }
        
        // 텍스트뷰의 inset을 제거하고 실제 텍스트 크기 가져오기
        tv.textContainerInset = .zero
        
        // as-be
        //        let textSize = attributedText.size() // 실제 텍스트 크기 사용
        //        guard textSize != .zero else {
        //            return nil
        //        }
        //to-be
        let maxWidth = tv.bounds.width
        
        // boundingRect로 높이 계산
        let bounding = attributedText.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                   options: [.usesLineFragmentOrigin,.usesFontLeading], // 텍스트의 라인 기준으로 그리기,폰트의 줄 간격을 구려하여 텍스트 그리기
                                                   context: nil)
        
        // 요청된 패딩 추가 (필요 시 조정)
        let padding: CGFloat = 5
        let contentSize = CGSize(
            width: bounding.width + (padding * 2),
            height: bounding.height + (padding * 2)
        )
        
        // 고해상도 스케일 설정
        let scale: CGFloat = 5.0 // 필요에 따라 조정
        UIGraphicsBeginImageContextWithOptions(contentSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 배경 투명 설정
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: contentSize))
        
        // 렌더링 품질 향상 설정
        context.setShouldAntialias(true)
        context.interpolationQuality = .high
        context.setRenderingIntent(.perceptual)
        
        // 텍스트를 정확한 크기로 그리기
        let drawingRect = CGRect(
            x: padding,
            y: padding,
            width: bounding.width,
            height: bounding.height
        )
        attributedText.draw(
            with: drawingRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    /// DFTextModifyView에서 사용
    @MainActor
    func renderTextImage(text: String, style: TextStyle){
        let renderer = ImageRenderer(
            content: TextRenderView(
                style: style
            )
        )
        renderer.scale = 10
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            
        }
        else{
            print("render 실패")
        }
    }
    
}


extension Color {
    func toHex() -> String? {
        // UIColor 변환 시도
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
