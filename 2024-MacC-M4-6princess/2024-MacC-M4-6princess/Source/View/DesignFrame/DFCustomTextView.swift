
//
//  DFCustomTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//
import Foundation
import UIKit
import SwiftUI

// SwiftUI에서 UIKit의 UITextView를 사용하기 위한 래퍼 구조체 (UIViewRepresentable 프로토콜 사용)
struct CustomTextView: UIViewRepresentable {
    // 키보드가 보이는지 여부를 추적하는 상태 변수 (SwiftUI의 @FocusState 사용)
    @FocusState var isKeyboardVisible: Bool
    
    // 텍스트 수정 관련 데이터를 관리하는 뷰모델 (실시간 변화를 감지하기 위해 @ObservedObject 사용)
    @ObservedObject var modiViewModel: DFModifyViewModel
    
    // 텍스트뷰의 데이터를 관리하는 뷰모델 (폰트, 색상, 텍스트 등을 포함)
    @ObservedObject var viewModel: DFTextViewModel
    
    // 디스플레이 스케일 (화면 해상도에 맞게 크기를 조정하기 위한 값)
    private let displayScale: CGFloat
    
    // 텍스트의 폰트 크기 (기본값 20으로 설정 가능)
    let fontSize: CGFloat
    
    // 이미지 데이터를 관리하는 환경 객체 (SwiftUI의 @EnvironmentObject로 주입)
    @EnvironmentObject var imageModel: ImageListModel
    
    // 초기화 메서드: 필요한 뷰모델과 설정값을 전달받아 인스턴스 생성
    init(modiViewModel: DFModifyViewModel,
         viewModel: DFTextViewModel,
         displayScale: CGFloat, fontSize: CGFloat = 20) {
        self.modiViewModel = modiViewModel
        self.viewModel = viewModel
        self.displayScale = displayScale
        self.fontSize = fontSize
    }
    
