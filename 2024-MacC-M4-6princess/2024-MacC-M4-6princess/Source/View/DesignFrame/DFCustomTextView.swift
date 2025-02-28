//
//  DFCustomTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import Foundation
import UIKit
import SwiftUI

struct CustomTextView: UIViewRepresentable {
    @FocusState var isKeyboardVisible: Bool
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel: DFTextViewModel
    private let displayScale: CGFloat
    let fontSize: CGFloat
    @EnvironmentObject var imageModel: ImageListModel
    
    init(modiViewModel: DFModifyViewModel,
         viewModel: DFTextViewModel,
         displayScale: CGFloat,fontSize:CGFloat=20) {  // 기본값
        self.modiViewModel = modiViewModel
        self.viewModel = viewModel
        self.displayScale = displayScale
        self.fontSize = fontSize
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // 폰트 설정
        let font = viewModel.newSelectedFont.applyFont(size: fontSize)
       
        textView.font = font
        
        // 텍스트 정렬 및 색상 설정
        textView.textAlignment = NSTextAlignment(viewModel.textAlignment)
        textView.textColor = UIColor(color: viewModel.fontColor)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.keyboardDismissMode = .interactive
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        // 키보드 노티피케이션 추가
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        context.coordinator.centerTextVertically(in: textView)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != viewModel.txt {
            uiView.text = viewModel.txt
            context.coordinator.centerTextVertically(in: uiView)
        }
        
        // 업데이트 시 속성 적용
        let font = viewModel.newSelectedFont.applyFont(size: fontSize)
        
        uiView.font = font
        uiView.textAlignment = NSTextAlignment(viewModel.textAlignment)
        uiView.textColor = UIColor(color: viewModel.fontColor)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.viewModel.txt = textView.text
                self.parent.viewModel.attributedTxt = textView.attributedText
                self.centerTextVertically(in: textView)
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = true
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = false
            }
        }
        
        func centerTextVertically(in textView: UITextView) {
            let size = textView.bounds.size
            let contentSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            let topInset = max(0, (size.height - contentSize.height) / 2)
            textView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: topInset, right: 0)
        }
        
        @objc func keyboardWillShow(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            let keyboardHeight = keyboardFrame.height
            if let textView = parent.focusedTextView() {
                let adjustedHeight = textView.bounds.height - keyboardHeight
                let contentSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
                let topInset = max(0, (adjustedHeight - contentSize.height) / 2)
                textView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: keyboardHeight, right: 0)
            }
        }
        
        @objc func keyboardWillHide(_ notification: Notification) {
            if let textView = parent.focusedTextView() {
                centerTextVertically(in: textView)
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

extension CustomTextView {
    func focusedTextView() -> UITextView? {
        UIApplication.shared.windows.first?.allSubviews.compactMap { $0 as? UITextView }.first { $0.isFirstResponder }
    }
}

extension UIView {
    var allSubviews: [UIView] {
        return subviews.flatMap { [$0] + $0.allSubviews }
    }
}
