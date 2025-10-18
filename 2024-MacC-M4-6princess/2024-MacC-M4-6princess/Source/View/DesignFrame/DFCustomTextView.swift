//
//  DFCustomTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//
import Foundation
import UIKit
import SwiftUI

struct DFCustomTextView: UIViewRepresentable {
    @FocusState var isKeyboardVisible: Bool
    @ObservedObject var viewModel: DFTextViewModel
    private let displayScale: CGFloat
    @EnvironmentObject var imageModel: ImageListModel
    
    init(
        viewModel: DFTextViewModel,
        displayScale: CGFloat,
        fontSize: CGFloat = 20
    ) {
        self.viewModel = viewModel
        self.displayScale = displayScale
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.attributedText = viewModel.attributedTxt
        textView.font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        textView.textAlignment = NSTextAlignment(viewModel.textAlignment)
        textView.textColor = UIColor(color: viewModel.selectedColor)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        // 키보드를 부드럽게 올리기
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textView.becomeFirstResponder()
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let newFont = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        let newAlignment = NSTextAlignment(viewModel.textAlignment)
        let newColor = UIColor(color: viewModel.selectedColor)
        
        // 변경된 속성만 업데이트
        if uiView.font != newFont {
            uiView.font = newFont
        }
        
        if uiView.textAlignment != newAlignment {
            uiView.textAlignment = newAlignment
        }
        
        if uiView.textColor != newColor {
            uiView.textColor = newColor
        }
        
        // attributedText는 coordinator에서 관리
        if !uiView.isFirstResponder,
           let newAttributedText = viewModel.attributedTxt,
           uiView.attributedText != newAttributedText {
            uiView.attributedText = newAttributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, UITextViewDelegate {
        private var parent: DFCustomTextView
        
        init(_ parent: DFCustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.viewModel.txt = textView.text
            parent.viewModel.attributedTxt = textView.attributedText
            
            let contentSize = textView.sizeThatFits(CGSize(
                width: textView.bounds.width,
                height: CGFloat.greatestFiniteMagnitude
            ))
            parent.viewModel.captureSize = contentSize
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isKeyboardVisible = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isKeyboardVisible = false
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - Extensions

extension DFCustomTextView {
    func focusedTextView() -> UITextView? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .allSubviews
            .compactMap { $0 as? UITextView }
            .first(where: { $0.isFirstResponder })
    }
}

extension UIView {
    var allSubviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSubviews }
    }
}
