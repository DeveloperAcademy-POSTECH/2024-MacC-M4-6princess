//
//  DFTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//
import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification -> CGFloat? in
                guard let userInfo = notification.userInfo else { return nil }
                if let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return notification.name == UIResponder.keyboardWillHideNotification ? 0 : endFrame.height
                }
                return nil
            }
            .assign(to: \.keyboardHeight, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
struct DFTextView: View {
    @ObservedObject var viewModel: DFModifyViewModel
    @State var fullText = ""
    @State var selectedFont: FontStyle = .modern
    @State var fontSize: Double = 20
    @State var fontColor: Color = .white
    @State var renderedImage: UIImage?
    @FocusState private var isKeyboardVisible: Bool // 키보드 상태 관리
    @State var tab = 0
    @State var colorNum = 0
    @State var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorArr: [Color] = ColorPreset.colorPallete
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    @StateObject private var keyboardObserver = KeyboardObserver() // 키보드 높이 감지
    
    var body: some View {
        VStack {
            TextEditor(text: $fullText)
                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(textAlignment) // 동적 텍스트 정렬
                .foregroundColor(fontColor)
                .font(selectedFont.applyFont(size: fontSize))
                .lineSpacing(5)
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .onTapGesture {
                    isKeyboardVisible = true
                }
            
           
            if tab == 0 {
                fontSelection
                
            } else if tab == 1 {
                colorSelection
            }
            textTabBar
                .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight : 0) // 키보드 높이에 따라 탭바 위치 조정
                .animation(.easeOut(duration: 0.3), value: keyboardObserver.keyboardHeight)
//            if isKeyboardVisible {
//                Spacer(minLength: keyboardObserver.keyboardHeight)
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
        )
        .ignoresSafeArea(.all)
        .onAppear {
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 활성화
        }
    }
    
    
}