    // UIKit의 UITextView를 처음 생성하는 메서드 (SwiftUI에서 호출됨)
    func makeUIView(context: Context) -> UITextView {
        // UITextView 객체 생성 (텍스트를 입력하고 표시할 수 있는 UIKit 컴포넌트)
        let textView = UITextView()
        
        // viewModel.attributedTxt로 초기화 (속성 텍스트: 폰트, 색상 등이 포함된 텍스트)
        textView.attributedText = viewModel.attributedTxt
        
        // 폰트 설정: viewModel에서 선택된 폰트를 지정된 크기로 적용
        let font = viewModel.newSelectedFont.applyFont(size: fontSize)
        textView.font = font
        
        // 텍스트 정렬과 색상 설정
        textView.textAlignment = NSTextAlignment(viewModel.textAlignment) // 텍스트 정렬 (왼쪽, 가운데, 오른쪽 등)
        textView.textColor = UIColor(color: viewModel.fontColor) // 텍스트 색상
        textView.backgroundColor = .clear // 배경 투명하게 설정
        textView.delegate = context.coordinator // 텍스트뷰의 이벤트를 Coordinator에서 처리하도록 설정
        textView.isScrollEnabled = true // 텍스트가 길어지면 스크롤 가능
        textView.keyboardDismissMode = .interactive // 키보드 내릴 때 인터랙티브하게 설정
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 수평 압축 저항 낮게 설정 (레이아웃 유연성)
        
        // iOS 18 이상에서만 사용 가능한 기능 (적응형 이미지 글리프 지원)
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        // 키보드가 나타나거나 사라질 때 알림 추가 (Coordinator에서 처리)
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.keyboardWillShow(_:)), // 키보드 나타날 때 호출
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.keyboardWillHide(_:)), // 키보드 사라질 때 호출
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 텍스트를 수직 중앙에 맞추기 (Coordinator에서 계산)
        context.coordinator.centerTextVertically(in: textView)
        
        return textView // 생성된 UITextView 반환
    }
    
    // 뷰가 업데이트될 때 호출되는 메서드 (SwiftUI 상태 변화 반영)
    func updateUIView(_ uiView: UITextView, context: Context) {
        // attributedText가 변경되었는지 확인 후 업데이트
        if uiView.attributedText != viewModel.attributedTxt {
            uiView.attributedText = viewModel.attributedTxt // 최신 속성 텍스트 적용
            context.coordinator.centerTextVertically(in: uiView) // 텍스트 수직 중앙 정렬
        }
        
        // 폰트, 정렬, 색상 속성 업데이트
        let font = viewModel.newSelectedFont.applyFont(size: fontSize)
        uiView.font = font // 폰트 설정
        uiView.textAlignment = NSTextAlignment(viewModel.textAlignment) // 텍스트 정렬
        uiView.textColor = UIColor(color: viewModel.fontColor) // 텍스트 색상
    }
    
    // Coordinator 객체 생성 (UITextView와 SwiftUI 간의 상호작용 관리)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator 클래스: UITextView의 이벤트와 동작을 처리
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView // 부모 CustomTextView 참조
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        // 텍스트가 변경될 때 호출 (사용자가 입력하거나 삭제할 때)
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async { // UI 업데이트는 메인 스레드에서 실행
                self.parent.viewModel.txt = textView.text // 일반 텍스트 저장
                self.parent.viewModel.attributedTxt = textView.attributedText // 속성 텍스트 저장
                textView.textColor = UIColor(color: self.parent.viewModel.fontColor) 
                self.centerTextVertically(in: textView) // 텍스트 수직 중앙 정렬
                
            }
        }
        
        // 편집 시작 시 호출 (텍스트뷰에 포커스가 갈 때)
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = true // 키보드 상태 업데이트
            }
        }
        
        // 편집 종료 시 호출 (포커스가 해제될 때)
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isKeyboardVisible = false // 키보드 상태 업데이트
            }
        }
        
        // 텍스트를 수직으로 중앙에 맞추는 메서드
        func centerTextVertically(in textView: UITextView) {
            let size = textView.bounds.size // 텍스트뷰의 크기
            let contentSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)) // 텍스트의 실제 크기
            let topInset = max(0, (size.height - contentSize.height) / 2) // 위쪽 여백 계산
            textView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: topInset, right: 0) // 여백 적용
        }
        
        // 키보드가 나타날 때 호출 (알림 처리)
        @objc func keyboardWillShow(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            let keyboardHeight = keyboardFrame.height // 키보드 높이
            if let textView = parent.focusedTextView() { // 현재 포커스된 텍스트뷰 찾기
                let adjustedHeight = textView.bounds.height - keyboardHeight // 키보드 높이만큼 조정된 높이
                let contentSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
                let topInset = max(0, (adjustedHeight - contentSize.height) / 2) // 위쪽 여백 계산
                textView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: keyboardHeight, right: 0) // 키보드 고려한 여백 설정
            }
        }
        
        // 키보드가 사라질 때 호출 (알림 처리)
        @objc func keyboardWillHide(_ notification: Notification) {
            if let textView = parent.focusedTextView() {
                centerTextVertically(in: textView) // 기본 중앙 정렬 복원
            }
        }
        
        // 메모리 해제 시 알림 제거
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// CustomTextView 확장: 추가 유틸리티 메서드
extension CustomTextView {
    // 현재 포커스된 UITextView를 찾는 메서드
    func focusedTextView() -> UITextView? {
        UIApplication.shared.windows.first?.allSubviews.compactMap { $0 as? UITextView }.first { $0.isFirstResponder }
    }
}

// UIView 확장: 모든 하위 뷰를 재귀적으로 가져오기
extension UIView {
    var allSubviews: [UIView] {
        return subviews.flatMap { [$0] + $0.allSubviews }
    }
}
//생성하면 색상,정렬,폰트 적용안됨 -> 뷰모델엔 저장되어있는데도 말이죠
// 수정할 때 뒤늦게 되는 것을 보아 렌더링의 문제같음
// 가로 채워지면 줄바꿈 되게하기

