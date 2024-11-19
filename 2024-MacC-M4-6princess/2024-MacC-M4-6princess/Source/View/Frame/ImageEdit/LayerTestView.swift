import SwiftUI
import PhotosUI

struct LayerImage: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}

struct LayerTestView: View {
    @State private var layerImages: [LayerImage] = []
    @State private var showImagePicker: Bool = false
    @State private var dragStartPosition: CGPoint?
    @State private var isDragging: Bool = false
    @State private var selectedLayerIndex: Int?
    @State private var previousStep: Int = 0 // 이전 단계
    
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
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    dragOnChanged(value: value, index: index)
                                }
                                .onEnded { _ in
                                    dragOnEnded()
                                }
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
    
    // 드래그 변경 시 동작 처리 함수
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            dragStartPosition = layerImages[index].position
            isDragging = true
            previousStep = 0 // 초기화
        }
        
        let dragOffsetY = value.translation.height
        let step = Int(dragOffsetY / 50)
        
        // 단계가 이전 단계와 달라야만 레이어 이동
        if step != previousStep {
            if step < 0, index + abs(step) < layerImages.count {
                moveLayerBackward(at: index, steps: abs(step - previousStep))
                selectedLayerIndex = min(index + abs(step), layerImages.count - 1)
            } else if step > 0, index - step >= 0 {
                moveLayerForward(at: index, steps: step - previousStep)
                selectedLayerIndex = max(index - step, 0)
            }
            previousStep = step // 이전 단계를 업데이트
        }
    }
    
    // 드래그 종료 시 동작 처리 함수
    func dragOnEnded() {
        isDragging = false
        dragStartPosition = nil
        selectedLayerIndex = nil
        previousStep = 0 // 초기화
    }
    
    // 순서 앞으로 이동 함수 (여러 단계)
    private func moveLayerForward(at index: Int, steps: Int) {
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            layerImages.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
        updateOrder()
    }
    
    // 순서 뒤로 이동 함수 (여러 단계)
    private func moveLayerBackward(at index: Int, steps: Int) {
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < layerImages.count - 1 else { return }
            layerImages.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
        updateOrder()
    }
    
    // 레이어 순서 업데이트 함수
    private func updateOrder() {
        for i in 0..<layerImages.count {
            layerImages[i].order = i + 1
        }
    }
}
