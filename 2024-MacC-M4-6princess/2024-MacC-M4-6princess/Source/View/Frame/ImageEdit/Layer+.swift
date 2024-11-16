//
//  Layer+.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/14/24.
//

import SwiftUI
import PhotosUI


extension LayerTestView{
    
    //    var layerIndicator: some View {
    //        VStack(spacing: 6) {
    //            ForEach(Array(stride(from: layerImages.count - 1, to: -1, by: -1)), id: \.self) { index in
    //                if index == selectedLayerIndex {
    //                    VStack {
    //                        Spacer()
    //                        HStack {
    //                            RoundedRectangle(cornerRadius: 3)
    //                                .frame(width: 24, height: 4)
    //                                .foregroundColor(.white)
    //                                .padding(.leading, 4)
    //                            Spacer()
    //                        }
    //                        Spacer()
    //                    }
    //                    .frame(height: 6)
    //                } else {
    //                    HStack {
    //                        Image("heart.union")
    //                            .resizable()
    //                            .frame(width: 8, height: 6)
    //                        Spacer()
    //                    }
    //                }
    //            }
    //        }
    //        .padding(6)
    //        .frame(width: 40)
    //        .background(Color.gray)
    //        .cornerRadius(8)
    //        .padding(.horizontal, 5)
    //    }
    
    //    // 드래그 제스처 생성 함수
    //    func dragGesture(for index: Int) -> some Gesture {
    //        DragGesture(minimumDistance: 0)
    //            .onChanged { value in
    //                withAnimation{
    //                    dragOnChaged(value: value, index: index)
    //                }
    //            }
    //            .onEnded { _ in
    //                dragOnEnded()
    //            }
    //    }
    // 드래그 변경 시 동작 처리 함수
    //    func dragOnChaged(value: DragGesture.Value, index: Int) {
    //        // 드래그가 시작되지 않았다면 초기 설정
    //        if !isDragging {
    //            selectedLayerIndex = index // 현재 드래그 중인 레이어 인덱스를 저장
    //            dragStartPosition = layerImages[index].position // 드래그 시작 시 레이어의 초기 위치 저장
    //            isDragging = true // 드래그 상태를 true로 설정
    //        }
    //
    //        // 드래그된 Y축 거리 계산
    //        let dragOffsetY = value.translation.height
    //
    //        // Y축 이동 거리(드래그 높이)를 50으로 나눠서 이동할 단계(step) 계산
    //        let step = Int(dragOffsetY / 50)
    //
    //        // 위로 드래그하여 레이어를 뒤로 이동
    //        if step < 0, index + abs(step) < layerImages.count {
    //            moveLayerBackward(at: index, steps: abs(step)) // 현재 레이어를 step 단계만큼 뒤로 이동
    //            selectedLayerIndex = min(index + abs(step), layerImages.count - 1) // 이동 후의 레이어 인덱스 업데이트
    //        }
    //        // 아래로 드래그하여 레이어를 앞으로 이동
    //        else if step > 0, index - step >= 0 {
    //            moveLayerForward(at: index, steps: step) // 현재 레이어를 step 단계만큼 앞으로 이동
    //            selectedLayerIndex = max(index - step, 0) // 이동 후의 레이어 인덱스 업데이트
    //        }
    //    }
    
    // 드래그 종료 시 동작 처리 함수
    //    func dragOnEnded() {
    //        isDragging = false
    //        dragStartPosition = nil
    //        selectedLayerIndex = nil
    //    }
    //
    //    // 순서 앞으로 이동 함수 (여러 단계)
    //    func moveLayerForward(at index: Int, steps: Int) {
    //        guard index - steps >= 0 else { return }
    //        let newIndex = index - steps
    //        let element = layerImages.remove(at: index)
    //        layerImages.insert(element, at: newIndex)
    //        updateOrder()
    //    }
    //
    //    // 순서 뒤로 이동 함수 (여러 단계)
    //    func moveLayerBackward(at index: Int, steps: Int) {
    //        guard index + steps < layerImages.count else { return }
    //        let newIndex = index + steps
    //        let element = layerImages.remove(at: index)
    //        layerImages.insert(element, at: newIndex)
    //        updateOrder()
    //    }
    //
    //    // 레이어 순서 업데이트 함수
    //    func updateOrder() {
    //        for i in 0..<layerImages.count {
    //            layerImages[i].order = i + 1
    //        }
    //    }
    //}
    //
    //
    //
    // PHPickerViewController를 사용하는 SwiftUI Wrapper
    struct LayerPhotoPicker: UIViewControllerRepresentable {
        @Binding var layerImages: [LayerImage]
        var screenSize: CGSize
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.selectionLimit = 0
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: LayerPhotoPicker
            
            init(_ parent: LayerPhotoPicker) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                
                for result in results {
                    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                            if let uiImage = image as? UIImage {
                                DispatchQueue.main.async {
                                    let newOrder = self.parent.layerImages.count + 1
                                    let newLayerImage = LayerImage(image: uiImage, order: newOrder, position: CGPoint(x: self.parent.screenSize.width/2, y: self.parent.screenSize.height/3))
                                    self.parent.layerImages.append(newLayerImage)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
