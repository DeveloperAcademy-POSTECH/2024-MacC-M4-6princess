//
//  DF+Modify.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 12/1/24.
//

import SwiftUI
import Foundation
import CoreData

extension DFModifyView{
    
    // 레이어를 앞으로 이동
    func moveLayerForward(at index: Int, steps: Int) -> Int{
        guard steps > 0 else { return index}
        var currentIndex = index
        print("forward steps:\(steps)")
        for _ in 0..<steps {
            guard currentIndex > 0 else { return 0}
            guard currentIndex < imageModel.imageList.count else { return imageModel.imageList.count - 1}
//            print("currentIndex: \(currentIndex),currentIndex - 1: \(currentIndex - 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex - 1)
            currentIndex -= 1
        }
        return currentIndex
    }
    
    // 레이어를 뒤로 이동
    func moveLayerBackward(at index: Int, steps: Int) -> Int{
        guard steps > 0 else { return index}
        var currentIndex = index
        for _ in 0..<steps {
            guard currentIndex < imageModel.imageList.count - 1 else { return imageModel.imageList.count-1}
            guard currentIndex >= 0 else { return 0}
//            print("currentIndex: \(currentIndex),currentIndex + 1: \(currentIndex + 1)")
            imageModel.imageList.swapAt(currentIndex, currentIndex + 1)
            currentIndex += 1
        }
        return currentIndex
    }
    
