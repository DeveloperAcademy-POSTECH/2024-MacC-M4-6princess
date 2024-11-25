//
//  LayerChangeView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/24/24.
//
import SwiftUI
import PhotosUI

struct LayerChangeView: View {
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
        if !isDragging {
            selectedLayerIndex = index // 드래그 중인 레이어의 인덱스 저장
            dragStartPosition = layerImages[index].position // 시작 위치 저장
            isDragging = true // 드래그 상태 활성화
            previousStep = 0 // 이전 이동 단계 초기화
//            print("Drag 시작: index = \(index), position = \(dragStartPosition ?? .zero), previousStep = \(previousStep)")
            print("Drag 시작: index = \(index)")
        }
        
        let dragOffsetY = value.translation.height // 드래그 이동 거리 (Y축 기준)
        let currentStep = Int(dragOffsetY-distance / 50) // 드래그 이동을 50 단위로 계산해 현재 이동 단계 도출
//        print("Drag 진행 중: dragOffsetY = \(dragOffsetY), currentStep = \(currentStep), previousStep = \(previousStep)")

        // 이전 단계와 현재 단계가 다를 때만 실행 (중복 이동 방지)
        if currentStep != previousStep {
            if currentStep < previousStep {
                // 이전 단계보다 더 위로 이동한 경우 (레이어 앞으로 이동)
                let steps = abs(currentStep - previousStep) // 이동 단계 계산
                print("위로 이동: steps = \(steps)")
                moveLayerForward(at: index, steps: steps) // 레이어를 앞으로 이동
                let newIndex = max(index - steps, 0) // 새로운 인덱스 계산
                print("index-steps = \(index-steps)")
                selectedLayerIndex = newIndex // 선택된 레이어 인덱스 업데이트
            } else if currentStep > previousStep {
                // 이전 단계보다 더 아래로 이동한 경우 (레이어 뒤로 이동)
                let steps = abs(currentStep - previousStep) // 이동 단계 계산
                print("아래로 이동: steps = \(steps)")
                moveLayerBackward(at: index, steps: steps) // 레이어를 뒤로 이동
                print("index+steps = \(index+steps)")
                print("layerImages.count - 1 = \(layerImages.count - 1)")
                let newIndex = min(index + steps, layerImages.count - 1) // 새로운 인덱스 계산
                selectedLayerIndex = newIndex // 선택된 레이어 인덱스 업데이트
            }

            previousStep = currentStep // 이전 단계 업데이트
//            dragOffsetY = 0
            distance += dragOffsetY
            
            print("레이어 상태 업데이트 후: \(layerImages.map { $0.order })")
        }
    }

    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        print("Drag 종료: selectedLayerIndex = \(selectedLayerIndex ?? -1), previousStep = \(previousStep)")
        isDragging = false // 드래그 상태 비활성화
        dragStartPosition = nil // 시작 위치 초기화
        selectedLayerIndex = nil // 선택된 레이어 초기화
        previousStep = 0 // 이전 이동 단계 초기화
        print("최종 레이어 상태: \(layerImages.map { $0.order })")
    }

    // 레이어를 앞으로 이동하는 함수
    private func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index

        // 변경 전 상태 저장
        let beforeOrder = layerImages.map { $0.order }

        for _ in 0..<steps {
            guard currentIndex > 0 else { return }
            layerImages.swapAt(currentIndex, currentIndex - 1) // 현재 레이어와 바로 앞 레이어 교환
            currentIndex -= 1 // 현재 인덱스를 앞으로 이동
        }

        // 변경 후 상태 저장
        let afterOrder = layerImages.map { $0.order }
        print("레이어 변경 (앞으로): \(beforeOrder) -> \(afterOrder)")
    }

    // 레이어를 뒤로 이동하는 함수
    private func moveLayerBackward(at index: Int, steps: Int) {
        guard steps > 0 else { return }
        var currentIndex = index

        // 변경 전 상태 저장
        let beforeOrder = layerImages.map { $0.order }

        for _ in 0..<steps {
            guard currentIndex < layerImages.count - 1 else { return }
            layerImages.swapAt(currentIndex, currentIndex + 1) // 현재 레이어와 바로 뒤 레이어 교환
            currentIndex += 1 // 현재 인덱스를 뒤로 이동
        }

        // 변경 후 상태 저장
        let afterOrder = layerImages.map { $0.order }
        print("레이어 변경 (뒤로): \(beforeOrder) -> \(afterOrder)")
    }

}
