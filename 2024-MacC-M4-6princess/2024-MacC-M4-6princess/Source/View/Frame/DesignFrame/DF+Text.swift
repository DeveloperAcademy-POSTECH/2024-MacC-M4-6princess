//
//  DF+Text.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//

import Foundation
import SwiftUI

extension DFTextView{
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
                        textAlignment = computeNextAlignment(for: textAlignment, direction: .left)
                    }
                } else if value.translation.width > 0 { // 오른쪽 스와이프
                    withAnimation {
                        textAlignment = computeNextAlignment(for: textAlignment, direction: .right)
                    }
                }
            }
    }
    var fontSelector: some View {
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
    }
    var colorSelector: some View {
        // fontColor 선택
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<colorChip.count, id: \.self) { colorIndex in
                    Circle()
                        .frame(width: colorNum == colorIndex ? 40 : 30)
                        .foregroundColor(colorChip[colorIndex])
                        .onTapGesture {
                            fontColor = colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                colorNum = colorIndex
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
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

struct TextRenderView: View {
    let text: String
    let selectedFont: FontStyle
    let selectedColor: Color
    let selectedAlignment: TextAlignment
    
    var body: some View {
        Text(text)
            .font(selectedFont.applyFont(size: 20))
            .foregroundColor(selectedColor)
            .multilineTextAlignment(selectedAlignment)
            .lineSpacing(5)
        
    }
}
