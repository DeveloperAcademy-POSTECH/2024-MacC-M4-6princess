import SwiftUI
import PhotosUI

struct LayerImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var position: CGPoint // 이미지 위치
    var scale: CGFloat = 1.0      // 이미지 크기
    var rotation: Angle = .zero   // 이미지 회전 각도
}

struct LayerTestView: View {
    @State var layerImages: [LayerImage] = []
    @State var showImagePicker: Bool = false
    @State var selectedLayerIndex: Int?
    
    @State private var activeDragOffset: CGSize = .zero // 드래그 이동값
    @State private var activeScale: CGFloat = 1.0       // 현재 확대/축소 값
    @State private var activeRotation: Angle = .zero    // 현재 회전 값
    
    @State private var isEditing: Bool = false // 에디팅 모드 활성화 여부
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(layerImages.indices, id: \.self) { index in
                    let layer = layerImages[index]
                    Image(uiImage: layer.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .position(layer.position)
                        .scaleEffect(layer.scale)
                        .rotationEffect(layer.rotation)
                        .background(isEditing && selectedLayerIndex == index ? Color.gray.opacity(0.5) : Color.clear)
                        .overlay(
                            Text("Image \(layer.order)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                        .gesture(combinedGesture(for: index))
                        .onTapGesture {
                            selectedLayerIndex = index
                        }
                        .overlay(
                            LongPressGestureRecognizerWrapper(isEditing: $isEditing, selectedLayerIndex: $selectedLayerIndex, currentIndex: index)
                        )
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            VStack {
                if isEditing {
                    Text("레이어를 위아래로 끌어서 변경할 수 있어요")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                }
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
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            LayerPhotoPicker(layerImages: $layerImages, screenSize: UIScreen.main.bounds.size)
        }
    }
    
    private func combinedGesture(for index: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if selectedLayerIndex == index {
                    activeDragOffset = value.translation
                }
            }
            .onEnded { value in
                if selectedLayerIndex == index {
                    layerImages[index].position.x += activeDragOffset.width
                    layerImages[index].position.y += activeDragOffset.height
                    activeDragOffset = .zero
                }
            }
            .simultaneously(
                with: MagnificationGesture()
                    .onChanged { value in
                        if selectedLayerIndex == index {
                            activeScale = value
                        }
                    }
                    .onEnded { value in
                        if selectedLayerIndex == index {
                            layerImages[index].scale *= activeScale
                            activeScale = 1.0
                        }
                    }
            )
            .simultaneously(
                with: RotationGesture()
                    .onChanged { angle in
                        if selectedLayerIndex == index {
                            activeRotation = angle
                        }
                    }
                    .onEnded { angle in
                        if selectedLayerIndex == index {
                            layerImages[index].rotation += activeRotation
                            activeRotation = .zero
                        }
                    }
            )
    }
}

// UIKit의 LongPressGestureRecognizer를 SwiftUI에 통합
struct LongPressGestureRecognizerWrapper: UIViewRepresentable {
    @Binding var isEditing: Bool
    @Binding var selectedLayerIndex: Int?
    var currentIndex: Int
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress))
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isEditing: $isEditing, selectedLayerIndex: $selectedLayerIndex, currentIndex: currentIndex)
    }
    
    class Coordinator: NSObject {
        @Binding var isEditing: Bool
        @Binding var selectedLayerIndex: Int?
        var currentIndex: Int
        
        init(isEditing: Binding<Bool>, selectedLayerIndex: Binding<Int?>, currentIndex: Int) {
            _isEditing = isEditing
            _selectedLayerIndex = selectedLayerIndex
            self.currentIndex = currentIndex
        }
        
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                isEditing = true
                selectedLayerIndex = currentIndex
            } else if gestureRecognizer.state == .ended {
                isEditing = false
            }
        }
    }
}
