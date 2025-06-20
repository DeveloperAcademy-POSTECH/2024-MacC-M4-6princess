
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
struct DFCustomTextView: UIViewRepresentable {
    // 키보드가 보이는지 여부를 추적하는 상태 변수 (SwiftUI의 @FocusState 사용)
    @FocusState var isKeyboardVisible: Bool
    // 텍스트뷰의 데이터를 관리하는 뷰모델 (폰트, 색상, 텍스트 등을 포함)
    @ObservedObject var viewModel: DFTextViewModel
    // 디스플레이 스케일 (화면 해상도에 맞게 크기를 조정하기 위한 값)
    private let displayScale: CGFloat
    // 텍스트의 폰트 크기 (기본값 20으로 설정 가능)
    //    let fontSize: CGFloat
    // 이미지 데이터를 관리하는 환경 객체 (SwiftUI의 @EnvironmentObject로 주입)
    @EnvironmentObject var imageModel: ImageListModel
    
    // 초기화 메서드: 필요한 뷰모델과 설정값을 전달받아 인스턴스 생성
    init(
        viewModel: DFTextViewModel,
        displayScale: CGFloat, fontSize: CGFloat = 20) {
            self.viewModel = viewModel
            self.displayScale = displayScale
            
        }
    
    // UIKit의 UITextView를 처음 생성하는 메서드 (SwiftUI에서 호출됨)
    func makeUIView(context: Context) -> UITextView {
        // UITextView 객체 생성 (텍스트를 입력하고 표시할 수 있는 UIKit 컴포넌트)
        let textView = VerticallyCenteredTextView()
        // 키보드가 바로 올라오도록 설정
        DispatchQueue.main.async {
            textView.becomeFirstResponder()
        }
        // viewModel.attributedTxt로 초기화 (속성 텍스트: 폰트, 색상 등이 포함된 텍스트)
        textView.attributedText = viewModel.attributedTxt
        
        // 폰트 설정: viewModel에서 선택된 폰트를 지정된 크기로 적용
        let font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        textView.font = font
        
        // 텍스트 정렬과 색상 설정
        textView.textAlignment = NSTextAlignment(viewModel.textAlignment) // 텍스트 정렬 (왼쪽, 가운데, 오른쪽 등)
        textView.textColor = UIColor(color: viewModel.selectedColor) // 텍스트 색상
        textView.backgroundColor = .clear // 배경 투명하게 설정
        textView.delegate = context.coordinator // 텍스트뷰의 이벤트를 Coordinator에서 처리하도록 설정
        textView.isScrollEnabled = true // 텍스트가 길어지면 스크롤 가능
        
        // iOS 18 이상에서만 사용 가능한 기능 (적응형 이미지 글리프 지원)
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        return textView // 생성된 UITextView 반환
    }
    
    // 뷰가 업데이트될 때 호출되는 메서드 (SwiftUI 상태 변화 반영)
    func updateUIView(_ uiView: UITextView, context: Context) {
        // attributedText가 변경되었는지 확인 후 업데이트
        
        uiView.attributedText = viewModel.attributedTxt // 최신 속성 텍스트 적용
        // 폰트, 정렬, 색상 속성 업데이트
        let font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        uiView.font = font // 폰트 설정
        uiView.textAlignment = NSTextAlignment(viewModel.textAlignment) // 텍스트 정렬
        uiView.textColor = UIColor(color: viewModel.selectedColor) // 텍스트 색상
        
        // 레이아웃 갱신을 강제
        uiView.setNeedsLayout()
    }
    
    // Coordinator 객체 생성 (UITextView와 SwiftUI 간의 상호작용 관리)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func centerVertically(_ textView: UITextView) {
        let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        let contentHeight = textView.sizeThatFits(fittingSize).height
        let textViewHeight = textView.bounds.height
        
        let topInset = max((textViewHeight - contentHeight) / 2, 0)
        textView.contentInset.top = topInset
        textView.contentInset.bottom = 0 // 아래 인셋은 보통 0으로
    }
    
    // Coordinator 클래스: UITextView의 이벤트와 동작을 처리
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DFCustomTextView // 부모 CustomTextView 참조
        
        init(_ parent: DFCustomTextView) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async { // UI 업데이트는 메인 스레드에서
                // 일반 텍스트와 속성 텍스트 저장
                self.parent.viewModel.txt = textView.text
                self.parent.viewModel.attributedTxt = textView.attributedText
                
                // 텍스트 색상 적용
                textView.textColor = UIColor(color: self.parent.viewModel.selectedColor)
                
                
                // 캡처할 크기 계산 및 저장
                let contentSize = textView.sizeThatFits(CGSize(
                    width: textView.bounds.width, // 현재 텍스트뷰 너비 기준
                    height: CGFloat.greatestFiniteMagnitude // 최대 높이로 계산
                ))
                self.parent.viewModel.captureSize = contentSize // viewModel에 저장
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
        
        
        // 메모리 해제 시 알림 제거
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
}

// CustomTextView 확장: 추가 유틸리티 메서드
extension DFCustomTextView {
    // 현재 포커스된 UITextView를 찾는 메서드
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

// UIView 확장: 모든 하위 뷰를 재귀적으로 가져오기
extension UIView {
    var allSubviews: [UIView] {
        return subviews.flatMap { [$0] + $0.allSubviews }
    }
}
class VerticallyCenteredTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 편집 중일 때는 중앙 정렬 해제 (흔들림 방지)
        guard !isFirstResponder else {
            textContainerInset.top = 0
            return
        }
        
        // contentSize.height: 실제 텍스트 전체 높이
        let contentHeight = contentSize.height
        let containerHeight = bounds.height
        
        // 차이가 양수일 때만 중앙 정렬, 소수점 이하 버림 처리
        let diff = containerHeight - contentHeight
        let top = diff > 0
        ? floor(diff / 2)
        : 0
        
        textContainerInset = UIEdgeInsets(
            top: top,
            left: textContainerInset.left,
            bottom: 0,
            right: textContainerInset.right
        )
    }
}
