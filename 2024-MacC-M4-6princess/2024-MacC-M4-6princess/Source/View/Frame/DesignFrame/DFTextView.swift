//
//  DFTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//
import SwiftUI

struct DFTextView: View {
    @ObservedObject var viewModel: DFFrameModifyViewModel
    @State var fullText = ""
    @State var selectedFont: FontStyle = .modern
    @State var fontSize: Double = 20
    @State var fontColor: Color = .black
    @State var renderedImage: UIImage?
    @FocusState private var isKeyboardVisible: Bool // 키보드 상태 관리
    @State var tab = 0
    @State var colorNum = 0
    let colorArr:[Color] = ColorPreset.colorPallete
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                TextEditor(text: $fullText)
                    .focused($isKeyboardVisible) // 키보드 활성화 상태와 연결
                    .multilineTextAlignment(.center)
                    .foregroundColor(fontColor)
                    .font(selectedFont.swiftUIFont(size: fontSize))
                    .lineSpacing(5)
                    .padding()
                    .background(Color.clear) // 배경을 투명하게 설정
                    .scrollContentBackground(.hidden) // 스크롤 뷰 배경 제거
                
                Spacer()
                
                if tab == 0{
                    // 폰트 선택 ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                                Text(fontStyle.displayName) // 한글 이름 표시
                                    .font(fontStyle.swiftUIFont(size: 20)) // 매칭된 영문 폰트 적용
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedFont == fontStyle ? Color.white : Color.clear) // 선택 여부에 따라 배경색 설정
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.white, lineWidth: 1) // 흰색 테두리
                                            )
                                    )
                                    .onTapGesture {
                                        selectedFont = fontStyle
                                    }
                            }
                        }
                    }
                    .padding()
                }
                else if tab == 1{
                    /// fontColor 선택
                    ScrollView(.horizontal,showsIndicators: false) {
                        HStack {
                            ForEach(0..<colorArr.count, id: \.self) { colorIndex in
                                Circle()
                                    .frame(width: colorNum == colorIndex ? 40 : 30)
                                    .foregroundColor(colorArr[colorIndex])
                                    .onTapGesture {
                                        fontColor = colorArr[colorIndex]
                                        withAnimation(.easeInOut(duration: 0.36)) {
                                            colorNum = colorIndex
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                else{
                   
                }
                
                ZStack {
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 335, height: 40)
                      .background(.white)
                      .cornerRadius(10)
                      .opacity(0.5)
                    
                    HStack(spacing:0){
                        Text("Aa")
                            .font(.system(size: 16))
                            .foregroundColor(tab == 0 ? .black : .gray)
                            .frame(width: 105, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(tab == 0 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                            )
                            .onTapGesture {
                                tab = 0
                            }
                            .frame(width:105, height: 30)
                        Image("df.colorChip")
                            .resizable()
                            .frame(width: 27, height: 27) // 텍스트 크기에 맞춘 프레임
                            
                            .background(
                                RoundedRectangle(cornerRadius: 10)
//                                    .frame(width: 105, height: 30)
                                    .fill(tab == 1 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                            )
                            .onTapGesture {
                                tab = 1
                            }
                            .frame(width:105, height: 30)

                        Image("df.alignment")
                            .resizable()
                            .frame(width: 27, height: 27) // 텍스트 크기에 맞춘 프레임
                            .background(
                                RoundedRectangle(cornerRadius: 10)
//                                    .frame(width: 105, height: 30)
                                    .fill(tab == 2 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                            )
                            .onTapGesture {
                                tab = 2
                            }
                            .frame(width:105, height: 30)

                        
                    }
                    .padding(.vertical)
                }
                .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                .padding()
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.black.opacity(0.5) // 반투명 검정색
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        viewModel.showTextView = false
                    }
                }
            }
            .onAppear {
                // 뷰가 나타날 때 키보드 자동 활성화
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isKeyboardVisible = true
                }
            }
        }
    }
}
