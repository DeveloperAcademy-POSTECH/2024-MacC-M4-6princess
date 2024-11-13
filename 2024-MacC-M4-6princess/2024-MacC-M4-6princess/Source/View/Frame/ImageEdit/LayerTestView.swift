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

// PHPickerViewController를 사용하는 SwiftUI Wrapper
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var layerOrder: [Int]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 여러 개의 사진을 선택 가능
        config.filter = .images // 이미지 필터 설정
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                // 이미지 추가 및 레이어 순서 갱신
                                self.parent.images.append(uiImage)
                                self.parent.layerOrder.append(self.parent.images.count - 1)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LayerTestView_Previews: PreviewProvider {
    static var previews: some View {
        LayerTestView()
    }
}
