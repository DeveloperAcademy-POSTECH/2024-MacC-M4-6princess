//import SwiftUI
//
//struct DFTextView: View {
//    @ObservedObject var modiViewModel: DFModifyViewModel
//    @ObservedObject var viewModel = DFTextViewModel()
//    @EnvironmentObject var imageModel: ImageListModel
//    @FocusState var isKeyboardVisible: Bool
//    @Environment(\.displayScale) var displayScale
//    @StateObject private var keyboardResponder = KeyboardHeightResponder()
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let availableHeight = geometry.size.height - keyboardResponder.currentHeight
//            
//            ZStack {
//                // 메인 컨텐츠
//                VStack(spacing: 0) {
//                    // 키보드 위 여유 공간 계산
//                    let contentHeight = availableHeight - bottomControlsHeight
//                    
//                    // 텍스트뷰를 중앙에 배치
//                    Spacer()
//                        .frame(height: max(0, contentHeight * 0.5 - textViewHeight * 0.5))
//                    
//                    DFCustomTextView(
//                        viewModel: viewModel,
//                        displayScale: displayScale
//                    )
//                    .frame(width: UIScreen.main.bounds.width * 0.9, height: textViewHeight)
//                    .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
//                    
//                    Spacer()
//                        .frame(height: max(0, contentHeight * 0.5 - textViewHeight * 0.5))
//                    
//                    // 하단 컨트롤
//                    VStack(spacing: 0) {
//                        if viewModel.tab == 0 {
//                            newFontSelector
//                                .padding(.horizontal, 10)
//                        } else if viewModel.tab == 1 {
//                            colorSelector
//                                .padding(.horizontal, 10)
//                        }
//                        textTabBar
//                            .padding(.horizontal, 10)
//                            .padding(.bottom, 20)
//                    }
//                }
//                
//                // 슬라이더 - 키보드 위 공간의 세로 중앙에 배치
//                VStack {
//                    Spacer()
//                    
//                    HStack(alignment: .center) {
//                        TextSizeSliderView(
//                            barSize: CGSize(width: 16, height: sliderHeight),
//                            minFontSize: 10,
//                            maxFontSize: 60,
//                            fontSize: $viewModel.fontSize
//                        )
//                        .padding(.leading, 5)
//                        
//                        Spacer()
//                    }
//                    
//                    Spacer()
//                }
//                .padding(.bottom, keyboardResponder.currentHeight + bottomControlsHeight)
//            }
//        }
//        .background(Color.black.opacity(0.5))
//        .ignoresSafeArea(.keyboard)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("완료") {
//                    handleCompletion()
//                }
//            }
//        }
//        .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var textViewHeight: CGFloat {
//        min(300, UIScreen.main.bounds.height * 0.4)
//    }
//    
//    private var sliderHeight: CGFloat {
//        200
//    }
//    
//    private var bottomControlsHeight: CGFloat {
//        // 탭바 + 폰트/컬러 셀렉터 높이 추정
//        viewModel.tab == 0 || viewModel.tab == 1 ? 150 : 70
//    }
//    
//    // MARK: - Private Methods
//    
//    private func handleCompletion() {
//        if let window = UIApplication.shared.keyWindowInForeground,
//           let textView = window.allSubviews
//            .compactMap({ $0 as? UITextView })
//            .first(where: { $0.isFirstResponder }) {
//            viewModel.captureTextView(from: textView)
//            imageToCoredata()
//            
//            modiViewModel.style = TextStyle(
//                attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""),
//                txt: viewModel.txt,
//                font: viewModel.selectedFont,
//                color: viewModel.selectedColor,
//                alignment: viewModel.textAlignment,
//                fontSize: viewModel.fontSize
//            )
//            
//            modiViewModel.showTextView = false
//        }
//    }
//}
