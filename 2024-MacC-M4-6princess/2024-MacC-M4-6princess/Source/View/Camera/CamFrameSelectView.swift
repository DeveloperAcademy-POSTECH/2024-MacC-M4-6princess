//
//  CameraFrameSelectView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 10/13/24.
//

import SwiftUI

struct CameraFrameSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var imageDataArray: [(name: String, data: Data)] = []  // 여기를 CoreData에서 불러오는 방식으로 수정
    @Binding var selectedFrame: String

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    NavigationLink(destination: CameraView(selectedFrame: selectedFrame)) {
                        Text("새로운 프레임 만들기")
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
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .padding()
                            } else {
                                Color.gray
                                    .frame(width: 150, height: 150)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadImages()
            }
            .padding()
        }
    }

    private func loadImages() {
        let imageNames = ["frameTest1", "frameTest2", "frameTest3", "frameTest4", "frameTest5"] // 이미지 파일 이름
        for imageName in imageNames {
            if let image = UIImage(named: imageName),
               let data = image.pngData() {
                imageDataArray.append((name: imageName, data: data))
            }
        }
    }
}
