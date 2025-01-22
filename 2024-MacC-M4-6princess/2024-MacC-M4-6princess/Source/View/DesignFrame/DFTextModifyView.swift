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
            TextEditor(text: $style.rawText)
                .padding()
                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
                .multilineTextAlignment(style.alignment) // 동적 텍스트 정렬
                .foregroundColor(style.color)
                .font(style.font.applyFont(size: 20))
                .lineSpacing(5)
                .frame(height:UIScreen.main.bounds.height/4)
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            viewModel.renderTextImage(text: style.rawText,style: style)
                            let newImage = SubjectImage()
                            if let image = viewModel.renderedImage {
                                newImage.text = image
                                newImage.originalImage = image
                                //                                newImage.rawText = style.rawText
                                newImage.textStyle = style
                                if let uuid = frameManager.textUUID, let index = imageModel.imageList.firstIndex(where: {$0.id == uuid}){
                                    imageModel.imageList[index] = newImage
                                    modiViewModel.selectedIndex = index
                                    modiViewModel.selectedSubject = newImage
                                    modiViewModel.modelListControl(subject: imageModel.imageList[index])
                                }
                                else{
                                    /// 에러처리
                                    ///
                                }
                                ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
                                imageModel.imageList.forEach {
                                    if $0.isTapped {
                                        $0.isTapped = false
                                    }
                                }
                            } else {
                                //TODO: 에러 처리 해야함
                                print("Image not found")
                            }
                            frameManager.showTextModifyView = false
                        }
                    }
                }
                .onTapGesture {
                    isKeyboardVisible.toggle()
                }
            
            if viewModel.tab == 0 {
                fontSelector
                
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


