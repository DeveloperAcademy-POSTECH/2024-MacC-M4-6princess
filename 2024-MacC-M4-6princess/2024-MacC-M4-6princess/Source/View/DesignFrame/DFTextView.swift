import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    //    @FocusState var isKeyboardVisible: Bool // 키보드 상태 관리
    //    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    var body: some View {
        VStack {
            Spacer()
            //            TextEditor(text: $viewModel.txt)
            //                .padding()
            //                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
            //                .multilineTextAlignment(viewModel.textAlignment) // 동적 텍스트 정렬
            //                .foregroundColor(viewModel.fontColor)
            //                .font(viewModel.selectedFont.applyFont(size: viewModel.fontSize))
            //                .lineSpacing(5)
            //                .frame(height:UIScreen.main.bounds.height/4)
            //                .background(Color.clear) // 배경을 투명하게 설정
            //                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
            DFCustomTextView(
                modiViewModel: modiViewModel,
                viewModel: viewModel,
                //                            isKeyboardVisible: $isKeyboardVisible,
                displayScale: displayScale
            )
            .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        //TODO: 함수로 만들기
                        // viewModel.rederedImage에 텍스트 이미지 저장
                        viewModel.renderTextImage(text: viewModel.txt)
                        
                        let newImage = SubjectImage()
                        if let image = viewModel.renderedImage {
                            newImage.text = image
                            newImage.originalImage = image
                            newImage.textStyle = TextStyle(rawText: viewModel.txt, font: viewModel.selectedFont, color: viewModel.fontColor, alignment: viewModel.textAlignment)
                            ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
                            imageModel.imageList.forEach {
                                if $0.isTapped {
                                    $0.isTapped = false
                                }
                            }
                            imageModel.imageList.append(newImage)
                            modiViewModel.selectedSubject = imageModel.imageList.last
                            modiViewModel.selectedIndex = imageModel.imageList.indices.last
                            modiViewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
                        } else {
                            //TODO: 에러 처리 해야함
                            print("Image not found")
                        }
                        
                        modiViewModel.showTextView = false
                    }
                }
            }
            //                .onTapGesture {
            //                    isKeyboardVisible.toggle()
            //                }
            
            if viewModel.tab == 0 {
                fontSelector
                
            } else if viewModel.tab == 1 {
                colorSelector
            }
            
            textTabBar
            Spacer()
                .frame(height: viewModel.keyboardHeight)
        }
        .animation(.easeOut(duration: 0.3))
        .keyboardHeight($viewModel.keyboardHeight)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
        )
        .ignoresSafeArea(.keyboard)
        .onAppear {
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 열기
        }
        
    }
    
}
import SwiftUI
import UIKit

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
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        } else {
            // Fallback on earlier versions
        }
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
        // Line spacing and alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        
        // Apply font color, size, and font family from viewModel
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(viewModel.fontColor), // Font color
            .font: UIFont(name: viewModel.selectedFont.rawValue, size: viewModel.fontSize) ?? UIFont.systemFont(ofSize: viewModel.fontSize), // Font family and size
            .paragraphStyle: paragraphStyle
        ]
        
        // Apply attributes to the entire text
        let attributedString = NSAttributedString(
            string: textView.text ?? "",
            attributes: attributes
        )
        textView.attributedText = attributedString
        
        // Set typing attributes for new text input
        textView.typingAttributes = attributes
        
        // Frame
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
