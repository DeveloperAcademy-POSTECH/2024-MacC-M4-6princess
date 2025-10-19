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
    
    // 🔥 폰트 크기 기반 동적 스케일 결정
    private func determineOptimalScale(fontSize: CGFloat) -> CGFloat {
        switch fontSize {
        case 0..<15:
            return 7.0
        case 15..<20:
            return 6.5
        case 20..<30:
            return 6.0
        case 30..<40:
            return 5.5
        case 40..<50:
            return 5.0
        case 50..<60:
            return 4.5
        default:
            return 4.0
        }
    }
    
    // 🔥 폰트 크기 기반 동적 여백 계산
    private func calculatePadding(fontSize: CGFloat) -> (inset: UIEdgeInsets, extra: CGFloat) {
        // 폰트 크기의 일정 비율로 여백 계산
        // 작은 폰트: 최소 여백 보장
        // 큰 폰트: 비례적으로 증가
        
        let basePadding: CGFloat
        let extraPadding: CGFloat
        
        switch fontSize {
        case 0..<15:
            // 매우 작은 폰트: 최소 여백
            basePadding = 3
            extraPadding = 2
            
        case 15..<20:
            // 작은 폰트: 작은 여백
            basePadding = 4
            extraPadding = 3
            
        case 20..<30:
            // 기본 폰트: 적당한 여백
            basePadding = 5
            extraPadding = 4
            
        case 30..<40:
            // 중간 폰트: 넉넉한 여백
            basePadding = 7
            extraPadding = 5
            
        case 40..<50:
            // 큰 폰트: 큰 여백
            basePadding = 9
            extraPadding = 6
            
        case 50..<60:
            // 매우 큰 폰트: 매우 큰 여백
            basePadding = 11
            extraPadding = 8
            
        default:
            // 초대형 폰트: 최대 여백
            basePadding = 14
            extraPadding = 10
        }
        
        let inset = UIEdgeInsets(
            top: 0,
            left: basePadding,
            bottom: 0,
            right: basePadding
        )
        
        return (inset: inset, extra: extraPadding)
    }
    
    @MainActor
    func captureTextView(from textView: UITextView) {
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            return
        }
        
        // 원본 inset 저장
        let originalInset = textView.textContainerInset
        
        // 🔥 폰트 크기에 따른 동적 여백 계산
        let padding = calculatePadding(fontSize: fontSize)
        let captureInset = padding.inset
        let extraPadding = padding.extra
        
        // 캡처용 inset 설정
        textView.textContainerInset = captureInset
        
        // 레이아웃 강제 업데이트
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        let linePadding = textView.textContainer.lineFragmentPadding
        
        // 실제 텍스트가 차지하는 너비 계산
        let maxWidth = textView.bounds.width
            - captureInset.left - captureInset.right
            - linePadding * 2
        
        // 실제 텍스트 크기 정확히 계산
        let bounding = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // 최종 캔버스 크기
        let contentSize = CGSize(
            width: ceil(bounding.width) + captureInset.left + captureInset.right + linePadding * 2 + extraPadding * 2,
            height: ceil(bounding.height) + captureInset.top + captureInset.bottom + extraPadding * 2
        )
        
        // 폰트 크기 기반 동적 스케일 결정
        let scale = determineOptimalScale(fontSize: fontSize)
        
        // 📊 디버그 로그
        #if DEBUG
        print("📐 Text Capture Info:")
        print("  - Font Size: \(fontSize)pt")
        print("  - Base Padding: \(captureInset.left)pt")
        print("  - Extra Padding: \(extraPadding)pt")
        print("  - Content Size: \(Int(contentSize.width)) x \(Int(contentSize.height))")
        print("  - Scale: \(scale)x")
        print("  - Final Image: \(Int(contentSize.width * scale)) x \(Int(contentSize.height * scale)) px")
        #endif
        
        // 그래픽 컨텍스트 시작
        UIGraphicsBeginImageContextWithOptions(contentSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            textView.textContainerInset = originalInset
            textView.setNeedsLayout()
            UIGraphicsEndImageContext()
            return
        }
        
        // 투명 배경
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: contentSize))
        context.setShouldAntialias(true)
        context.interpolationQuality = .high
        context.setRenderingIntent(.perceptual)
        
        // 텍스트 그리기 영역
        let drawRect = CGRect(
            x: captureInset.left + linePadding + extraPadding,
            y: captureInset.top + extraPadding,
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
        
        // 원본 inset 복원
        textView.textContainerInset = originalInset
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        self.renderedImage = image
        
        #if DEBUG
        if let finalImage = image {
            print("  ✅ Result: \(finalImage.size.width) x \(finalImage.size.height) @\(finalImage.scale)x")
        }
        #endif
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
