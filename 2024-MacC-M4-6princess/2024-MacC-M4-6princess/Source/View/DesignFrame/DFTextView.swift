import SwiftUI

struct DFTextView: View {
    @ObservedObject var modiViewModel: DFModifyViewModel
    @ObservedObject var viewModel = DFTextViewModel()
    @EnvironmentObject var imageModel: ImageListModel
    @FocusState var isKeyboardVisible: Bool
    @Environment(\.displayScale) var displayScale
    @StateObject private var keyboardResponder = KeyboardHeightResponder()
    
    var body: some View {
        let availableHeight = UIScreen.main.bounds.height - keyboardResponder.currentHeight
        ZStack{
            VStack {
                Spacer()
                DFCustomTextView(
                    viewModel: viewModel,
                    displayScale: displayScale
                )
                .frame(width: UIScreen.main.bounds.width * 0.9, height: availableHeight * 0.6)
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
                                /// 이미지와 메타데이터를 코어데이터에 저장
                                imageToCoredata()
                                
                                modiViewModel.style = TextStyle(attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""), txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment, fontSize: viewModel.fontSize)
                                
                                /// 텍스트뷰를 닫음
                                modiViewModel.showTextView = false
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
                    minFontSize: 10,
                    maxFontSize: 60,
                    fontSize: $viewModel.fontSize
                )
                
                .padding(5)
                Spacer()
            }
        }
        .padding(.bottom, keyboardResponder.currentHeight == 0 ? 20 : keyboardResponder.currentHeight+5)
        .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
        .keyboardHeight($viewModel.keyboardHeight)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
        )
        .ignoresSafeArea(.keyboard)
        
        
        
    }
    
}
extension DFTextView{
    
    var swipeAlignmentGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 스와이프 감지
                if value.translation.width < 0 { // 왼쪽 스와이프
                    withAnimation {
                        viewModel.textAlignment = viewModel.computeNextAlignment(for: viewModel.textAlignment, direction: .left)
                    }
                } else if value.translation.width > 0 { // 오른쪽 스와이프
                    withAnimation {
                        viewModel.textAlignment = viewModel.computeNextAlignment(for: viewModel.textAlignment, direction: .right)
                    }
                }
            }
    }
    var newFontSelector: some View {
        // 폰트 선택 ScrollView
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                
                ForEach(NewFontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName) // 한글 이름 표시
                        .font(fontStyle.oldApplyFont(size: 18)) // 매칭된 영문 폰트 적용
                        .padding(.horizontal,15)
                        .padding(.vertical,6)
                        .foregroundColor(viewModel.selectedFont == fontStyle ? .black :.white)
                        .frame(maxWidth:UIScreen.main.bounds.width/3)
                        .minimumScaleFactor(0.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedFont == fontStyle ? Color.white : Color.clear) // 선택 여부에 따라 배경색 설정
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                )
                        )
                        .onTapGesture {
                            viewModel.selectedFont = fontStyle
                        }
                }
            }
            .padding(.horizontal,5)
        }
        .frame(maxWidth:.infinity)
    }
    var colorSelector: some View {
        // fontColor 선택
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewModel.colorChip.count, id: \.self) { colorIndex in
                    Circle()
                        .frame(width: viewModel.colorNum == colorIndex ? 40 : 30)
                        .foregroundColor(viewModel.colorChip[colorIndex])
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1) // 흰색 테두리와 두께 설정
                        )
                        .onTapGesture {
                            viewModel.selectedColor = viewModel.colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                viewModel.colorNum = colorIndex
                            }
                        }
                }
            }
            .padding(5)
        }
        .frame(width: 335)
    }
    
    var textTabBar: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let itemWidth = totalWidth / 3 - 10
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color.white)
                    .cornerRadius(10)
                    .opacity(0.5)
                
                HStack(spacing: 0) {
                    Text("Aa")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 0 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 0
                        }
                    
                    Image("df.colorChip")
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 1 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 1
                        }
                    
                    Image(viewModel.imageForAlignment(viewModel.textAlignment))
                        .resizable()
                        .scaledToFit()
                        .frame(width: itemWidth, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.tab == 2 ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            viewModel.tab = 2
                            viewModel.toggleTextAlignment()
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 40)
    }
    
    func imageToCoredata() {
        let newImage = SubjectImage()
        if let image = viewModel.renderedImage {
            newImage.text = image
            newImage.originalImage = image
            if let att = viewModel.attributedTxt{
                newImage.textStyle = TextStyle(attributedString: att, txt: viewModel.txt, font: viewModel.selectedFont, color: viewModel.selectedColor, alignment: viewModel.textAlignment, fontSize: viewModel.fontSize)
            }
            else{
                
            }
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
    }
}
