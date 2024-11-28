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
            HStack(spacing: 10) {
                ForEach(FontStyle.allCases, id: \.self) { fontStyle in
                    Text(fontStyle.displayName) // 한글 이름 표시
                        .font(fontStyle.applyFont(size: 18)) // 매칭된 영문 폰트 적용
                        .padding(.horizontal,15)
                        .padding(.vertical,6)
                        .foregroundColor(selectedFont == fontStyle ? .black :.white)
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
        .padding(.horizontal)
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
                            fontColor = colorChip[colorIndex]
                            withAnimation(.easeInOut(duration: 0.36)) {
                                colorNum = colorIndex
                            }
                        }
                }
            }
            .padding(.vertical)
        }
        .padding(.horizontal,20)
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
                    Image(imageForAlignment(textAlignment))
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
        .frame(height: 40)
        .frame(maxWidth:.infinity)
    }
}
