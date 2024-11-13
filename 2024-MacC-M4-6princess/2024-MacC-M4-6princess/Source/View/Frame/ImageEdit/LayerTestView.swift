import SwiftUI
import PhotosUI

// 이미지와 순서를 관리하는 구조체
struct LayerImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
}


struct LayerTestView: View {
    // LayerImage 배열로 이미지와 순서를 관리
    @State private var layerImages: [LayerImage] = []
    @State private var isEditing: Bool = false
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        VStack {
            // ZStack으로 레이어 순서대로 이미지 표시
            ZStack {
                ForEach(layerImages.indices, id: \.self) { index in
                    Image(uiImage: layerImages[index].image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text("Image \(layerImages[index].order)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                        .onAppear {
                            print("Image \(index + 1) Loaded")
                        }
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
                ForEach(layerImages.indices.reversed(), id: \.self) { index in
                    HStack {
                        Text("Image \(layerImages[index].order)")
                        Spacer()
                    }
                }
                .onMove(perform: moveLayerImages)
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .onAppear {
                self.isEditing = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            LayerPhotoPicker(layerImages: $layerImages)
        }
    }
    
    // 순서 변경 함수
    private func moveLayerImages(indices: IndexSet, newOffset: Int) {
        layerImages.move(fromOffsets: indices, toOffset: newOffset)
        print("New Layer Order:")
        for (index, layer) in layerImages.enumerated() {
            print("Image \(layer.order) : \(index + 1)")
        }
    }
}



// PHPickerViewController를 사용하는 SwiftUI Wrapper
struct LayerPhotoPicker: UIViewControllerRepresentable {
    @Binding var layerImages: [LayerImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LayerPhotoPicker
        
        init(_ parent: LayerPhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                let newOrder = self.parent.layerImages.count + 1
                                let newLayerImage = LayerImage(image: uiImage, order: newOrder)
                                self.parent.layerImages.append(newLayerImage)
                            }
                        }
                    }
                }
            }
        }
    }
}
