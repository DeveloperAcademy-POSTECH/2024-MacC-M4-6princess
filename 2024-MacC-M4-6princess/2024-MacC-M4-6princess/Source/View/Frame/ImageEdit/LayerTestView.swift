import SwiftUI
import PhotosUI

struct LayerTestView: View {
    // 이미지 파일명 배열
    @State private var images: [UIImage] = []
    @State private var layerOrder: [Int] = []
    @State private var isEditing: Bool = false
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        VStack {
            // ZStack으로 레이어 순서대로 이미지 표시
            ZStack {
                ForEach(layerOrder.indices, id: \.self) { index in
                    let imageIndex = layerOrder[index]
                    Image(uiImage: images[imageIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text("Image \(imageIndex + 1)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
            .border(Color.black, width: 1)
            .padding()
            
            // EditButton과 추가 버튼
            HStack {
                EditButton()
                Spacer()
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("사진 추가")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
                Text(isEditing ? "Editing" : "Not Editing")
                Spacer()
            }
            .padding()
            
            // 리스트를 사용한 순서 변경 기능
            List {
                ForEach(layerOrder, id: \.self) { index in
                    HStack {
                        Text("Image \(index + 1)")
                        Spacer()
                    }
                }
                .onMove { indices, newOffset in
                    layerOrder.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .onAppear {
                self.isEditing = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(images: $images, layerOrder: $layerOrder)
        }
    }
}
