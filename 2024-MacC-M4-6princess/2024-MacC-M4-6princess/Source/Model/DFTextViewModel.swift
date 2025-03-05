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
    func captureTextContent(from textView: UITextView) -> UIImage? {
        // 텍스트뷰의 attributedText가 nil이거나 길이가 0이면 nil 반환
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            print("Debug: attributedText is nil or empty")
            return nil
        }
        
        // 디버깅: attributedText 속성 확인
        print("Debug: Full attributedText: \(attributedText.string)")
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attrs, range, _ in
            print("Debug: Attributes at \(range): \(attrs)")
            if let attachment = attrs[.attachment] as? NSTextAttachment {
                print("Debug: Found NSTextAttachment - bounds: \(attachment.bounds), image: \(String(describing: attachment.image))")
            }
        }
        
        // viewModel.captureSize를 사용해 콘텐츠 크기 가져오기
        let captureSize = captureSize
        guard captureSize != .zero else {
            print("Debug: captureSize is zero, falling back to default calculation")
            return nil // 또는 기존 방식으로 계산
        }
        
        // 요청된 패딩 10 추가
        let padding: CGFloat = 5
        let contentSize = CGSize(
            width: captureSize.width + (padding * 2),
            height: captureSize.height + (padding * 2)
        )
        
        // 디버깅: 크기 확인
        print("Debug: viewModel.captureSize: \(captureSize)")
        print("Debug: Final contentSize with padding: \(contentSize)")
        print("Debug: Attributed text length: \(attributedText.length), String: \(attributedText.string)")
        
        // 그래픽 컨텍스트 설정
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Debug: Failed to get graphics context")
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 배경 투명 설정
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: contentSize))
        
        // 텍스트와 이미지 글리프 그리기 (패딩 고려)
        let drawingRect = CGRect(
            x: padding,
            y: padding,
            width: captureSize.width,
            height: captureSize.height
        )
        print("Debug: Drawing rect: \(drawingRect)")
        attributedText.draw(in: drawingRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 디버깅: 생성된 이미지 크기 확인
        if let image = image {
            print("Debug: Captured image size: \(image.size)")
            if let imageData = image.pngData() {
                let debugPath = NSTemporaryDirectory() + "capturedText.png"
                try? imageData.write(to: URL(fileURLWithPath: debugPath))
                print("Debug: Image saved to \(debugPath)")
            }
        } else {
            print("Debug: Failed to capture image")
        }
        
        return image
    }
