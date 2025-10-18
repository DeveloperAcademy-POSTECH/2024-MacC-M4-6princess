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
    func captureTextView(from textView: UITextView){
        // 1) 텍스트 유효성 검사
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            return
        }

        // 2) textView의 inset과 padding 값 읽어오기 (원본 변경 금지)
        let inset = textView.textContainerInset
        let linePadding = textView.textContainer.lineFragmentPadding

        // 3) 실제 글자가 들어갈 폭 계산
        let maxWidth = textView.bounds.width
            - inset.left - inset.right
            - linePadding * 2

        // 4) 줄바꿈·행간 옵션으로 전체 높이 계산
        let bounding = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        // 5) 원하는 추가 여백
        let extraPadding: CGFloat = 0

        // 6) 최종 캔버스 크기
        let contentSize = CGSize(
            width: bounding.width
                   + inset.left + inset.right
                   + linePadding * 2
                   + extraPadding * 2,
            height: bounding.height
                   + inset.top + inset.bottom
                   + extraPadding * 2
        )

        // 7) 그래픽 컨텍스트 시작
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }

        // 8) 투명 배경 초기화
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: contentSize))
        context.setShouldAntialias(true)
        context.interpolationQuality = .high
        context.setRenderingIntent(.perceptual)

        // 9) draw(with:) 호출 위치 계산
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

        // 10) 이미지 얻고 종료
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.renderedImage = image
        
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
