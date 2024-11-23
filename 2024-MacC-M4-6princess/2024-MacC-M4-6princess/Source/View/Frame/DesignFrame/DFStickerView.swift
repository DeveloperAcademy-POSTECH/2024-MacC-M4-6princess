//
//  DFStickerView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//
import SwiftUI

struct DFStickerView: View {
    @State private var selectedTab: StickerTab = .bubble // 기본 탭 선택
    private let images = StickerImages.getStickerImages() // 스티커 이미지 리스트
    
    var body: some View {
        VStack {
            // 탭 선택 버튼
            HStack(spacing: 20) {
                ForEach(StickerTab.allCases, id: \.self) { tab in
                    Text(tab.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == tab ? Color.white : Color.clear)
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedTab = tab
                            }
                        }
                }
            }
            .padding(.vertical, 10)
            
            // 이미지 스크롤 뷰
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                    ForEach(images[selectedTab] ?? [], id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.black.opacity(0.05))
        }
        .padding()
        .background(Color.black.opacity(0.1))
    }
}

// Enum for Tabs
enum StickerTab: String, CaseIterable {
    case bubble, humor, character, full
    
    var displayName: String {
        switch self {
        case .bubble: return "Bubble"
        case .humor: return "Humor"
        case .character: return "Character"
        case .full: return "Full"
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