    // 레이어 순서 표시 뷰(구버전)
    var newLayerIndicator: some View {
        HStack{
            Group{
                VStack() {
                    
                    Button(action: {
                        if let index = viewModel.selectedIndex{
                            viewModel.selectedIndex = moveLayerBackward(at: index, steps: 1)
                        }
                        else{
                            // 에러처리
                        }
                        withAnimation(.spring()) {
                            viewModel.isPressedUp = true
                        }
                        // 일정 시간 후 다시 false로 복구
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) {
                                viewModel.isPressedUp = false
                            }
                        }
                    }) {
                        HStack {
                            Image("layer.up")
                                .frame(width: 14, height: 14)
                                .scaleEffect(viewModel.isPressedUp ? 1.2 : 1.0)
                        }
                        .padding(5)
                        .frame(width: 24, height: 24, alignment: .leading)
                        .background(.white)
                        .cornerRadius(12)
                    }
                    
                    // caption
                    Text("앞으로")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray01)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                        .frame(height: 12)
                    Button(action: {
                        if let index = viewModel.selectedIndex{
                            viewModel.selectedIndex=moveLayerForward(at: index, steps: 1)
                            
                        }
                        else{
                            // 에러처리
                        }
                        withAnimation(.spring()) {
                            viewModel.isPressedDown = true
                        }
                        // 일정 시간 후 다시 false로 복구
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) {
                                viewModel.isPressedDown = false
                            }
                        }
                    }) {
                        HStack {
                            Image("layer.down")
                                .frame(width: 14, height: 14)
                                .scaleEffect(viewModel.isPressedDown ? 1.2 : 1.0)
                        }
                        .padding(5)
                        .frame(width: 24, height: 24, alignment: .leading)
                        .background(.white)
                        .cornerRadius(12)
                    }
                    
                    // caption
                    Text("뒤로")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray01)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.vertical, 8)
                .frame(width: 40, height: 116, alignment: .topLeading)
                .background(.gray03)
                .cornerRadius(20)
            }
            .padding(10)
            Spacer()
            
        }
    }
    
    func imageListUpdate() {
        // 길게 누름 상태 초기화
        if imageModel.imageList.count > 0 {
            imageModel.imageList.append(imageModel.imageList[0])
            imageModel.imageList.removeLast()
        }
    }
    
    // 1초 길게 누르고 드래그 제스처를 생성하는 함수
    func longPressAndDragGesture(for index: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5) // 1초 동안 길게 누름
            .onEnded { _ in
                isLongPressed = true // 길게 눌림 활성화
                selectedLayerIndex = index
                imageListUpdate()
                
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
                    beforeDragOffsetY = .zero
                    isLongPressed = false
                    imageListUpdate()
                }
            )
    }
    
    
    func combinedGesture(subject: SubjectImage) -> some Gesture {
        
        DragGesture()
            .onChanged { value in
                if !isLongPressed{
                    viewModel.dragGestureTask(subject: subject, changed: value.translation)
                }
            }
            .onEnded { value in
                if !isLongPressed {
                    viewModel.accumulatedOffSet = .zero
                    viewModel.modelListControl(subject: subject)
                    subject.isTapped = true
                    imageModel.imageList.append(subject)
                    imageModel.imageList.removeLast()
                }
                
            }
            .simultaneously(with: RotateGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped  {
                        if viewModel.current == .zero {
                            viewModel.current = subject.getAngle()
                        }
                        viewModel.angle = value.rotation + viewModel.current
                        subject.setAngle(angle: viewModel.angle)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.current = .zero
                    }
                }
            )
            .simultaneously(with: MagnifyGesture()
                .onChanged { value in
                    if !isLongPressed && subject.isTapped {
                        viewModel.setScaleVolume(value.magnification, subject: subject)
                    }
                }
                .onEnded { value in
                    if !isLongPressed{
                        viewModel.setScaleValue(minimum: 0.2, maximum: 10, subject: subject)
                    }
                }
            )
    }
    
    var toolBarButtons: some View {
        HStack {
            Button {
                viewModel.isAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray01)
                }
            }
            .alert("프레임 편집을 종료하시겠습니까?", isPresented: $viewModel.isAlert) {
                Button {
                    viewModel.isAlert.toggle()
                } label: {
                    Text("취소")
                }
                
                Button {
                    imageModel.imageList.removeAll()
                    if naviManager.route.count > 3 {
                        naviManager.pop(depth: naviManager.route.count - 1)
                    } else {
                        naviManager.pop()
                    }
                } label: {
                    Text("나가기")
                }
                
            } message: {
                Text("종료 시 편집된 내용은 저장되지 않습니다.")
            }
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 20)
            
            
            Text("프레임 꾸미기")
                .foregroundStyle(.gray01)
                .font(.system(size: 17))
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.width * 0.27, height: UIScreen.main.bounds.height * 0.035)
                .padding(.leading, UIScreen.main.bounds.width * 0.1)
                .padding(.trailing, UIScreen.main.bounds.width * 0.1)
            
            Button {
                if let _  = frameManager.updateFrame {
                    
                    imageModel.imageList.forEach {
                        $0.isTapped = false
                    }
                    
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    
                    viewModel.updateImage(view: imageView, frameManager: frameManager, viewContext: managedContext, imageModel: imageModel) {
                        
                        viewModel.btnOpacity = 0
                        viewModel.showCamera = true
                        imageModel.imageList.removeAll()
                        frameManager.resultImage = viewModel.frameImage
                        frameManager.updateFrame = nil
                        frameManager.selectedFrame = nil
                    }
                    
                } else if let image = frameManager.removedImage {
                    
                    imageModel.imageList.forEach {
                        $0.isTapped = false
                    }
                    
                    viewModel.saveStateText = "저장 중입니다..."
                    viewModel.isPushedSaveBtn = true
                    
                    viewModel.saveImage(view: imageView, inputImage: image, context: managedContext, imageModel: imageModel) {
                        
                        viewModel.btnOpacity = 0
                        viewModel.showCamera = true
                        imageModel.imageList.removeAll()
                        frameManager.resultImage = viewModel.frameImage
                        frameManager.removedImage = nil
                    }
                    
                } else {
                    
                    viewModel.saveStateText = "저장할 이미지가 없습니다."
                    Task {
                        viewModel.btnOpacity = 1
                        try await Task.sleep(for: .seconds(1))
                        viewModel.btnOpacity = 0
                    }
                }
                if !frameManager.firstTime {
                    frameManager.firstTime = true
                }
                frameManager.isFrameLoading = true
            } label: {
                Text("저장")
                    .fontWeight(.semibold)
                    .foregroundStyle(.pointPink)
                    .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.height / 20)
            }
            .padding(.trailing, UIScreen.main.bounds.width * 0.1)
            .disabled(viewModel.isPushedSaveBtn)
            
        }
    }
}
// 인스타 layer 버전
extension DFModifyView{
    // 레이어 순서 표시 뷰(구버전)
    var oldLayerIndicator: some View {
        VStack(spacing: 6) {
            ForEach(imageModel.imageList.indices.reversed(), id: \.self) { index in
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
    // 드래그 중 호출되는 함수 (구버전)
    func dragOnChanged(value: DragGesture.Value, index: Int) {
        if !isDragging {
            selectedLayerIndex = index
            isDragging = true
        }
        
        let dragOffsetY = value.translation.height
        // 차이
        let diff = dragOffsetY - beforeDragOffsetY
        /*
         0 -> 50 (backward) => 50
         0 -> -50 (forward) => -50
         */
        var currentStep = Int(diff / 50)
        if diff < 0 && diff > -50 {
            currentStep = 0
        }
        // 밑으로 내리면 -> backward (index 증가)
        // 밑으로 내리면 dragOffsetY가 양수
        // 위로 올리면 -> Forward (index 감소)
        // 위로 올리면 dragOffsetY가 마이너스
        
        if let currentIndex = selectedLayerIndex,
           currentStep != 0
        //            currentStep != currentIndex
        {
            if diff > 0 {
                if currentIndex - currentStep < 0{
                    currentStep = currentIndex
                }
                /// 인덱스 감소
                selectedLayerIndex = moveLayerForward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
                imageModel.imageList.append(imageModel.imageList[0])
                imageModel.imageList.removeLast()
            } else {
                if currentStep + currentIndex > imageModel.imageList.count{
                    let diff = currentStep + currentIndex - imageModel.imageList.count
                    currentStep = imageModel.imageList.count - currentIndex
                }
                /// 인덱스 증가
                selectedLayerIndex = moveLayerBackward(at: currentIndex, steps: abs(currentStep))
                beforeDragOffsetY = dragOffsetY
                imageModel.imageList.append(imageModel.imageList[0])
                imageModel.imageList.removeLast()
            }
        }
    }
    // 드래그 종료 시 호출되는 함수
    func dragOnEnded() {
        isDragging = false
        selectedLayerIndex = nil
    }
}
