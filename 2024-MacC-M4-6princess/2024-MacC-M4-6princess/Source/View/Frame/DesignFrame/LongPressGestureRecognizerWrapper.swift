//
//  LongPressGestureRecognizerWrapper.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import SwiftUI
import UIKit
// UIKit의 LongPressGestureRecognizer를 SwiftUI에 통합
struct LongPressGestureRecognizerWrapper: UIViewRepresentable {
    @Binding var isEditing: Bool // 에디팅 모드 상태를 바인딩

    // UIView 생성 및 UILongPressGestureRecognizer 추가
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress))
        view.addGestureRecognizer(gestureRecognizer) // 뷰에 제스처 연결
        view.isUserInteractionEnabled = true // 사용자 상호작용 활성화
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // UIView 업데이트 로직 (필요하지 않아 비워둠)
    }
    
    // Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(isEditing: $isEditing)
    }
    
    // UILongPressGestureRecognizer 처리를 위한 Coordinator 클래스
    class Coordinator: NSObject {
        @Binding var isEditing: Bool // 에디팅 모드 상태를 바인딩
        
        // 초기화
        init(isEditing: Binding<Bool>) {
            _isEditing = isEditing
        }
        
        // Long press 동작 처리 메서드
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                isEditing = true // 에디팅 모드 시작
            } else if gestureRecognizer.state == .ended {
                isEditing = false // 에디팅 모드 종료
            }
        }
    }
}
