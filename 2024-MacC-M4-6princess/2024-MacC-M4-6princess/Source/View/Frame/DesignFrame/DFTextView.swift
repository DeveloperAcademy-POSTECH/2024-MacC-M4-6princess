import SwiftUI

struct DFTextView: View {
    @ObservedObject var viewModel: DFModifyViewModel
    @State var txt = ""
    @State var selectedFont: FontStyle = .modern
    @State var fontSize: Double = 20
    @State var fontColor: Color = .white
    @State var renderedImage: UIImage?
    @FocusState var isKeyboardVisible: Bool // 키보드 상태 관리
    @State var tab = 0
    @State var colorNum = 0
    @State var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorChip: [Color] = ColorPreset.colorPallete
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var imageModel: ImageListModel
    
    
    var body: some View {
        VStack {
            TextEditor(text: $txt)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
                .multilineTextAlignment(textAlignment) // 동적 텍스트 정렬
                .foregroundColor(fontColor)
                .font(selectedFont.applyFont(size: fontSize))
                .lineSpacing(5)
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .gesture(tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            renderTextImage(text: txt)
                            let newImage = SubjectImage()
                            if let image = renderedImage {
                                newImage.image = image
                                newImage.originalImage = image
                                imageModel.imageList.append(newImage)
                            } else {
                                //TODO: 에러 처리 해야함
                                print("Image not found")
                            }
                            viewModel.showTextView = false
                        }
                    }
                }
                .onTapGesture {
                    isKeyboardVisible.toggle()
                }
            
            if tab == 0 {
                fontSelector
                
            } else if tab == 1 {
                colorSelector
            }
            textTabBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
            
        )
        .ignoresSafeArea(.all)
    }
}

