//
//  DFTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//
import SwiftUI

struct DFTextView: View {
    
    @ObservedObject var viewModel: DFModifyViewModel
    @State var fullText = ""
    @State var selectedFont: FontStyle = .modern
    @State var fontSize: Double = 20
    @State var fontColor: Color = .white
    @State var renderedImage: UIImage?
    @FocusState private var isKeyboardVisible: Bool // 키보드 상태 관리
    @State var tab = 0
    @State var colorNum = 0
    @State var textAlignment: TextAlignment = .center // 텍스트 정렬 상태
    let colorArr: [Color] = ColorPreset.colorPallete
    @Environment(\.displayScale) var displayScale
    
    var body: some View {
        NavigationStack{
            VStack {
                TextEditor(text: $fullText)
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
                    .gesture(tab == 2 ? swipeGesture : nil)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("완료") {
                                viewModel.showTextView = false
                            }
                        }
                    }
                    .onTapGesture {
                        
                        isKeyboardVisible.toggle()
                    }
                
                if tab == 0 {
                    // 폰트 선택 ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                                Text(fontStyle.displayName) // 한글 이름 표시
                                    .font(fontStyle.applyFont(size: 20)) // 매칭된 영문 폰트 적용
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
                        .padding(.horizontal)
                    }
                } else if tab == 1 {
                    // fontColor 선택
                    ScrollView(.horizontal, showsIndicators: false) {
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
                            .foregroundColor(tab == 0 ? .black : .gray)
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
                            Image("df.alignment")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 105, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(tab == 2 ? Color.white : Color.clear) // 탭 상태에 따른 배경색
                                )
                                .onTapGesture {
                                    tab = 2
                                }
                        }
                        .frame(width: 105, height: 30)
                    }
                    .padding(.vertical)
                }
                .frame(height: 40)
                .frame(maxWidth:.infinity)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black.opacity(0.5) // 반투명 검정색
                
        )
        .ignoresSafeArea(.all)
        .onAppear {
            // 초기 로직 설정
        }
    }
    
   
}
