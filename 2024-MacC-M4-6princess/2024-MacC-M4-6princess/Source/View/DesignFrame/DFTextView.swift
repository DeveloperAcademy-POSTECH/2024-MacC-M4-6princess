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
                        //TODO: 함수로 만들기
                        // viewModel.rederedImage에 텍스트 이미지 저장
//                        viewModel.renderTextImage(text: viewModel.txt)
                        viewModel.renderedImage=viewModel.renderTextAsImage()
//                        print(viewModel.txt)
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
                            modiViewModel.selectedSubject = imageModel.imageList.last
                            modiViewModel.selectedIndex = imageModel.imageList.indices.last
                            modiViewModel.modelListControl(subject: imageModel.imageList[imageModel.imageList.count-1])
                        } else {
                            //TODO: 에러 처리 해야함
                            print("Image not found")
                        }
                        
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
