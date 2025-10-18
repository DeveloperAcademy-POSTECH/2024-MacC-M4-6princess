//
//  DFTextEditView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/2/24.
//

import SwiftUI
struct DFTextModifyView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    @StateObject private var keyboardResponder = KeyboardHeightResponder()
    @EnvironmentObject var frameManager: FrameManager
    
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
                                
                                modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment, fontSize: viewModel.fontSize)
                                
                                /// 이미지와 메타데이터를 코어데이터에 저장
                                imageToCoredata()
                                
                                /// 텍스트뷰를 닫음
                                frameManager.showTextModifyView = false
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
                
            }
            HStack{
                TextSizeSliderView(
                    barSize: CGSize(width: 16, height: 200),
                    minFontSize: 20,
                    maxFontSize: 60,
                    fontSize: $viewModel.fontSize
                )
                
                .padding(5)
                Spacer()
            }
            
        }
        .padding(.bottom, keyboardResponder.currentHeight == 0 ? 20 : keyboardResponder.currentHeight+5)
        .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
        )
        .ignoresSafeArea(.keyboard)
        .onAppear {
            viewModel.attributedTxt = modiViewModel.style.attributedString
            viewModel.txt = modiViewModel.style.txt
            viewModel.selectedColor = modiViewModel.style.color
            viewModel.selectedFont = modiViewModel.style.font
            viewModel.textAlignment = modiViewModel.style.alignment
            viewModel.fontSize = modiViewModel.style.fontSize
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 열기
        }
    }
    
}
