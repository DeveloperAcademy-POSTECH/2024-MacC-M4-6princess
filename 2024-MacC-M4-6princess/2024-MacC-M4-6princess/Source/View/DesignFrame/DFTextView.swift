import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
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
                        if let textView = UIApplication.shared.windows.first?.allSubviews.compactMap({ $0 as? UITextView }).first(where: { $0.isFirstResponder }) {
                            viewModel.renderedImage = viewModel.captureTextView(from: textView)
                            /// 이미지와 메타데이터를 코어데이터에 저장
                            imageToCoredata()
                            modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment)
                            
                            /// 텍스트뷰를 닫음
                            modiViewModel.showTextView = false
                        }
                        /// 텍스트를 이미지로 변환
                        //                        viewModel.renderedImage=viewModel.attributedTextToImage()
                        
                        
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
        
    }
    
}
