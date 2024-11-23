//
//  LayerChangeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//
import SwiftUI
import PhotosUI

struct LayerModel: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}
struct LayerChangeView: View {
    @State private var layerImages: [LayerModel] = []
    @State private var showImagePicker: Bool = false
    @State private var dragStartPosition: CGPoint?
    @State private var isDragging: Bool = false
    @State private var selectedLayerIndex: Int?
    @State private var previousStep: Int = 0

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
                        .gesture(dragGesture(for: index)) // 제스처 분리
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

    // 레이어 순서 표시 뷰
    var layerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(layerImages.indices, id: \.self) { index in
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

    // 드래그 제스처 분리
    func dragGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragOnChanged(value: value, index: index)
            }
            .onEnded { _ in
                dragOnEnded()
            }
    }

    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            dragStartPosition = layerImages[index].position
            isDragging = true
            previousStep = 0
        }

        let dragOffsetY = value.translation.height
        let currentStep = Int(dragOffsetY / 50)

        if currentStep != previousStep {
            if currentStep < previousStep {
                let steps = abs(currentStep - previousStep)
                moveLayerForward(at: index, steps: steps)
                let newIndex = max(index - steps, 0)
                selectedLayerIndex = newIndex
            } else if currentStep > previousStep {
                let steps = abs(currentStep - previousStep)
                moveLayerBackward(at: index, steps: steps)
                let newIndex = min(index + steps, layerImages.count - 1)
                selectedLayerIndex = newIndex
            }

            previousStep = 0 // 단계 초기화
        }
    }

    func dragOnEnded() {
        isDragging = false
        dragStartPosition = nil
        selectedLayerIndex = nil
        previousStep = 0
    }

    private func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            layerImages.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
    }

    private func moveLayerBackward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < layerImages.count - 1 else { return }
            layerImages.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
    }
}
