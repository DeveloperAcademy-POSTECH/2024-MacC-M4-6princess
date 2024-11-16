import SwiftUI
import PhotosUI

struct LayerTestView: View {
    @State var layerImages: [LayerImage] = []
    @State var showImagePicker: Bool = false
    @State var dragStartPosition: CGPoint?
    @State var isDragging: Bool = false
    @State var selectedLayerIndex: Int?
    @State var currentStep: Int = 0 // 현재 드래그 단계
    var layerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(Array(stride(from: layerImages.count - 1, to: -1, by: -1)), id: \.self) { index in
                if index == selectedLayerIndex {
                    VStack {
                        Spacer()
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .frame(width: 24, height: 4)
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: 6)
                } else {
                    HStack {
                        Image("heart.union")
                            .resizable()
                            .frame(width: 8, height: 6)
                        Spacer()
                    }
                }
            }
        }
        .padding(6)
        .frame(width: 40)
        .background(Color.gray)
        .cornerRadius(8)
        .padding(.horizontal, 5)
    }

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
                        .overlay(
                            Text("Image \(layer.order)")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .padding(5),
                            alignment: .bottom
                        )
                        .gesture(
                            dragGesture(for: index)
                        )
                        .onAppear {
                            print("Image \(index + 1) Loaded")
                        }
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            HStack {
                layerIndicator
                Spacer()
            }
            
            VStack {
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

    // 드래그 제스처 생성 함수
    func dragGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                withAnimation{
                    dragOnChaged(value: value, index: index)
                }
            }
            .onEnded { _ in
                dragOnEnded()
            }
    }

    
}
