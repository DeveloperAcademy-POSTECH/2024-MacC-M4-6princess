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
            CustomTextView(text: $viewModel.txt)
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
//            DFCustomTextView(
//                            modiViewModel: modiViewModel,
//                            viewModel: viewModel,
////                            isKeyboardVisible: $isKeyboardVisible,
//                            displayScale: displayScale
//                        )
//                .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("완료") {
//                            //TODO: 함수로 만들기
//                            // viewModel.rederedImage에 텍스트 이미지 저장
//                            viewModel.renderTextImage(text: viewModel.txt)
//
//                            let newImage = SubjectImage()
//                            if let image = viewModel.renderedImage {
//                                newImage.text = image
//                                newImage.originalImage = image
//                                newImage.textStyle = TextStyle(rawText: viewModel.txt, font: viewModel.selectedFont, color: viewModel.fontColor, alignment: viewModel.textAlignment)
//                                ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
//                                imageModel.imageList.forEach {
//                                    if $0.isTapped {
//                                        $0.isTapped = false
//                                    }
//                                }
//                                imageModel.imageList.append(newImage)
//                                modiViewModel.selectedSubject = imageModel.imageList.last
//                                modiViewModel.selectedIndex = imageModel.imageList.indices.last
//                                modiViewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
//                            } else {
//                                //TODO: 에러 처리 해야함
//                                print("Image not found")
//                            }
//
//                            modiViewModel.showTextView = false
//                        }
//                    }
//                }
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
//    @Binding var isKeyboardVisible: Bool
    
    private let displayScale: CGFloat
    @EnvironmentObject var imageModel: ImageListModel
    
    init(modiViewModel: DFModifyViewModel,
         viewModel: DFTextViewModel,
//         isKeyboardVisible: Binding<Bool>,
         displayScale: CGFloat) {
        self.modiViewModel = modiViewModel
        self.viewModel = viewModel
//        self._isKeyboardVisible = isKeyboardVisible
        self.displayScale = displayScale
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        
        // Configure initial appearance
        updateTextViewAppearance(textView)
        
        // Add tap gesture
//        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
//        textView.addGestureRecognizer(tap)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update text
        uiView.text = viewModel.txt
        
        // Update appearance
        updateTextViewAppearance(uiView)
//
//        // Keyboard visibility
//        if isKeyboardVisible && !uiView.isFirstResponder {
//            uiView.becomeFirstResponder()
//        } else if !isKeyboardVisible && uiView.isFirstResponder {
//            uiView.resignFirstResponder()
//        }
    }
    
    private func updateTextViewAppearance(_ textView: UITextView) {
        // Font and size
//        textView.font = viewModel.selectedFont.uiFont(withSize: viewModel.fontSize)
//
//        // Text color
//        textView.textColor = UIColor(viewModel.fontColor)
//
//        // Text alignment
//        textView.textAlignment = viewModel.textAlignment.uiTextAlignment
//
        // Line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]
        textView.typingAttributes = attributes
        
        // Frame
        textView.bounds.size.height = UIScreen.main.bounds.height/4
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
        }
        
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            parent.isKeyboardVisible = true
//        }
//
//        func textViewDidEndEditing(_ textView: UITextView) {
//            parent.isKeyboardVisible = false
//        }
//
//        @objc func handleTap() {
//            parent.isKeyboardVisible.toggle()
//        }
    }
}

import SwiftUI

// UIViewRepresentable을 사용하여 UIKit의 UITextView를 SwiftUI에서 사용할 수 있도록 래핑한 뷰
struct CustomTextView: UIViewRepresentable {
    // 외부에서 바인딩할 수 있는 텍스트 값
    @Binding var text: String
    // 키보드가 보이는지 여부를 추적하는 @FocusState 프로퍼티
    @FocusState var isKeyboardVisible: Bool

    // UITextView 생성 및 초기 설정
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18) // 폰트 크기 설정
        textView.backgroundColor = .clear // 배경색 투명 설정
        textView.delegate = context.coordinator // UITextViewDelegate 설정
        textView.isScrollEnabled = true // 스크롤 가능하도록 설정
        textView.keyboardDismissMode = .interactive // 스크롤 시 키보드 내리기 가능
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 가로 방향에서 낮은 압축 저항 우선순위 설정

        // iOS 18 이상에서 Adaptive Image Glyph 기능 지원 활성화
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        } else {
            // 이전 버전에서는 해당 기능을 사용하지 않음
        }
        return textView
    }

    // SwiftUI의 state가 변경될 때 UITextView 업데이트
    func updateUIView(_ uiView: UITextView, context: Context) {
        // 현재 UITextView의 내용이 SwiftUI의 text와 다르면 업데이트
        if uiView.text != text {
            uiView.text = text
        }
    }

    // UITextView의 이벤트를 처리할 Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // UITextView의 델리게이트를 처리하는 Coordinator 클래스
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        // 사용자가 텍스트를 입력할 때 호출되는 메서드
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text // SwiftUI의 text 값 업데이트
            }
        }

        // 텍스트 입력을 시작할 때 호출되는 메서드
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = true // 키보드가 표시됨
            }
        }

        // 텍스트 입력을 끝낼 때 호출되는 메서드
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = false // 키보드가 사라짐
            }
        }
    }
}
