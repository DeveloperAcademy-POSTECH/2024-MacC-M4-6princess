//
//  DFTextEditView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/2/24.
//
import SwiftUI

struct DFTextModifyView: View {
    @ObservedObject var viewModel: DFModifyViewModel
    @Binding var style: TextStyle
    
    @State var renderedImage: UIImage?
    
    @State var tab = 0
    @State var colorNum = 0
    @State var keyboardHeight: CGFloat = 0 // 키보드 높이 상태
    
    let colorChip: [Color] = ColorPreset.colorPallete
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
            //isKeyboardVisible
                .background(Color.clear) // 배경을 투명하게 설정
                .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                .gesture(tab == 2 ? swipeAlignmentGesture : nil)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            renderTextImage(text: style.rawText)
                            let newImage = SubjectImage()
                            if let image = renderedImage {
                                newImage.text = image
                                newImage.originalImage = image
                                //                                newImage.rawText = style.rawText
                                newImage.textStyle = style
                                if let uuid = frameManager.textUUID, let index = imageModel.imageList.firstIndex(where: {$0.id == uuid}){
                                    imageModel.imageList[index] = newImage
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

extension DFTextModifyView{
    // 정렬 방향 정의
    enum SwipeDirection {
        case left, right
    }
    
    var swipeAlignmentGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 스와이프 감지
                if value.translation.width < 0 { // 왼쪽 스와이프
                    withAnimation {
                        style.alignment = computeNextAlignment(for: style.alignment, direction: .left)
                    }
                } else if value.translation.width > 0 { // 오른쪽 스와이프
                    withAnimation {
                        style.alignment = computeNextAlignment(for: style.alignment, direction: .right)
                    }
                }
            }
    }
    var fontSelector: some View {
        // 폰트 선택 ScrollView
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName) // 한글 이름 표시
                        .font(fontStyle.applyFont(size: 18)) // 매칭된 영문 폰트 적용
                        .padding(.horizontal,15)
                        .padding(.vertical,6)
                        .foregroundColor(style.font == fontStyle ? Color.black : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(style.font == fontStyle ? Color.white : Color.clear) // 선택 여부에 따라 배경색 설정
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                )
                        )
                        .onTapGesture {
                            style.font = fontStyle
                        }
                }
            }
            .padding(.horizontal,5)
            
        }
        .frame(width: 335)
        //        .padding(.horizontal)
    }
    var colorSelector: some View {
        // fontColor 선택
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<colorChip.count, id: \.self) { colorIndex in
                    Circle()
                        .frame(width: colorNum == colorIndex ? 40 : 30)
                        .foregroundColor(colorChip[colorIndex])
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1) // 흰색 테두리와 두께 설정
                        )
                        .onTapGesture {
                            style.color = colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                colorNum = colorIndex
                            }
                        }
                }
            }
            .padding(5)
        }
        .frame(width: 335)
        //        .padding(.horizontal,20)
        //        .padding(.vertical,20)
    }
    var textTabBar: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 335, height: 40)
                .background(.white)
                .cornerRadius(10)
                .opacity(0.5)
            
            HStack(spacing: 0) {
                Text("Aa")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 105, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tab == 0 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                    )
                    .onTapGesture {
                        tab = 0
                    }
                    .frame(width: 105, height: 30)
                
                Group {
                    Image("df.colorChip")
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                        .frame(width: 105, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tab == 1 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                        )
                        .onTapGesture {
                            tab = 1
                        }
                }
                .frame(width: 105, height: 30)
                
                Group {
                    Image(imageForAlignment(style.alignment))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tab == 2 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                        )
                        .onTapGesture {
                            tab = 2
                            toggleTextAlignment() // 텍스트 정렬 변경 함수 호출
                        }
                }
                .frame(width: 105, height: 30)
                
            }
            .padding()
        }
        //        .padding(.horizontal,15)
        .frame(height: 40)
        .frame(maxWidth:.infinity)
        
    }
}
extension DFTextModifyView{
    @MainActor
    func renderTextImage(text: String){
        let renderer = ImageRenderer(
            content: TextRenderView(
                style: style
            )
        )
        renderer.scale = 10
        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
            
        }
        else{
            print("render 실패")
        }
    }
    // 정렬 상태 변경 함수
    func computeNextAlignment(for current: TextAlignment, direction: SwipeDirection) -> TextAlignment {
        switch (current, direction) {
            case (.center, .left): return .leading
            case (.center, .right): return .trailing
            case (.leading, .right): return .center
            case (.trailing, .left): return .center
            case (.leading, .left): return .leading // 유지
            case (.trailing, .right): return .trailing // 유지
                //            default: return .center
        }
    }
    
    //TODO: 함수명 바꾸기
    /// 이미지명을 내어주는 함수
    func imageForAlignment(_ alignment: TextAlignment) -> String {
        switch alignment {
            case .leading:
                return "df.alignment.leading"
            case .center:
                return "df.alignment.center"
            case .trailing:
                return "df.alignment.trailing"
                
        }
    }
    
    
    func toggleTextAlignment() {
        switch style.alignment {
            case .leading:
                style.alignment = .center
            case .center:
                style.alignment = .trailing
            case .trailing:
                style.alignment = .leading
                
        }
    }
}
