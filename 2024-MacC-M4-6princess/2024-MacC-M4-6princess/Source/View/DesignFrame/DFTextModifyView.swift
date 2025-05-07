//
//  DFTextEditView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/2/24.
//
import SwiftUI

struct DFTextModifyView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
//    @Binding var style: TextStyle // viewModel로 전달을 해야할까?
    @ObservedObject var viewModel = DFTextViewModel()
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var frameManager: FrameManager
    @FocusState var isKeyboardVisible: Bool // 키보드 상태 관리
    
    var body: some View {
        VStack {
            Spacer()
            DFCustomTextView(
                //                modiViewModel: modiViewModel,
                viewModel: viewModel,
                displayScale: displayScale
            )
            .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        
                        /// 텍스트를 이미지로 변환
                        if let textView = UIApplication.shared.windows.first?.allSubviews.compactMap({ $0 as? UITextView }).first(where: { $0.isFirstResponder }) {
                            viewModel.captureTextView(from: textView)
//                            modiViewModel.style.attributedString = viewModel.attributedTxt ?? NSAttributedString(string: "")
//                            modiViewModel.style.txt =  viewModel.txt
//                            modiViewModel.style.color = viewModel.selectedColor
//                            modiViewModel.style.font = viewModel.selectedFont
//                            modiViewModel.style.alignment = viewModel.textAlignment
//
                            modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment)
                            //                        TextStyle(attributedString: viewModel.attributedTxt!, txt: viewModel.txt, font: viewModel.newSelectedFont, color: viewModel.fontColor, alignment: viewModel.textAlignment)
                            /// 이미지와 메타데이터를 코어데이터에 저장
                            imageToCoredata()
                            
                            /// 텍스트뷰를 닫음
                            frameManager.showTextModifyView = false
                        }
                        
                    }
                }
            }
//            .onAppear{
//                viewModel.attributedTxt = style.attributedString
//                viewModel.txt = style.txt
//                viewModel.selectedColor = style.color
//                viewModel.selectedFont = style.font
//                viewModel.textAlignment = style.alignment
//                print("모디텍스트:\(viewModel.txt)")
//            }
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
            viewModel.attributedTxt = modiViewModel.style.attributedString
            viewModel.txt = modiViewModel.style.txt
            viewModel.selectedColor = modiViewModel.style.color
            viewModel.selectedFont = modiViewModel.style.font
            viewModel.textAlignment = modiViewModel.style.alignment
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 열기
        }
        
    }
    
}


