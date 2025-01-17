import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @FocusState var isKeyboardVisible: Bool // 키보드 상태 관리
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    
    var body: some View {
        VStack {
            Spacer()
            TextEditor(text: $viewModel.txt)
                .padding()
                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
                .multilineTextAlignment(viewModel.textAlignment) // 동적 텍스트 정렬
                .foregroundColor(viewModel.fontColor)
                .font(viewModel.selectedFont.applyFont(size: viewModel.fontSize))
                .lineSpacing(5)
                .frame(height:UIScreen.main.bounds.height/4)
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .gesture(viewModel.tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            //TODO: 함수로 만들기
                            // viewModel.rederedImage에 텍스트 이미지 저장
                            viewModel.renderTextImage(text: viewModel.txt)
                            
                            let newImage = SubjectImage()
                            if let image = viewModel.renderedImage {
                                newImage.text = image
                                newImage.originalImage = image
                                newImage.textStyle = TextStyle(rawText: viewModel.txt, font: viewModel.selectedFont, color: viewModel.fontColor, alignment: viewModel.textAlignment)
                                ///새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제합니다.
                                imageModel.imageList.forEach {
                                    if $0.isTapped {
                                        $0.isTapped = false
                                    }
                                }
                                imageModel.imageList.append(newImage)
                                modiViewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
                            } else {
                                //TODO: 에러 처리 해야함
                                print("Image not found")
                            }
                            
                            modiViewModel.showTextView = false
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
