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
        // 드래그가 시작되지 않았다면 초기 설정
        if !isDragging {
            print("value:\(value)") // 현재 드래그 값 디버깅 출력
            selectedLayerIndex = index // 현재 드래그 중인 레이어의 인덱스를 저장
            dragStartPosition = layerImages[index].position // 드래그 시작 시 레이어의 초기 위치 저장
            isDragging = true // 드래그 상태를 활성화
            previousStep = 0 // 이전 단계 초기화
        }
        
        let dragOffsetY = value.translation.height // 드래그 이동 거리의 Y축 값
        let step = Int(dragOffsetY / 50) // Y축 이동 거리를 50으로 나눠 이동 단계(step)를 계산
        
        // 현재 단계가 이전 단계와 다를 때만 레이어를 이동
        if step != previousStep {
            if step < 0, index + abs(step) < layerImages.count {
                // 위로 드래그 (step이 음수)
                // 현재 레이어를 step 단계만큼 뒤로 이동
                moveLayerBackward(at: index, steps: abs(step - previousStep))
                // 드래그로 이동한 후 선택된 레이어 인덱스를 업데이트
                selectedLayerIndex = min(index + abs(step), layerImages.count - 1)
            } else if step > 0, index - step >= 0 {
                // 아래로 드래그 (step이 양수)
                // 현재 레이어를 step 단계만큼 앞으로 이동
                moveLayerForward(at: index, steps: step - previousStep)
                // 드래그로 이동한 후 선택된 레이어 인덱스를 업데이트
                selectedLayerIndex = max(index - step, 0)
            }
            // 이전 단계를 현재 단계로 업데이트
            previousStep = step
        }
    }

    // 드래그 종료 시 동작 처리 함수
    func dragOnEnded() {
        isDragging = false // 드래그 상태 종료
        dragStartPosition = nil // 드래그 시작 위치 초기화
        selectedLayerIndex = nil // 선택된 레이어 초기화
        previousStep = 0 // 이전 단계 초기화
    }

    // 순서 앞으로 이동 함수 (여러 단계)
    private func moveLayerForward(at index: Int, steps: Int) {
        guard steps > 0 else { return } // steps가 0 이하인 경우 함수 종료
        var currentIndex = index // 현재 레이어의 인덱스를 추적
        for _ in 0..<steps { // steps 단계만큼 반복
            guard currentIndex > 0 else { return } // 배열의 시작 범위를 벗어나지 않도록 제한
            layerImages.swapAt(currentIndex, currentIndex - 1) // 현재 인덱스와 바로 앞 인덱스의 레이어를 교환
            currentIndex -= 1 // 현재 인덱스를 앞으로 한 단계 이동
        }
        updateOrder() // 순서 업데이트
    }

    // 순서 뒤로 이동 함수 (여러 단계)
    private func moveLayerBackward(at index: Int, steps: Int) {
        guard steps > 0 else { return } // steps가 0 이하인 경우 함수 종료
        var currentIndex = index // 현재 레이어의 인덱스를 추적
        for _ in 0..<steps { // steps 단계만큼 반복
            guard currentIndex < layerImages.count - 1 else { return } // 배열의 끝 범위를 벗어나지 않도록 제한
            layerImages.swapAt(currentIndex, currentIndex + 1) // 현재 인덱스와 바로 뒤 인덱스의 레이어를 교환
            currentIndex += 1 // 현재 인덱스를 뒤로 한 단계 이동
        }
        updateOrder() // 순서 업데이트
    }

    // 레이어 순서 업데이트 함수
    private func updateOrder() {
        // 모든 레이어의 순서를 인덱스 기반으로 재설정
        for i in 0..<layerImages.count {
            layerImages[i].order = i + 1 // 배열의 현재 순서에 맞게 order를 업데이트
        }
    }

   
}
