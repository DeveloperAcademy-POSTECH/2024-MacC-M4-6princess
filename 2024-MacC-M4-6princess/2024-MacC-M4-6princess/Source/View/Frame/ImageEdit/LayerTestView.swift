import SwiftUI

import PhotosUI

struct LayerTestView: View {
    @State private var layerImages: [LayerImage] = []
    @State private var showImagePicker: Bool = false
    @State private var dragStartPosition: CGPoint?
    @State private var isDragging: Bool = false
    @State private var selectedLayerIndex: Int?
    //    @State var memoryIndex
    var layerIndicator: some View {
        VStack(spacing: 4) {
            ForEach(0..<layerImages.count, id: \.self) { index in
                if index==selectedLayerIndex {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 20, height: 3)
                }
                else{
                    HStack{
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.gray)
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
    }
    var body: some View {
        ZStack {
            HStack {
                layerIndicator
                // 막대 그래프 표시
                //                VStack {
                //                    ForEach(layerImages.indices, id: \.self) { index in
                //                        Rectangle()
                //                            .fill(index == selectedLayerIndex ? Color.blue : Color.gray.opacity(0.5))
                //                            .frame(width: 10, height: 30)
                //                    }
                //                }
                //                .padding(.trailing, 10)
                
                // ZStack으로 레이어 순서대로 이미지 표시
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
                                        if !isDragging {
                                            // 드래그 시작 시, 현재 레이어 위치 기억
                                            selectedLayerIndex = index
                                            dragStartPosition = layer.position
                                            isDragging = true
                                        }
                                        
                                        // 드래그의 Y축 이동 거리
                                        let dragOffsetY = value.translation.height
                                        let step = Int(dragOffsetY / 50) // 50픽셀당 한 단계 이동
                                        
                                        if step < 0, index - abs(step) >= 0 {
                                            // 위로 드래그해서 여러 단계 앞으로 이동
                                            moveLayerForward(at: index, steps: abs(step))
                                            selectedLayerIndex = max(index - abs(step), 0)
                                        } else if step > 0, index + step < layerImages.count {
                                            // 아래로 드래그해서 여러 단계 뒤로 이동
                                            moveLayerBackward(at: index, steps: step)
                                            selectedLayerIndex = min(index + step, layerImages.count - 1)
                                        }
                                    }
                                    .onEnded { _ in
                                        // 드래그 종료 시 초기화
                                        isDragging = false
                                        dragStartPosition = nil
                                        selectedLayerIndex = nil
                                    }
                            )
                            .onAppear {
                                print("Image \(index + 1) Loaded")
                            }
                    }
                }
                .frame(width: 300, height: 300)
                .padding()
            }
            
            // 추가 버튼
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
    
    // 순서 앞으로 이동 함수 (여러 단계)
    private func moveLayerForward(at index: Int, steps: Int) {
        guard index - steps >= 0 else { return }
        let newIndex = index - steps
        let element = layerImages.remove(at: index)
        layerImages.insert(element, at: newIndex)
        updateOrder()
    }
    
    // 순서 뒤로 이동 함수 (여러 단계)
    private func moveLayerBackward(at index: Int, steps: Int) {
        guard index + steps < layerImages.count else { return }
        let newIndex = index + steps
        let element = layerImages.remove(at: index)
        layerImages.insert(element, at: newIndex)
        updateOrder()
    }
    
    // 레이어 순서 업데이트 함수
    private func updateOrder() {
        for i in 0..<layerImages.count {
            layerImages[i].order = i + 1
        }
        
    }
}
