//
//  DFStickerView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/22/24.
//
import SwiftUI
import FirebaseAnalytics
/// 코드가 복잡하지 않아서 viewModel 사용안함


struct DFStickerView: View {
    @StateObject var viewModel:DFModifyViewModel
    @State private var selectedTab: StickerTab = .bubble // 기본 탭 선택
    private let stickers = StickerImages.getStickerImages() // 스티커 이미지 리스트
    @EnvironmentObject var imageModel: ImageListModel
    
    var body: some View {
        VStack {
            
            Text("스티커")
                .font(.system(size: 17, weight: .bold))
                .frame(maxWidth: .infinity) // 부모 뷰의 가로 폭을 채우기
                .multilineTextAlignment(.center) // 텍스트 중앙 정렬
                .padding(.top)
                .padding(.vertical,8)
            
            Divider()
            // 탭 선택 버튼
            HStack() {
                
                ForEach(StickerTab.allCases, id: \.self) { tab in
                    HStack{
                        Spacer()
                        ZStack{
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 13)
                                    .fill(.gray02)
                                    .frame(width: 70, height: 26)
                            }
                            Text(tab.displayName)
                                .font(.system(size: 15, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundColor(selectedTab == tab ? .white : .gray02)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .onTapGesture {
                                    selectedTab = tab
                                    viewModel.selectedStickerTab = tab
                                }
                                .frame(width:UIScreen.main.bounds.width/5-20)
                        }
                        
                        Spacer()
                    }
                    .frame(width:UIScreen.main.bounds.width/5)
                    
                }
                
            }
            .padding(.horizontal,20)
            
            Divider()
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 70, maximum: 120), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(stickers[selectedTab] ?? [], id: \.self) { imageName in
                        VStack {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // 정사각형 유지
                                .aspectRatio(1, contentMode: .fit) // 비율 유지
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .onTapGesture {
                            let newImage = SubjectImage()
                            if let image = UIImage(named: imageName) {
                                newImage.sticker = image
                                newImage.originalImage = image
                                if viewModel.selectedStickerTab == .full{
                                    newImage.isFullSticker = true
                                }
                                
                                imageModel.imageList.forEach { $0.isTapped = false }
                                imageModel.imageList.append(newImage)
                                
                                Analytics.logEvent("A5_스티커선택", parameters: ["sticker_name": imageName])
                                
                                viewModel.selectedSubject = imageModel.imageList.last
                                viewModel.selectedIndex = imageModel.imageList.indices.last
                                viewModel.modelListControl(subject: imageModel.imageList.last!)
                            } else {
                                print("Image not found")
                            }
                            
                            viewModel.showStickerSheet = false
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 정사각형 박스 크기
                        .aspectRatio(1, contentMode: .fit) // 비율 유지
                    }
                }
                .padding(.horizontal,20)
            }
        }
    }
}

enum StickerTab: String, CaseIterable {
    case bubble, humor, character, full
    
    var displayName: String {
        NSLocalizedString("stickerTab.\(self.rawValue)", comment: "")
    }
}

struct StickerImages {
    static func getStickerImages() -> [StickerTab: [String]] {
        let locale = Locale.current.identifier

        let humorStickers: [String]
        switch locale {
        case let id where id.hasPrefix("ja"):
            humorStickers = (1...17).map { String(format: "ja_humor%02d", $0) }
        case let id where id.hasPrefix("zh"):
            humorStickers = (1...22).map { String(format: "zh_humor%02d", $0) }
        default: // 영어 포함
            humorStickers = (1...28).map { String(format: "humor%02d", $0) }
        }
        let fullStickers: [String]
        switch locale {
        case let id where id.hasPrefix("ja"):
            fullStickers = (1...4).map { String(format: "ja_full%02d", $0) }
        case let id where id.hasPrefix("zh"):
            fullStickers = (1...3).map { String(format: "zh_full%02d", $0) }
            
        default: // 영어 포함
            fullStickers = (1...5).map { String(format: "full%02d", $0) }
        }
        return [
            .bubble: (1...33).map { String(format: "bubble%02d", $0) },
            .humor: humorStickers,
            .character: (1...6).map { String(format: "character%02d", $0) },
            .full: fullStickers
        ]
    }

}
