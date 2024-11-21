//
//  DFTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/21/24.
//

import SwiftUI
enum FontStyle: String {
    case modern = "HelveticaNeue"
    case handwriting = "SnellRoundhand"
    case bold = "Bold" // 시스템 기본 볼드체
    
    var displayName: String {
        switch self {
            case .modern:
                return "모던체"
            case .handwriting:
                return "손글씨체"
            case .bold:
                return "볼드체"
        }
    }
}

extension FontStyle: CaseIterable {
    func swiftUIFont(size: CGFloat) -> Font {
        switch self {
        case .modern:
            return .system(size: size, weight: .regular) // 시스템 폰트
        case .handwriting:
            return .custom("Helvetica", size: size) // 헬베티카 폰트
        case .bold:
            return .system(size: size, weight: .bold) // 시스템 기본 볼드체
        }
    }
}


struct DFTextView: View {
    @ObservedObject var viewModel:DFFrameModifyViewModel
    @State var selectedFont: FontStyle = .modern
    @State var fontSize:Double = 20
    @State var fontColor: Color = .black
    @State var renderedImage:UIImage?
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button(action: {
                    viewModel.showTextView = false
                }) {
                    Text("완료")
                }
                
            }
            Spacer()
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
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.white, lineWidth: 1) // 흰색 테두리
//                            )
//                            .background(selectedFont == fontStyle ? Color.white : .clear)
                            .onTapGesture {
                                selectedFont = fontStyle
                            }
                    }
                }
                
            }
            .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.black.opacity(0.5) // 반투명 검정색
            )
        }
    }
    

   