//    @MainActor
//    // UITextView의 텍스트와 이미지 글리프가 포함된 콘텐츠 영역만 캡처하여 UIImage로 반환하는 함수
//    func captureTextContent(from textView: UITextView) -> UIImage? {
//        // 텍스트뷰의 attributedText가 nil이거나 길이가 0이면 nil 반환
//        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
//            print("Debug: attributedText is nil or empty")
//            return nil
//        }
//        
//        // 디버깅: attributedText 전체 속성 출력
//        print("Debug: Full attributedText: \(attributedText.string)")
//        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attrs, range, _ in
//            print("Debug: Attributes at \(range): \(attrs)")
//            if let attachment = attrs[.attachment] as? NSTextAttachment {
//                print("Debug: Found NSTextAttachment - bounds: \(attachment.bounds), image: \(String(describing: attachment.image))")
//            }
//        }
//        
//        // NSLayoutManager를 사용해 콘텐츠 크기 계산
//        let textStorage = NSTextStorage(attributedString: attributedText)
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
//        textContainer.lineFragmentPadding = 0
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//        
//        // 전체 글리프 범위와 크기 계산
//        let glyphRange = layoutManager.glyphRange(for: textContainer)
//        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//        
//        // 디버깅: 각 줄의 글리프 범위와 위치 출력
//        print("Debug: Glyph range: \(glyphRange)")
//        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { rect, usedRect, textContainer, lineGlyphRange, _ in
//            print("Debug: Line fragment - Rect: \(rect), Used rect: \(usedRect), Glyph range: \(lineGlyphRange)")
//        }
//        
//        // 디버깅: 개별 글리프 위치 확인 (선택적)
//        for glyphIndex in glyphRange.location..<NSMaxRange(glyphRange) {
//            let glyphPoint = layoutManager.location(forGlyphAt: glyphIndex)
//            let charRange = layoutManager.characterRange(forGlyphRange: NSRange(location: glyphIndex, length: 1), actualGlyphRange: nil)
//            print("Debug: Glyph \(glyphIndex) - Position: \(glyphPoint), Char range: \(charRange)")
//        }
//        
//        // 여유분 추가: 폰트 메트릭과 이미지 글리프를 완전히 포함하기 위해
//        let extraPadding: CGFloat = 10
//        let contentWidth = ceil(boundingRect.width) + extraPadding
//        let contentHeight = ceil(boundingRect.height) + extraPadding
//        
//        // 요청된 패딩 10 추가
//        let padding: CGFloat = 10
//        let contentSize = CGSize(
//            width: contentWidth + (padding * 2),
//            height: contentHeight + (padding * 2)
//        )
//        
//        // 디버깅: 계산된 크기와 비교
//        print("Debug: boundingRect: \(boundingRect)")
//        print("Debug: Calculated contentWidth: \(contentWidth), contentHeight: \(contentHeight)")
//        print("Debug: Final contentSize with padding: \(contentSize)")
//        print("Debug: Attributed text length: \(attributedText.length), String: \(attributedText.string)")
//        
//        // 디버깅: 마지막 글자의 예상 위치 계산
//        if attributedText.length > 0 {
//            let lastCharRange = NSRange(location: attributedText.length - 1, length: 1)
//            let lastGlyphRange = layoutManager.glyphRange(forCharacterRange: lastCharRange, actualCharacterRange: nil)
//            let lastGlyphRect = layoutManager.boundingRect(forGlyphRange: lastGlyphRange, in: textContainer)
//            print("Debug: Last character glyph rect: \(lastGlyphRect)")
//            if lastGlyphRect.maxX > contentWidth || lastGlyphRect.maxY > contentHeight {
//                print("Debug: Warning - Last glyph exceeds content dimensions!")
//            }
//        }
//        
//        // 그래픽 컨텍스트 설정
//        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            print("Debug: Failed to get graphics context")
//            UIGraphicsEndImageContext()
//            return nil
//        }
//        
//        // 배경 투명 설정
//        UIColor.clear.setFill()
//        context.fill(CGRect(origin: .zero, size: contentSize))
//        
//        // 텍스트와 이미지 글리프 그리기 (패딩 고려)
//        let drawingRect = CGRect(
//            x: padding,
//            y: padding,
//            width: contentWidth,
//            height: contentHeight
//        )
//        print("Debug: Drawing rect: \(drawingRect)")
//        attributedText.draw(in: drawingRect)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        // 디버깅: 생성된 이미지 크기 확인
//        if let image = image {
//            print("Debug: Captured image size: \(image.size)")
//            if let imageData = image.pngData() {
//                let debugPath = NSTemporaryDirectory() + "capturedText.png"
//                try? imageData.write(to: URL(fileURLWithPath: debugPath))
//                print("Debug: Image saved to \(debugPath)")
//            }
//        } else {
//            print("Debug: Failed to capture image")
//        }
//        
//        return image
//    }
//    @MainActor
//        func captureTextContent(from textView: UITextView) -> UIImage? {
//            guard let attributedText = textView.attributedText, attributedText.length > 0 else {
//                return nil
//            }
//            
//            // NSLayoutManager를 사용해 콘텐츠 크기 계산
//            let textStorage = NSTextStorage(attributedString: attributedText)
//            let layoutManager = NSLayoutManager()
//            // 폭을 충분히 크게 설정해 줄바꿈 없이 전체 콘텐츠 계산
//            let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
//            textContainer.lineFragmentPadding = 0
//            layoutManager.addTextContainer(textContainer)
//            textStorage.addLayoutManager(layoutManager)
//            
//            // 전체 글리프 범위와 크기 계산
//            let glyphRange = layoutManager.glyphRange(for: textContainer)
//            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//            let contentSize = CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
//            
//            // 디버깅: 계산된 크기 출력
//            print("Calculated contentSize: \(contentSize)")
//            print("Attributed text: \(attributedText.string)")
//            
//            // 그래픽 컨텍스트 설정
//            UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
//            guard let context = UIGraphicsGetCurrentContext() else {
//                UIGraphicsEndImageContext()
//                return nil
//            }
//            
//            // 배경 투명 설정
//            UIColor.clear.setFill()
//            context.fill(CGRect(origin: .zero, size: contentSize))
//            
//            // 텍스트와 이미지 글리프 그리기
//            attributedText.draw(in: CGRect(origin: .zero, size: contentSize))
//            
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            // 디버깅: 생성된 이미지 크기 확인
//            if let image = image {
//                print("Captured image size: \(image.size)")
//            }
//            
//            return image
//        }
//    @MainActor
//        func captureTextContent(from textView: UITextView) -> UIImage? {
//            guard let attributedText = textView.attributedText, attributedText.length > 0 else {
//                return nil
//            }
//            
//            let textStorage = NSTextStorage(attributedString: attributedText)
//            let layoutManager = NSLayoutManager()
//            let textContainer = NSTextContainer(size: CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
//            textContainer.lineFragmentPadding = 0
//            layoutManager.addTextContainer(textContainer)
//            textStorage.addLayoutManager(layoutManager)
//            
//            let glyphRange = layoutManager.glyphRange(for: textContainer)
//            let usedRect = layoutManager.usedRect(for: textContainer)
//            let contentSize = CGSize(width: ceil(usedRect.width), height: ceil(usedRect.height))
//            
//            UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
//            guard let context = UIGraphicsGetCurrentContext() else {
//                UIGraphicsEndImageContext()
//                return nil
//            }
//            
//            UIColor.clear.setFill()
//            context.fill(CGRect(origin: .zero, size: contentSize))
//            attributedText.draw(in: CGRect(origin: .zero, size: contentSize))
//            
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            return image
//        }
 
    @MainActor
    func attributedTextToImage() -> UIImage? {
        // 현재 attributedTxt가 비어있거나 nil이면 nil 반환
        guard let attributedText = attributedTxt, attributedText.length > 0 else {
            return nil
        }
        print("attributedText: \(attributedText.string)")
        
        // 최신 스타일을 적용하기 위해 새로운 NSMutableAttributedString 생성
        let updatedAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // viewModel에서 폰트, 색상, 사이즈 적용
        let font = newSelectedFont.applyFont(size: fontSize)
        let textColor = UIColor(color: fontColor)
        let range = NSRange(location: 0, length: updatedAttributedText.length)
        
        // 기존 속성 유지하며 폰트와 색상만 추가 (이미지 글리프 손실 방지)
        updatedAttributedText.enumerateAttributes(in: range, options: []) { attrs, range, _ in
            var newAttrs = attrs
            // NSTextAttachment가 없는 경우에만 폰트와 색상 적용
            if newAttrs[.attachment] == nil {
                newAttrs[.font] = font
                newAttrs[.foregroundColor] = textColor
            }
            updatedAttributedText.setAttributes(newAttrs, range: range)
        }
        
        // 정렬과 줄바꿈 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment(textAlignment)
        paragraphStyle.lineBreakMode = .byClipping // 줄바꿈 억제
        updatedAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        print("updatedAttributedText: \(updatedAttributedText.string)")
        
        // 이미지 글리프 확인 (디버깅용)
        updatedAttributedText.enumerateAttribute(.attachment, in: range) { value, range, _ in
            if let attachment = value as? NSTextAttachment {
                print("이미지 글리프 발견: \(attachment.bounds), 이미지: \(String(describing: attachment.image))")
            }
        }
        
        // NSLayoutManager를 사용해 정확한 레이아웃 계산
        let textStorage = NSTextStorage(attributedString: updatedAttributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // 전체 텍스트와 이미지 글리프의 크기 계산
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let maxLineWidth = ceil(usedRect.width)
        let totalHeight = ceil(usedRect.height)
        
        // 패딩 추가
        let padding: CGFloat = 20
        let imageSize = CGSize(
            width: maxLineWidth + (padding * 2),
            height: totalHeight + (padding * 2)
        )
        print("imageSize: \(imageSize)")
        
        // 그래픽 컨텍스트 설정
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 안티앨리어싱 설정
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        // 배경 설정 (투명)
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        // 텍스트와 이미지 글리프를 그릴 영역 설정
        let drawingRect = CGRect(
            x: padding,
            y: padding,
            width: maxLineWidth,
            height: totalHeight
        )
        
        // 전체 텍스트와 이미지 글리프 그리기
        updatedAttributedText.draw(in: drawingRect)
        
        // 이미지 생성
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
