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
            if isEditing{
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
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
                        
                }
            }
            .overlay(
                LongPressGestureRecognizerWrapper(isEditing: $isEditing)
            )
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
                if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                    activeDragOffset = value.translation
                }
            }
            .onEnded { value in
                if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                    layerImages[index].position.x += activeDragOffset.width
                    layerImages[index].position.y += activeDragOffset.height
                    activeDragOffset = .zero
                }
            }
            .simultaneously(
                with: MagnificationGesture()
                    .onChanged { value in
                        if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                            activeScale = value
                        }
                    }
                    .onEnded { value in
                        if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                            layerImages[index].scale *= activeScale
                            activeScale = 1.0
                        }
                    }
            )
            .simultaneously(
                with: RotationGesture()
                    .onChanged { angle in
                        if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                            activeRotation = angle
                        }
                    }
                    .onEnded { angle in
                        if isEditing, selectedLayerIndex == index { // isEditing이 true일 때만 실행
                            layerImages[index].rotation += activeRotation
                            activeRotation = .zero
                        }
                    }
            )
    }


}

