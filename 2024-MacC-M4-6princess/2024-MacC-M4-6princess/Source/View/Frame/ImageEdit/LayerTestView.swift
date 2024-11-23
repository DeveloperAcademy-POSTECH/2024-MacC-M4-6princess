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
    @State private var previousStep: Int = 0
    
    var layerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(layerImages.indices, id: \.self) { index in // 최상단 레이어는 index가 0
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
                ForEach(layerImages.indices.reversed(), id: \.self) { index in // 가장 위에 오는 것이 index == 0
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
    
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            dragStartPosition = layerImages[index].position
            isDragging = true
            previousStep = 0
            print("Drag 시작: index = \(index), position = \(dragStartPosition ?? .zero)")
        }

        let dragOffsetY = value.translation.height
        let currentStep = Int(dragOffsetY / 50)
        print("Drag 진행 중: dragOffsetY = \(dragOffsetY), currentStep = \(currentStep), previousStep = \(previousStep)")

        if currentStep != previousStep {
            if currentStep < previousStep {
                let steps = abs(currentStep - previousStep)
                print("위로 이동: steps = \(steps)")
                moveLayerForward(at: index, steps: steps)
                let newIndex = max(index - steps, 0)
                selectedLayerIndex = newIndex
            } else if currentStep > previousStep {
                let steps = abs(currentStep - previousStep)
                print("아래로 이동: steps = \(steps)")
                moveLayerBackward(at: index, steps: steps)
                let newIndex = min(index + steps, layerImages.count - 1)
                selectedLayerIndex = newIndex
            }

            previousStep = 0 // 단계 초기화
            print("레이어 상태 업데이트 후: \(layerImages.map { $0.order })")
        }
    }

    func dragOnEnded() {
        print("Drag 종료: selectedLayerIndex = \(selectedLayerIndex ?? -1), previousStep = \(previousStep)")
        isDragging = false
        dragStartPosition = nil
        selectedLayerIndex = nil
        previousStep = 0
        print("최종 레이어 상태: \(layerImages.map { $0.order })")
    }

    private func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        print("moveLayerForward 호출: index = \(index), steps = \(steps)")
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            layerImages.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
    }

    private func moveLayerBackward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        print("moveLayerBackward 호출: index = \(index), steps = \(steps)")
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < layerImages.count - 1 else { return }
            layerImages.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
    }

}
