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
            
            CustomTextView(
                modiViewModel: modiViewModel,
                viewModel: viewModel,
                displayScale: displayScale
            )
            .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        
                        /// 텍스트를 이미지로 변환
                        viewModel.renderedImage=viewModel.renderTextAsImage()
                        
                        /// 이미지와 메타데이터를 코어데이터에 저장
                        imageToCoredata()
                        
                        /// 텍스트뷰를 닫음
                        modiViewModel.showTextView = false
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
        .onAppear {
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 열기
        }
        
    }
    
}
