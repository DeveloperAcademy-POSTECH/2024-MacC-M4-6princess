import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                
                DFCustomTextView(
                    viewModel: viewModel,
                    displayScale: displayScale
                )
                .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            if let window = UIApplication.shared.keyWindowInForeground,
                               let textView = window.allSubviews
                                .compactMap({ $0 as? UITextView })
                                .first(where: { $0.isFirstResponder }) {
                                viewModel.renderedImage = viewModel.captureTextView(from: textView)
                                /// 이미지와 메타데이터를 코어데이터에 저장
                                imageToCoredata()
                                modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment)
                                
                                /// 텍스트뷰를 닫음
                                modiViewModel.showTextView = false
                            }
                            
                        }
                    }
                }
                
                if viewModel.tab == 0 {
                    newFontSelector
                    
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
            
            VStack{
                Spacer()
                    .frame(height:UIScreen.main.bounds.height * 0.35)
                HStack{
                    Slider(value: $viewModel.fontSize, in: 10...40, step: 1)
                        .frame(width: 150)                      // ① 회전 전에 “길이”를 가로 폭으로 지정
                        .rotationEffect(.degrees(-90))          // ② 90도 회전
                        .frame(width: 20)                       // ③ 회전 후 “두께”를 가로(=세로) 폭으로 지정
                        .accentColor(.pointPink)

                    Spacer()
                        
                }
                Spacer()
                    
                
            }
        }
    }
    
}
import UIKit

extension UIApplication {
    /// 현재 포그라운드에 활성화된 씬의 keyWindow를 반환
    var keyWindowInForeground: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
