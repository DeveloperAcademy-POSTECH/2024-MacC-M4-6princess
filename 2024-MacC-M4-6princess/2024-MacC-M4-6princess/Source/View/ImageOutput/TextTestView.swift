import SwiftUI
import UIKit

// Custom UITextView to expose become/resignFirstResponder
class FocusableTextView: UITextView {
    func focus() {
        becomeFirstResponder()
    }
    
    func unfocus() {
        resignFirstResponder()
    }
}

struct TextTestView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = "Enter text..."
    var isFocused: Bool

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextTestView

        init(_ parent: TextTestView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = .label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> FocusableTextView {
        let textView = FocusableTextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        
        /// 배경을 투명하게
        textView.backgroundColor = .clear         // 뷰 자체 배경 투명
        textView.isOpaque = false                 // 투명화 가능하게 설정
        textView.layer.backgroundColor = nil      // 레이어 배경도 제거
        

        
        
        textView.backgroundColor = .clear
        textView.text = text.isEmpty ? placeholder : text
        textView.textColor = text.isEmpty ? .placeholderText : .label
        return textView
    }

    func updateUIView(_ uiView: FocusableTextView, context: Context) {
        if uiView.text != text && !(uiView.isFirstResponder && uiView.textColor != .placeholderText) {
            uiView.text = text
            uiView.textColor = .label
        }

        // 자동 포커스 or 포커스 해제
        if isFocused {
            uiView.focus()
        } else {
            uiView.unfocus()
        }
    }
}
