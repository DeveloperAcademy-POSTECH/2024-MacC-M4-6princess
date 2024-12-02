//
//  LayerLongPressView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/29/24.
//
import SwiftUI
import PhotosUI

struct LayerLongPressView: View {
    
    @State private var showImagePicker: Bool = false
    @State private var layerList: [LayerModel] = []
    @State var isDragging: Bool = false
    @State var selectedLayerIndex: Int?
    @State var isLongPressed: Bool = false
    @State var beforeDragOffsetY: CGFloat = .zero
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(layerList.indices, id: \.self) { index in
                    let layer = layerList[index]
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
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    isLongPressed = true
                                    selectedLayerIndex = index
                                    print("isLongPressed 눌림")
                                }
                                .simultaneously(with: DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if isLongPressed {
                                            dragOnChanged(value: value, index: index)
                                        }
                                    }
                                    .onEnded { _ in
                                        dragOnEnded()
                                        beforeDragOffsetY = .zero
                                        isLongPressed = false
                                    }
                                )
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    if !isLongPressed {
                                        layerList[index].scale = value
                                    }
                                }

                        )
                        .simultaneousGesture(
                            DragGesture()
                            .onChanged{ value in
                                if !isLongPressed {
                                    layerList[index].position = value.location
                                }
                                
                            }
                        )
                        .simultaneousGesture(
                            RotationGesture()
                                .onChanged { value in
                                    if !isLongPressed {
                                        layerList[index].rotation = value
                                    }
                                }
                        )
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            HStack {
                if isLongPressed {
                    layerIndicator
                }
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
            LayerPhotoPicker2(layerImages: $layerList, screenSize: UIScreen.main.bounds.size)
        }
    }
    
    var layerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(layerList.indices.reversed(), id: \.self) { index in
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
    
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            isDragging = true
        }
        
        let dragOffsetY = value.translation.height
        let diff = dragOffsetY - beforeDragOffsetY
        var currentStep = Int(diff / 50)
        if diff < 0 && diff > -50 {
            currentStep = 0
        }
        
        if let currentIndex = selectedLayerIndex, currentStep != 0 {
            if diff > 0 {
                if currentIndex - currentStep < 0 {
                    currentStep = currentIndex
                }
                selectedLayerIndex = moveLayerForward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
            } else {
                if currentStep + currentIndex > layerList.count {
                    let diff = currentStep + currentIndex - layerList.count
                    currentStep = layerList.count - currentIndex
                }
                selectedLayerIndex = moveLayerBackward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
            }
        }
    }
    
    func dragOnEnded() {
        isDragging = false
        selectedLayerIndex = nil
    }
    
    func moveLayerForward(at index: Int, steps: Int) -> Int {
        guard steps > 0 else { return index }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex > 0 else { return 0 }
            guard currentIndex < layerList.count else { return layerList.count - 1 }
            layerList.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
        return currentIndex
    }
    
    func moveLayerBackward(at index: Int, steps: Int) -> Int {
        guard steps > 0 else { return index }
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < layerList.count - 1 else { return layerList.count - 1 }
            guard currentIndex >= 0 else { return 0 }
            layerList.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
        return currentIndex
    }
}

struct LayerModel: Identifiable {
    let id = UUID()
    var image: UIImage
    var order: Int
    var position: CGPoint = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}

