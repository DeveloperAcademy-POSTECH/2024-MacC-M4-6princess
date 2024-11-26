//
//  LayerChangeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//
import SwiftUI
import PhotosUI

struct LayerChangeTestView: View {
    @State private var layerImages: [LayerModel] = []
    @State private var showImagePicker: Bool = false
    @State private var dragStartPosition: CGPoint?
    @State private var isDragging: Bool = false
    @State private var selectedLayerIndex: Int?
    @State private var previousStep: Int = 0
    @State var distance = 0.0
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
            LayerPhotoPicker2(layerImages: $layerImages, screenSize: UIScreen.main.bounds.size)
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
    // 드래그 제스처를 생성하는 함수
    func dragGesture(for index: Int) -> some Gesture {
        // 최소 이동 거리 없이 DragGesture를 생성
        DragGesture(minimumDistance: 0)
            // 드래그 중 발생하는 동작 정의
            .onChanged { value in
                dragOnChanged(value: value, index: index)
            }
            // 드래그가 종료되었을 때 발생하는 동작 정의
            .onEnded { _ in
                dragOnEnded()
            }
    }

    // 드래그 중 호출되는 함수
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        // 드래그가 처음 시작되었을 때 초기 설정
        if !isDragging {
            selectedLayerIndex = index
            dragStartPosition = layerImages[index].position
            isDragging = true
            previousStep = 0
        }

        let dragOffsetY = value.translation.height
        let currentStep = Int(dragOffsetY / 50)

        // 이전 단계와 현재 단계가 다를 때만 실행 (중복 이동 방지)
        if currentStep != previousStep {
            if currentStep < previousStep {
                // 레이어 앞으로 이동
                let steps = abs(currentStep - previousStep)
                if let selected = selectedLayerIndex{
                    moveLayerForward(at: selected, steps: steps)
                    let newIndex = max(selected - steps, 0)
                    selectedLayerIndex = newIndex
                    print("newIndex:\(newIndex)")
                }
                else{
                    print("not search selectedLayerIndex")
                }
            } else if currentStep > previousStep {
                // 이전 단계보다 더 아래로 이동한 경우 (레이어 뒤로 이동)
                let steps = abs(currentStep - previousStep)
                print("steps:\(steps)")
                if let selected = selectedLayerIndex{
                    moveLayerBackward(at: selected, steps: steps)
                    let newIndex = min(selected + steps, layerImages.count - 1)
                    selectedLayerIndex = newIndex
                    print("newIndex:\(newIndex)")
                }
                else{
                    print("not search selectedLayerIndex")
                }
            }
            previousStep = currentStep
        }
    }

    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        isDragging = false
        dragStartPosition = nil
        selectedLayerIndex = nil
        previousStep = 0
    }

    // 레이어를 앞으로 이동시킴
    private func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            layerImages.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
    }

    // 레이어를 뒤로 이동하는 함수
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
