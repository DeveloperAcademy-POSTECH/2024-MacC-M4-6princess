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
    
    @State var keyboardHeight: CGFloat = 0 // 키보드 높이 상태
    
    var body: some View {
        VStack {
            Spacer()
            TextEditor(text: $txt)
                .padding()
                .focused($isKeyboardVisible) // 키보드 활성 상태와 연결
                .multilineTextAlignment(textAlignment) // 동적 텍스트 정렬
                .foregroundColor(fontColor)
                .font(selectedFont.applyFont(size: fontSize))
                .lineSpacing(5)
                .frame(height:UIScreen.main.bounds.height/5)
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .gesture(tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            renderTextImage(text: txt)
                            let newImage = SubjectImage()
                            if let image = renderedImage {
                                newImage.text = image
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
            Spacer()
                .frame(height: keyboardHeight)
        }
        .animation(.easeOut(duration: 0.3))
        .keyboardHeight($keyboardHeight)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
        )
        .ignoresSafeArea(.keyboard)
        .onAppear {
            isKeyboardVisible = true // 뷰가 나타날 때 키보드 열기
        }
        
    }
    
}
