import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    @StateObject private var keyboardResponder = KeyboardHeightResponder()
    
    var body: some View {
        let availableHeight = UIScreen.main.bounds.height - keyboardResponder.currentHeight
        ZStack{
            VStack {
                Spacer()
                DFCustomTextView(
                    viewModel: viewModel,
                    displayScale: displayScale
                )
                .frame(width: UIScreen.main.bounds.width * 0.8, height: availableHeight * 0.5)
                .position(x: UIScreen.main.bounds.width / 2, y: availableHeight / 2)
                .animation(.easeInOut, value: keyboardResponder.currentHeight)
                .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            if let window = UIApplication.shared.keyWindowInForeground,
                               let textView = window.allSubviews
                                .compactMap({ $0 as? UITextView })
                                .first(where: { $0.isFirstResponder }) {
                                viewModel.captureTextView(from: textView)
                                /// 이미지와 메타데이터를 코어데이터에 저장
                                imageToCoredata()
                                
                                modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment)
                                
                                /// 텍스트뷰를 닫음
                                modiViewModel.showTextView = false
                            }
                            
                        }
                    }
                }
                VStack{
                    if viewModel.tab == 0 {
                        newFontSelector
                            .padding(.horizontal,10)
                        
                    } else if viewModel.tab == 1 {
                        colorSelector
                            .padding(.horizontal,10)
                    }
                    textTabBar
                        .padding(.horizontal,10)
                }
                .padding(.bottom, keyboardResponder.currentHeight == 0 ? 20 : keyboardResponder.currentHeight+5)
            }
            .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
            .keyboardHeight($viewModel.keyboardHeight)
            .background(
                Color.black.opacity(0.5) // 반투명 검정색
            )
            .ignoresSafeArea(.keyboard)
            
//            VStack{
//                Spacer()
//                    .frame(height:UIScreen.main.bounds.height * 0.35)
//                HStack{
//                    Slider(value: $viewModel.fontSize, in: 10...40, step: 1)
//                        .frame(width: 150)                      // ① 회전 전에 “길이”를 가로 폭으로 지정
//                        .rotationEffect(.degrees(-90))          // ② 90도 회전
//                        .frame(width: 20)                       // ③ 회전 후 “두께”를 가로(=세로) 폭으로 지정
//                        .accentColor(.pointPink)
//                    
//                    Spacer()
//                }
//                Spacer()
//            }
        }
    }
    
}
