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
                                    .frame(width: 56, height: 26)
                                
                            }
                            Text(tab.displayName)
                                .font(.system(size: 15, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundColor(selectedTab == tab ? .white : .gray02)
                                .onTapGesture {
                                    selectedTab = tab
                                }
                        }
                        
                        Spacer()
                    }
                    .frame(width:UIScreen.main.bounds.width/5)
                    
                }
                
            }
                        .padding(.horizontal,20)
            //            .padding(.vertical, 6)
            Divider()
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 10)],
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
