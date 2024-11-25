//
//  DF+Keyboard.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/25/24.
//

import Foundation
import SwiftUI

struct KeyboardProvider : ViewModifier {
    
    //키보드 높이값
    var keyboardHeight: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
        //키보드 올라가기 직전 노티를 받으면 나오는 객체
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                //키보드 높이값 . 바인딩 원본 객체 연결 -> 전달
                self.keyboardHeight.wrappedValue = keyboardRect.height
                
            })
        //키보드 닫기 전 보내는 노티 받으면 실행
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                       perform: { _ in
                //키보드 높이값 0으로 변경
                self.keyboardHeight.wrappedValue = 0
            })
    }
}

public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
