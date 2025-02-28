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
    @Published var selectedFont: FontStyle = .modern
    @Published var newSelectedFont:NewFontStyle = .modern
    @Published var fontSize: Double = 20
    @Published var fontColor: Color = ColorPreset.colorPallete[0]
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
    
    /// DFTextView에서 사용
    @MainActor
    func renderTextImage(text: String){
        let tmp = ImageRenderer(
            content: TextRenderView(
                style: TextStyle(rawText: text, font: selectedFont, color: fontColor, alignment: textAlignment)
            )
        )
        //TODO: scale 계산 부분 넣기
        tmp.scale = 10
        if let uiImage = tmp.uiImage {
            renderedImage = uiImage
        }
        else{
            print("text render 실패")
        }
    }
    @MainActor
    
    // Function to render attributed text as an image
    func renderTextAsImage() -> UIImage? {
        guard let attributedText = attributedTxt, attributedText.length > 0 else {
            return nil
        }
        
        // Calculate the size needed for the text with maximum width constraint
        let maxWidth: CGFloat = 1000 // Set a reasonable max width to prevent overly wide images
        let textSize = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        // Add padding (10 points on each side)
        let padding: CGFloat = 10
        let imageSize = CGSize(
            width: ceil(textSize.width) + (padding * 2),
            height: ceil(textSize.height) + (padding * 2)
        )
        
        // Set up graphics context
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Fill background (optional - remove if you want transparent background)
        UIColor.clear.setFill()
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        // Draw the attributed text with padding offset
        let drawingRect = CGRect(
            x: padding,
            y: padding,
            width: imageSize.width - (padding * 2),
            height: imageSize.height - (padding * 2)
        )
        
        attributedText.draw(in: drawingRect)
        
        // Get the image from context
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
//MARK: ViewModel 만드는 대신 extension으로 함수만 따로 뺌
extension DFTextView{
    
    
    
    
    
}


// PHPickerViewController를 사용하는 SwiftUI Wrapper
struct LayerPhotoPicker2: UIViewControllerRepresentable {
    @Binding var layerImages: [LayerModel]
    var screenSize: CGSize
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LayerPhotoPicker2
        
        init(_ parent: LayerPhotoPicker2) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                let newOrder = self.parent.layerImages.count + 1
                                let newLayerImage = LayerModel(image: uiImage, order: newOrder, position: CGPoint(x: self.parent.screenSize.width/2, y: self.parent.screenSize.height/3))
                                self.parent.layerImages.append(newLayerImage)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
struct DFCustomTextView: UIViewRepresentable {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel: DFTextViewModel
    
    private let displayScale: CGFloat
    @EnvironmentObject var imageModel: ImageListModel
    
    init(modiViewModel: DFModifyViewModel,
         viewModel: DFTextViewModel,
         displayScale: CGFloat) {
        self.modiViewModel = modiViewModel
        self.viewModel = viewModel
        self.displayScale = displayScale
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        
        // Center text horizontally
        textView.textAlignment = .center
        
        // Center text vertically
        textView.contentInsetAdjustmentBehavior = .automatic
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { notification in
            context.coordinator.adjustForKeyboard(notification: notification, textView: textView)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { notification in
            context.coordinator.adjustForKeyboard(notification: notification, textView: textView)
        }
        
        // iOS 18.0 이상에서 적응형 이미지 글리프 지원 설정
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        } else {
            // Fallback on earlier versions
        }
        
        updateTextViewAppearance(textView)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update text
        uiView.text = viewModel.txt
        
        // Apply real-time font color, size, and font family
        updateTextViewAppearance(uiView)
        
        // Center text vertically
        let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let topOffset = max(0, (uiView.bounds.height - size.height) / 2)
        uiView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
    }
    
    private func updateTextViewAppearance(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        
        // 기존 attributedText를 가져와서 수정
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString(string: textView.text ?? ""))
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(viewModel.fontColor),
            .font: UIFont(name: viewModel.newSelectedFont.rawValue, size: viewModel.fontSize) ?? UIFont.systemFont(ofSize: viewModel.fontSize),
            .paragraphStyle: paragraphStyle
        ]
        
        // 기존 텍스트 전체에 속성 적용 (이미지 글리프 유지)
        mutableAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttributedString.length))
        
        textView.attributedText = mutableAttributedString
        textView.typingAttributes = attributes
        
        textView.bounds.size.height = UIScreen.main.bounds.height / 4
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DFCustomTextView
        
        init(_ parent: DFCustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.viewModel.txt = textView.text
            
            // Recenter text vertically when content changes
            let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            let topOffset = max(0, (textView.bounds.height - size.height) / 2)
            textView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
        }
        
        func adjustForKeyboard(notification: Notification, textView: UITextView) {
            guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardIsShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            if keyboardIsShowing {
                let keyboardHeight = keyboardScreenEndFrame.height
                textView.contentInset = UIEdgeInsets(top: (textView.bounds.height - textView.contentSize.height) / 2,
                                                     left: 0,
                                                     bottom: keyboardHeight,
                                                     right: 0)
            } else {
                let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
                let topOffset = max(0, (textView.bounds.height - size.height) / 2)
                textView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
            }
            
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }
}
