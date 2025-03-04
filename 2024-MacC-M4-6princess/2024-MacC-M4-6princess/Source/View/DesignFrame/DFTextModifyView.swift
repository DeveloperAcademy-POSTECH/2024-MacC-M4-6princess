//
//  DFTextEditView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/2/24.
//
import SwiftUI

struct DFTextModifyView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @Binding var style: TextStyle // viewModel로 전달을 해야할까?
    @StateObject var viewModel = DFTextViewModel()
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var frameManager: FrameManager
    @FocusState var isKeyboardVisible: Bool // 키보드 상태 관리
    
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
                        viewModel.renderedImage=viewModel.attributedTextToImage()
                        
                        style.attributedString = viewModel.attributedTxt ?? NSAttributedString(string: "")
                        style.txt =  viewModel.txt
                        style.font = viewModel.newSelectedFont
                        style.alignment = viewModel.textAlignment
                        
                        //                        TextStyle(attributedString: viewModel.attributedTxt!, txt: viewModel.txt, font: viewModel.newSelectedFont, color: viewModel.fontColor, alignment: viewModel.textAlignment)
                        /// 이미지와 메타데이터를 코어데이터에 저장
                        imageToCoredata()
                        
                        /// 텍스트뷰를 닫음
                        frameManager.showTextModifyView = false
                    }
                }
            }
            .onAppear{
                viewModel.attributedTxt = style.attributedString
                viewModel.txt = style.txt
                viewModel.fontColor = style.color
                viewModel.newSelectedFont = style.font
                viewModel.textAlignment = style.alignment
                print("모디텍스트:\(viewModel.txt)")
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


