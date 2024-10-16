//
//  CameraFrameSelectView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/13/24.
//

import SwiftUI

struct CameraFrameSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var imageDataArray: [(name: String, data: Data)] = []
    @Binding var isFullScreenPop: Bool
    @Binding var selectedFrame: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 제목을 상단에 배치
                SheetTitleView()
                
                if !imageDataArray.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                            Button {
                                dismiss()
                                isFullScreenPop.toggle()
                            } label: {
                                VStack(alignment: .center, spacing: 4) {
                                    Spacer()
                                    Image("plusIcon")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                    Text("새로운\n프레임 만들기")
                                        .font(.system(size: 13))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.83, green: 0.83, blue: 0.83))
                            }
                            
                            
                            ForEach(imageDataArray, id: \.name) { imageInfo in
                                Button {
                                    selectedFrame = imageInfo.name
                                    dismiss()
                                } label: {
                                    if let uiImage = UIImage(data: imageInfo.data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    } else {
                                        Color.gray
                                            .frame(width: 150, height: 150) // 크기 설정
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    Spacer()
                    Button {
                        dismiss()
                        isFullScreenPop.toggle()
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Image("plusIcon")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                            Text("앗! 내가 만든 프레임이 없어요!\n화면을 클릭해서 새로운 프레임을 만들어주세요!")
                                .font(.system(size: 17))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                        }
                    }
                    
                    
                    Spacer()
                }
            }.onAppear {
                loadImages()
            }
        }
    }
    
    //임시로 프레임 불러오는 함수
    private func loadImages() {
        // 여기를 CoreData에서 불러오는 방식으로 수정
        let imageNames = ["frameTest1", "frameTest2", "frameTest3", "frameTest4", "frameTest5"] // 이미지 파일 이름
        for imageName in imageNames {
            if let image = UIImage(named: imageName),
               let data = image.pngData() {
                    imageDataArray.append((name: imageName, data: data))
            }
        }
    }
}


struct SheetTitleView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("프레임 선택")
                    .font(Font.custom("SF Pro", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            }
            .padding(.vertical, 11)
            .padding(.top, 10)
            .overlay(
                Rectangle()
                    .fill(.white)
                    .padding(.bottom, 1)
                    .background(.sheetBorder)
            )
            Text("프레임 선택")
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }
        
    }
}
