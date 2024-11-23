//
//  DFStickerView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//
import SwiftUI

struct DFStickerView: View {
    @StateObject var viewModel:DFFrameModifyViewModel
    @State private var selectedTab: StickerTab = .bubble // 기본 탭 선택
    private let stickers = StickerImages.getStickerImages() // 스티커 이미지 리스트
    
    var body: some View {
        VStack {
            Text("스티커")
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity) // 부모 뷰의 가로 폭을 채우기
                .multilineTextAlignment(.center) // 텍스트 중앙 정렬
                .padding(.top)
            Divider()
            // 탭 선택 버튼
            HStack(spacing: 20) {
                ForEach(StickerTab.allCases, id: \.self) { tab in
                    Text(tab.displayName)
                        .font(.system(size: 13, weight: selectedTab == tab ? .bold : .medium))
                        .foregroundColor(selectedTab == tab ? .pointPink : .gray02)
                        .onTapGesture {
                            selectedTab = tab
                        }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            Divider()
            // 이미지 스크롤 뷰
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(stickers[selectedTab] ?? [], id: \.self) { imageName in
                        VStack {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .onTapGesture {
                            viewModel.showStickerSheet = false
//                            print("Selected Sticker: \(imageName)")
                            
                        }

                        .frame(width: 80, height: 80) // 정사각형 박스 크기
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

enum StickerTab: String, CaseIterable {
    case bubble, humor, character, full
    
    var displayName: String {
        switch self {
            case .bubble: return "말풍선"
            case .humor: return "유머"
            case .character: return "캐릭터"
            case .full: return "프레임"
        }
    }
}
struct StickerImages {
    static func getStickerImages() -> [StickerTab: [String]] {
        return [
            .bubble: (1...33).map { String(format: "bubble%02d", $0) },
            .humor: (1...12).map { String(format: "humor%02d", $0) },
            .character: (1...10).map { String(format: "character%02d", $0) },
            .full: (1...7).map { String(format: "full%02d", $0) }
        ]
    }
}
