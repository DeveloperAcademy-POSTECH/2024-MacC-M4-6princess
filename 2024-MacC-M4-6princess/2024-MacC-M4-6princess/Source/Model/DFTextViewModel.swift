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
    @Published var newSelectedFont:NewFontStyle = .modern
    @Published var fontSize: Double = 20
    @Published var fontColor: Color = ColorPreset.colorPallete[0] {
        didSet {
            // 값이 변경될 때마다 프린트
            print("폰트컬러체인지드: \(fontColor.toHex())")
        }
    }
    @Published var renderedImage: UIImage?
    @Published var keyboardHeight: CGFloat = 0 // 키보드 높이 상태
    @Published var tab = 0
    @Published var colorNum = 0
    @Published var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorChip: [Color] = ColorPreset.colorPallete
    @Published var attributedTxt: NSAttributedString?
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
    func attributtedTextToImage() -> UIImage? {
        // 현재 attributedTxt가 비어있거나 nil이면 nil 반환
        guard let attributedText = attributedTxt, attributedText.length > 0 else {
            return nil
        }
        
        // 최신 스타일을 적용하기 위해 새로운 NSMutableAttributedString 생성
        let updatedAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // viewModel에서 최신 스타일 가져오기
        let font = newSelectedFont.applyFont(size: fontSize) // 폰트와 크기 적용
        let textColor = UIColor(color: fontColor) // 텍스트 색상
        let range = NSRange(location: 0, length: updatedAttributedText.length) // 전체 텍스트 범위
        
        // 최신 폰트와 색상 속성 적용
        updatedAttributedText.addAttributes([
            .font: font,
            .foregroundColor: textColor
        ], range: range)
        
        // 정렬을 반영하기 위해 NSMutableParagraphStyle 사용
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment(textAlignment) // 최신 textAlignment 적용
        updatedAttributedText.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range
        )
        
        // 가장 긴 줄의 너비 계산
        let lines = updatedAttributedText.string.split(separator: "\n") // 텍스트를 줄 단위로 분리
        var maxLineWidth: CGFloat = 0
        let maxHeight: CGFloat = .greatestFiniteMagnitude
        
        for line in lines {
            let lineAttributedText = NSAttributedString(
                string: String(line),
                attributes: [
                    .font: font,
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle
                ]
            )
            let lineSize = lineAttributedText.boundingRect(
                with: CGSize(width: .greatestFiniteMagnitude, height: maxHeight),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size
            maxLineWidth = max(maxLineWidth, ceil(lineSize.width))
        }
        
        // 전체 텍스트 높이 계산 (최대 너비를 가장 긴 줄에 맞춤)
        let textSize = updatedAttributedText.boundingRect(
            with: CGSize(width: maxLineWidth, height: maxHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        // 패딩 추가 (양쪽 10포인트씩)
        let padding: CGFloat = 10
        let imageSize = CGSize(
            width: maxLineWidth + (padding * 2),
            height: ceil(textSize.height) + (padding * 2)
        )
        
        // 그래픽 컨텍스트 설정 (이미지 렌더링 시작)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // 안티앨리어싱 설정 (텍스트가 깔끔하게 보이도록)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // 배경 설정 (투명 배경으로 설정)
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        // 텍스트를 그릴 영역 설정 (패딩 고려)
        let drawingRect = CGRect(
            x: padding,
            y: padding,
            width: imageSize.width - (padding * 2),
            height: imageSize.height - (padding * 2)
        )
        
        // 업데이트된 속성 텍스트 그리기
        updatedAttributedText.draw(in: drawingRect)
        
        // 컨텍스트에서 이미지 생성
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



//struct DFCustomTextView: UIViewRepresentable {
//    @ObservedObject var modiViewModel: DFModifyViewModel
//    @ObservedObject var viewModel: DFTextViewModel
//    
//    private let displayScale: CGFloat
//    @EnvironmentObject var imageModel: ImageListModel
//    
//    init(modiViewModel: DFModifyViewModel,
//         viewModel: DFTextViewModel,
//         displayScale: CGFloat) {
//        self.modiViewModel = modiViewModel
//        self.viewModel = viewModel
//        self.displayScale = displayScale
//    }
//    
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.delegate = context.coordinator
//        textView.backgroundColor = .clear
//        textView.isScrollEnabled = true
//        
//        // Center text horizontally
//        textView.textAlignment = .center
//        
//        // Center text vertically
//        textView.contentInsetAdjustmentBehavior = .automatic
//        
//        // Add keyboard notifications
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
//                                               object: nil,
//                                               queue: .main) { notification in
//            context.coordinator.adjustForKeyboard(notification: notification, textView: textView)
//        }
//        
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
//                                               object: nil,
//                                               queue: .main) { notification in
//            context.coordinator.adjustForKeyboard(notification: notification, textView: textView)
//        }
//        
//        // iOS 18.0 이상에서 적응형 이미지 글리프 지원 설정
//        if #available(iOS 18.0, *) {
//            textView.supportsAdaptiveImageGlyph = true
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        updateTextViewAppearance(textView)
//        return textView
//    }
//    
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        // Update text
//        uiView.text = viewModel.txt
//        
//        // Apply real-time font color, size, and font family
//        updateTextViewAppearance(uiView)
//        
//        // Center text vertically
//        let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
//        let topOffset = max(0, (uiView.bounds.height - size.height) / 2)
//        uiView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
//    }
//    
//    private func updateTextViewAppearance(_ textView: UITextView) {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 5
//        paragraphStyle.alignment = .center
//        
//        // 기존 attributedText를 가져와서 수정
//        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString(string: textView.text ?? ""))
//        
//        let attributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(viewModel.fontColor),
//            .font: UIFont(name: viewModel.newSelectedFont.rawValue, size: viewModel.fontSize) ?? UIFont.systemFont(ofSize: viewModel.fontSize),
//            .paragraphStyle: paragraphStyle
//        ]
//        
//        // 기존 텍스트 전체에 속성 적용 (이미지 글리프 유지)
//        mutableAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttributedString.length))
//        
//        textView.attributedText = mutableAttributedString
//        textView.typingAttributes = attributes
//        
//        textView.bounds.size.height = UIScreen.main.bounds.height / 4
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: DFCustomTextView
//        
//        init(_ parent: DFCustomTextView) {
//            self.parent = parent
//        }
//        
//        func textViewDidChange(_ textView: UITextView) {
//            parent.viewModel.txt = textView.text
//            
//            // Recenter text vertically when content changes
//            let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
//            let topOffset = max(0, (textView.bounds.height - size.height) / 2)
//            textView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
//        }
//        
//        func adjustForKeyboard(notification: Notification, textView: UITextView) {
//            guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//            
//            let keyboardScreenEndFrame = keyboardValue.cgRectValue
//            let keyboardIsShowing = notification.name == UIResponder.keyboardWillShowNotification
//            
//            if keyboardIsShowing {
//                let keyboardHeight = keyboardScreenEndFrame.height
//                textView.contentInset = UIEdgeInsets(top: (textView.bounds.height - textView.contentSize.height) / 2,
//                                                     left: 0,
//                                                     bottom: keyboardHeight,
//                                                     right: 0)
//            } else {
//                let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
//                let topOffset = max(0, (textView.bounds.height - size.height) / 2)
//                textView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
//            }
//            
//            textView.scrollIndicatorInsets = textView.contentInset
//        }
//    }
//}
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
