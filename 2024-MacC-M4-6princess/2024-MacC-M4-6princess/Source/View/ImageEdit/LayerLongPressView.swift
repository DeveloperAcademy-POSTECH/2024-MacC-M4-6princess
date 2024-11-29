//
//  LayerLongPressView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/29/24.
//
import SwiftUI
import PhotosUI

struct LayerLongPressView: View {
    @State private var layerImages: [LayerModel] = []
    @State private var showImagePicker: Bool = false
//    @State private var dragStartPosition: CGPoint?
    @State private var isDragging: Bool = false
    @State private var selectedLayerIndex: Int?
    @State private var isLongPressed: Bool = false // 1초 길게 누름 상태
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
                        .gesture(longPressAndDragGesture(for: index)) // 제스처 분리
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
    
    // 1초 길게 누르고 드래그 제스처를 생성하는 함수
    func longPressAndDragGesture(for index: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5) // 1초 동안 길게 누름
            .onEnded { _ in
                isLongPressed = true // 길게 눌림 활성화
                selectedLayerIndex = index
                print("isLongPressed 눌림")
            }
            .simultaneously(with: DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if isLongPressed { // 길게 누른 상태에서만 드래그 동작
                        dragOnChanged(value: value, index: index)
                    }
                }
                .onEnded { _ in
                    dragOnEnded()
                    isLongPressed = false // 길게 누름 상태 초기화
                }
            )
    }

    // 드래그 중 호출되는 함수
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
//            dragStartPosition = layerImages[index].position
            isDragging = true
        }

        let dragOffsetY = value.translation.height
        let currentStep = Int(dragOffsetY / 50)

        if let currentIndex = selectedLayerIndex, currentStep != currentIndex {
            if currentStep < currentIndex {
                moveLayerForward(at: currentIndex, steps: abs(currentStep - currentIndex))
            } else {
                moveLayerBackward(at: currentIndex, steps: abs(currentStep - currentIndex))
            }
            selectedLayerIndex = currentStep
        }
    }

    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        isDragging = false
//        dragStartPosition = nil
        selectedLayerIndex = nil
    }
    
    // 레이어를 앞으로 이동
       private func moveLayerForward(at index: Int, steps: Int) {
           guard steps < 0 else { return }
           var currentIndex = index
           for _ in 0..<steps {
               guard currentIndex > 0 else { return }
//               print("currentIndex: \(currentIndex),currentIndex - 1: \(currentIndex - 1)")
               layerImages.swapAt(currentIndex, currentIndex - 1)
               currentIndex -= 1
           }
       }

       // 레이어를 뒤로 이동
       private func moveLayerBackward(at index: Int, steps: Int) {
           guard steps > 0 else { return }
           var currentIndex = index
           for _ in 0..<steps {
               guard currentIndex < layerImages.count - 1 else { return }
               guard currentIndex > 0 else { return }
//               print("currentIndex: \(currentIndex),currentIndex + 1: \(currentIndex + 1)")
               layerImages.swapAt(currentIndex, currentIndex + 1)
               currentIndex += 1
           }
       }
}
//.gesture(longPressAndDragGesture(for: index)) // 제스처 분리
